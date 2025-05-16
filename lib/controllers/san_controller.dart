import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pickleball_admin/models/khu.dart';
import 'package:pickleball_admin/models/san.dart';
import 'package:pickleball_admin/models/san_khunggio.dart';
import 'package:pickleball_admin/services/san_khu_service.dart';

import '../models/khung_gio.dart';

class SanController with ChangeNotifier {
  final SanKhuService _sanKhuService = SanKhuService();
  final String userId;

  List<Khu> danhSachKhu = [];
  List<San> danhSachSan = [];
  List<SanKhungGio> danhSachKhungGio = [];

  String? selectedKhuMa;
  DateTime selectedDate = DateTime.now();
  String ngayHienTai = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool expandedKhu = false;
  bool isLoading = false;

  SanController(this.userId) {
    fetchKhu();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF2196F3), // AppColors.Blue
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2196F3),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF2196F3),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      ngayHienTai = DateFormat('yyyy-MM-dd').format(selectedDate);
      notifyListeners();
      if (selectedKhuMa != null) {
        await fetchSanVaKhungGio(selectedKhuMa!);
      }
    }
  }

  Future<void> fetchKhu() async {
    isLoading = true;
    notifyListeners();
    try {
      danhSachKhu = await _sanKhuService.getKhuByUserId(userId);
      if (danhSachKhu.isNotEmpty && selectedKhuMa == null) {
        selectedKhuMa = danhSachKhu.first.ma;
        await fetchSanVaKhungGio(selectedKhuMa!);
      }
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách khu: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSanVaKhungGio(String maKhu) async {
    isLoading = true;
    notifyListeners();
    try {
      danhSachSan = await _sanKhuService.getSanByKhu(maKhu);
      danhSachKhungGio = [];
      if (danhSachSan.isNotEmpty) {
        final khungGioFutures = danhSachSan.map(
              (san) => _sanKhuService.getKhungGioBySan(san.ma, ngayHienTai),
        ).toList();
        final List<List<SanKhungGio>> khungGioResults = await Future.wait(khungGioFutures);
        danhSachKhungGio = khungGioResults.expand((list) => list).toList();
      }
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu sân: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAllKhungGioForSan(San san) async {
    isLoading = true;
    notifyListeners();
    try {
      await _sanKhuService.addAllKhungGioForSan(san.ma, ngayHienTai);
      await fetchSanVaKhungGio(selectedKhuMa!);
    } catch (e) {
      throw Exception('Lỗi khi thêm khung giờ: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleKhungGioStatus(SanKhungGio sanKhungGio, int khungGioIndex) async {
    KhungGio khungGio = sanKhungGio.khungGio[khungGioIndex];
    if (khungGio.trangThai == 1) return;

    int newStatus = khungGio.trangThai == 0 ? 2 : 0;
    int oldStatus = khungGio.trangThai;

    sanKhungGio.khungGio[khungGioIndex].trangThai = newStatus;
    notifyListeners();

    try {
      await _sanKhuService.updateKhungGioStatus(
        sanKhungGio.maSan,
        ngayHienTai,
        khungGioIndex,
        newStatus,
      );
    } catch (e) {
      sanKhungGio.khungGio[khungGioIndex].trangThai = oldStatus;
      notifyListeners();
      throw Exception('Lỗi khi cập nhật trạng thái: $e');
    }
  }

  Future<void> toggleSanStatus(San san) async {
    bool newStatus = !san.trangThai;
    bool oldStatus = san.trangThai;

    san.trangThai = newStatus;
    notifyListeners();

    try {
      bool success = await _sanKhuService.updateSanStatus(san.id, newStatus);
      if (!success) {
        throw Exception('Failed to update court status');
      }
    } catch (e) {
      san.trangThai = oldStatus;
      notifyListeners();
      throw Exception('Cập nhật trạng thái sân thất bại: $e');
    }
  }

  Future<void> addSan(San san) async {
    isLoading = true;
    notifyListeners();
    try {
      String? sanId = await _sanKhuService.addSan(san);
      if (sanId != null) {
        await fetchSanVaKhungGio(selectedKhuMa!);
      } else {
        throw Exception('Failed to add court');
      }
    } catch (e) {
      throw Exception('Thêm sân thất bại: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSan(San san) async {
    isLoading = true;
    notifyListeners();
    try {
      bool success = await _sanKhuService.deleteSan(san.id);
      if (success) {
        await fetchSanVaKhungGio(selectedKhuMa!);
      } else {
        throw Exception('Failed to delete court');
      }
    } catch (e) {
      throw Exception('Xóa sân thất bại: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getStatusBackgroundColor(int status) {
    switch (status) {
      case 0:
        return Colors.green.shade100;
      case 1:
        return Colors.orange.shade100;
      case 2:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  IconData getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.check_circle;
      case 1:
        return Icons.event_busy;
      case 2:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}