import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pickleball_admin/models/khu.dart';
import 'package:pickleball_admin/services/thong_ke.dart';
import 'package:pickleball_admin/services/san_khu_service.dart';

class ThongKeDoanhThuController with ChangeNotifier {
  final DoanhThuThongKeService _thongKeService = DoanhThuThongKeService();
  final SanKhuService _sanKhuService = SanKhuService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  double _tongDoanhThu = 0;
  int _tongDonHang = 0;
  Map<int, double> _doanhThuTheoNgay = {};
  List<Khu> _khuList = [];
  Khu? _selectedKhu;
  int _thang = DateTime.now().month;
  int _nam = DateTime.now().year;
  String? _errorMessage;


  bool get isLoading => _isLoading;
  double get tongDoanhThu => _tongDoanhThu;
  int get tongDonHang => _tongDonHang;
  Map<int, double> get doanhThuTheoNgay => _doanhThuTheoNgay;
  List<Khu> get khuList => _khuList;
  Khu? get selectedKhu => _selectedKhu;
  int get thang => _thang;
  int get nam => _nam;
  String? get errorMessage => _errorMessage;


  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  ThongKeDoanhThuController() {
    _loadKhuAndData();
  }

  Future<void> _loadKhuAndData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không tìm thấy người dùng. Vui lòng đăng nhập lại.');
      }
      final userId = user.uid;
      print('Fetching khu for user: $userId');

      _khuList = await _sanKhuService.getKhuByUserId(userId);
      print('Fetched khuList: ${_khuList.map((k) => k.id).toList()}');

      if (_khuList.isNotEmpty) {
        _selectedKhu = _khuList.first;
        print('Selected khu: ${_selectedKhu?.id}');
      } else {
        _errorMessage = 'Không có khu nào được phân công';
      }

      await _loadData();
    } catch (e) {
      print('Error in _loadKhuAndData: $e');
      _errorMessage = 'Không thể tải dữ liệu khu hoặc thống kê: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_selectedKhu == null) {
        _tongDoanhThu = 0;
        _tongDonHang = 0;
        _doanhThuTheoNgay = {};
        _isLoading = false;
        _errorMessage = 'Vui lòng chọn một khu để xem thống kê';
        notifyListeners();
        return;
      }

      print('Loading data for khu: ${_selectedKhu!.id}, thang: $_thang, nam: $_nam');


      final doanhThu = await _thongKeService.getDoanhThuTheoThang(_thang, _nam, maKhu: _selectedKhu!.id);


      final tongDonHang =
      await _thongKeService.getTongSoHoaDonDaDuyetTrongThang(_thang, _nam, maKhu: _selectedKhu!.id);


      final doanhThuNgay =
      await _thongKeService.getDoanhThuTheoNgayTrongThang(_thang, _nam, maKhu: _selectedKhu!.id);

      _tongDoanhThu = doanhThu;
      _tongDonHang = tongDonHang;
      _doanhThuTheoNgay = doanhThuNgay;
      _isLoading = false;
      if (_doanhThuTheoNgay.isEmpty) {
        _errorMessage = 'Không có dữ liệu doanh thu trong tháng $_thang/$_nam cho khu ${_selectedKhu!.ten}';
      }
      print('Loaded doanh thu: $_tongDoanhThu, don hang: $_tongDonHang, days: ${_doanhThuTheoNgay.length}');
      notifyListeners();
    } catch (e) {
      print('Error in _loadData: $e');
      _tongDoanhThu = 0;
      _tongDonHang = 0;
      _doanhThuTheoNgay = {};
      _errorMessage = 'Không thể tải dữ liệu thống kê: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectKhu(Khu? newKhu) {
    if (_selectedKhu != newKhu) {
      _selectedKhu = newKhu;
      print('Selected khu: ${_selectedKhu?.id}');
      _loadData();
    }
  }

  void thayDoiThang(int thang, int nam) {
    if (_thang != thang || _nam != nam) {
      _thang = thang;
      _nam = nam;
      print('Changed to thang: $_thang, nam: $_nam');
      _loadData();
    }
  }

  Future<void> refreshData() async {
    await _loadKhuAndData();
  }


  double findMaxDoanhThuNgay() {
    double max = 0;
    _doanhThuTheoNgay.forEach((ngay, doanhThu) {
      if (doanhThu > max) {
        max = doanhThu;
      }
    });
    return max > 0 ? max : 1000000;
  }

  String formatCurrencyShort(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}