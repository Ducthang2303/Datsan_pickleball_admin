import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pickleball_admin/models/hoa_don.dart';
import 'package:pickleball_admin/models/khu.dart';
import 'package:pickleball_admin/services/hoa_don.dart';
import 'package:pickleball_admin/services/san_khu_service.dart';
import 'package:pickleball_admin/services/dat_san.dart';

class HoaDonController with ChangeNotifier {
  final HoaDonService _hoaDonService = HoaDonService();
  final SanKhuService _sanKhuService = SanKhuService();
  final DatSanService _datSanService = DatSanService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HoaDon> _hoaDonList = [];
  List<Khu> _khuList = [];
  Khu? _selectedKhu;
  DateTime? _selectedDate = DateTime.now();
  bool _isLoading = true;
  int _currentTabIndex = 0;
  String? _errorMessage;

  List<HoaDon> get hoaDonList => _hoaDonList;
  List<Khu> get khuList => _khuList;
  Khu? get selectedKhu => _selectedKhu;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  int get currentTabIndex => _currentTabIndex;
  String? get errorMessage => _errorMessage;

  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final dateFormat = DateFormat('dd/MM/yyyy');

  HoaDonController() {
    fetchUserKhuAndHoaDon();
  }

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      print('Tab index changed to: $_currentTabIndex');
      fetchHoaDonList();
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0047AB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      print('Selected date: $_selectedDate');
      _errorMessage = null;
      notifyListeners();
      await fetchHoaDonList();
    }
  }

  Future<void> fetchUserKhuAndHoaDon() async {
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
        print('No khu found for user');
      }

      await fetchHoaDonList();
    } catch (e) {
      print('Error in fetchUserKhuAndHoaDon: $e');
      _hoaDonList = [];
      _errorMessage = 'Không thể tải dữ liệu khu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHoaDonList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_selectedKhu == null || _khuList.isEmpty || _selectedDate == null) {
        print('No khu or date selected. Returning empty list.');
        _hoaDonList = [];
        _errorMessage = 'Vui lòng chọn khu và ngày để xem hóa đơn';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('Fetching hoa don for khu: ${_selectedKhu!.id}, date: $_selectedDate, tab: $_currentTabIndex');
      List<HoaDon> result;
      switch (_currentTabIndex) {
        case 0: // All invoices
          result = await _hoaDonService.getHoaDonByKhuListAndDate([_selectedKhu!.id], _selectedDate!);
          break;
        case 1: // Pending
          result = await _hoaDonService.getHoaDonByKhuListStatusAndDate(
              [_selectedKhu!.id], 'Chờ xác nhận', _selectedDate!);
          break;
        case 2: // Completed
          result = await _hoaDonService.getHoaDonByKhuListStatusAndDate(
              [_selectedKhu!.id], 'Đã duyệt', _selectedDate!);
          break;
        default:
          result = await _hoaDonService.getHoaDonByKhuListAndDate([_selectedKhu!.id], _selectedDate!);
      }

      print('Fetched hoa don count: ${result.length}');
      _hoaDonList = result;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in fetchHoaDonList: $e');
      _hoaDonList = [];
      _errorMessage = 'Không thể tải danh sách hóa đơn: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectKhu(Khu? newKhu) {
    _selectedKhu = newKhu;
    print('Selected khu: ${_selectedKhu?.id}');
    _errorMessage = null;
    notifyListeners();
    fetchHoaDonList();
  }

  Future<void> acceptBooking(HoaDon hoaDon) async {
    try {
      print('Accepting booking: ${hoaDon.id}');
      bool success = await _datSanService.duyetDonDatSan(hoaDon);
      if (success) {
        print('Booking accepted successfully');
        await fetchHoaDonList();
      } else {
        throw Exception('Không thể duyệt đơn.');
      }
    } catch (e) {
      print('Error in acceptBooking: $e');
      throw Exception('Lỗi khi duyệt đơn đặt sân: $e');
    }
  }

  Future<void> cancelBooking(HoaDon hoaDon) async {
    try {
      print('Canceling booking: ${hoaDon.id}');
      bool success = await _datSanService.huyDonDatSan(hoaDon);
      if (success) {
        print('Booking canceled successfully');
        await fetchHoaDonList();
      } else {
        throw Exception('Không thể hủy đơn.');
      }
    } catch (e) {
      print('Error in cancelBooking: $e');
      throw Exception('Lỗi khi hủy đơn đặt sân: $e');
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đã duyệt':
      case 'Đã thanh toán':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}