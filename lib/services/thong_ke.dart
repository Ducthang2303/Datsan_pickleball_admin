import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:pickleball_admin/models/hoa_don.dart';

class DoanhThuThongKeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<double> getDoanhThuThangHienTai({String? maKhu}) async {
    final DateTime now = DateTime.now();
    return getDoanhThuTheoThang(now.month, now.year, maKhu: maKhu);
  }


  Future<double> getDoanhThuTheoThang(int thang, int nam, {String? maKhu}) async {
    try {

      final DateTime ngayDauThang = DateTime(nam, thang, 1);
      final DateTime ngayCuoiThang = (thang < 12)
          ? DateTime(nam, thang + 1, 1).subtract(Duration(days: 1))
          : DateTime(nam + 1, 1, 1).subtract(Duration(days: 1));


      final Timestamp timestampBatDau = Timestamp.fromDate(ngayDauThang);
      final Timestamp timestampKetThuc = Timestamp.fromDate(
          DateTime(ngayCuoiThang.year, ngayCuoiThang.month, ngayCuoiThang.day, 23, 59, 59));


      Query query = _firestore
          .collection('HOA_DON')
          .where('trangThai', isEqualTo: 'Đã duyệt')
          .where('thoiGianTao', isGreaterThanOrEqualTo: timestampBatDau)
          .where('thoiGianTao', isLessThanOrEqualTo: timestampKetThuc);

      // Thêm bộ lọc theo maKhu nếu có
      if (maKhu != null) {
        query = query.where('maKhu', isEqualTo: maKhu);
      }

      final QuerySnapshot querySnapshot = await query.get();


      double tongDoanhThu = 0;
      for (var doc in querySnapshot.docs) {
        final hoaDon = HoaDon.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        tongDoanhThu += hoaDon.giaTien;
      }

      return tongDoanhThu;
    } catch (e) {
      print('Lỗi khi lấy doanh thu theo tháng: $e');
      return 0;
    }
  }


  Future<List<HoaDon>> getDanhSachHoaDonDaDuyetTheoThang(int thang, int nam, {String? maKhu}) async {
    try {

      final DateTime ngayDauThang = DateTime(nam, thang, 1);
      final DateTime ngayCuoiThang = (thang < 12)
          ? DateTime(nam, thang + 1, 1).subtract(Duration(days: 1))
          : DateTime(nam + 1, 1, 1).subtract(Duration(days: 1));


      final Timestamp timestampBatDau = Timestamp.fromDate(ngayDauThang);
      final Timestamp timestampKetThuc = Timestamp.fromDate(
          DateTime(ngayCuoiThang.year, ngayCuoiThang.month, ngayCuoiThang.day, 23, 59, 59));


      Query query = _firestore
          .collection('HOA_DON')
          .where('trangThai', isEqualTo: 'Đã duyệt')
          .where('thoiGianTao', isGreaterThanOrEqualTo: timestampBatDau)
          .where('thoiGianTao', isLessThanOrEqualTo: timestampKetThuc)
          .orderBy('thoiGianTao', descending: true);

      // Thêm bộ lọc theo maKhu nếu có
      if (maKhu != null) {
        query = query.where('maKhu', isEqualTo: maKhu);
      }

      final QuerySnapshot querySnapshot = await query.get();

      // Chuyển đổi dữ liệu thành danh sách các đối tượng HoaDon
      List<HoaDon> danhSachHoaDon = querySnapshot.docs
          .map((doc) => HoaDon.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return danhSachHoaDon;
    } catch (e) {
      print('Lỗi khi lấy danh sách hóa đơn đã duyệt theo tháng: $e');
      return [];
    }
  }

  // Lấy thống kê doanh thu theo từng ngày trong tháng
  Future<Map<int, double>> getDoanhThuTheoNgayTrongThang(int thang, int nam, {String? maKhu}) async {
    try {
      final danhSachHoaDon = await getDanhSachHoaDonDaDuyetTheoThang(thang, nam, maKhu: maKhu);


      Map<int, double> doanhThuTheoNgay = {};


      final daysInMonth = DateTime(nam, thang + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        doanhThuTheoNgay[i] = 0;
      }


      for (var hoaDon in danhSachHoaDon) {
        if (hoaDon.thoiGianTao != null) {
          final ngay = hoaDon.thoiGianTao!.day;
          doanhThuTheoNgay[ngay] = (doanhThuTheoNgay[ngay] ?? 0) + hoaDon.giaTien;
        }
      }

      return doanhThuTheoNgay;
    } catch (e) {
      print('Lỗi khi lấy doanh thu theo ngày trong tháng: $e');
      return {};
    }
  }


  Future<Map<String, double>> getDoanhThuTheoKhuVuc(int thang, int nam, {String? maKhu}) async {
    try {
      final danhSachHoaDon = await getDanhSachHoaDonDaDuyetTheoThang(thang, nam, maKhu: maKhu);


      Map<String, double> doanhThuTheoKhuVuc = {};


      for (var hoaDon in danhSachHoaDon) {
        final tenKhu = hoaDon.tenKhu;
        doanhThuTheoKhuVuc[tenKhu] = (doanhThuTheoKhuVuc[tenKhu] ?? 0) + hoaDon.giaTien;
      }

      return doanhThuTheoKhuVuc;
    } catch (e) {
      print('Lỗi khi lấy doanh thu theo khu vực: $e');
      return {};
    }
  }


  Future<Map<String, dynamic>> getNgayCoDoanhThuCaoNhatTrongThang(int thang, int nam, {String? maKhu}) async {
    try {
      final doanhThuTheoNgay = await getDoanhThuTheoNgayTrongThang(thang, nam, maKhu: maKhu);

      if (doanhThuTheoNgay.isEmpty) {
        return {'ngay': 0, 'doanhThu': 0.0};
      }


      int ngayCaoNhat = 1;
      double doanhThuCaoNhat = 0;

      doanhThuTheoNgay.forEach((ngay, doanhThu) {
        if (doanhThu > doanhThuCaoNhat) {
          ngayCaoNhat = ngay;
          doanhThuCaoNhat = doanhThu;
        }
      });

      return {'ngay': ngayCaoNhat, 'doanhThu': doanhThuCaoNhat};
    } catch (e) {
      print('Lỗi khi tìm ngày có doanh thu cao nhất: $e');
      return {'ngay': 0, 'doanhThu': 0.0};
    }
  }


  Future<int> getTongSoHoaDonDaDuyetTrongThang(int thang, int nam, {String? maKhu}) async {
    try {
      final danhSachHoaDon = await getDanhSachHoaDonDaDuyetTheoThang(thang, nam, maKhu: maKhu);
      return danhSachHoaDon.length;
    } catch (e) {
      print('Lỗi khi lấy tổng số hóa đơn đã duyệt: $e');
      return 0;
    }
  }


  Future<double> getGiaTriTrungBinhHoaDonTrongThang(int thang, int nam, {String? maKhu}) async {
    try {
      final danhSachHoaDon = await getDanhSachHoaDonDaDuyetTheoThang(thang, nam, maKhu: maKhu);

      if (danhSachHoaDon.isEmpty) {
        return 0;
      }

      double tongGiaTri = 0;
      for (var hoaDon in danhSachHoaDon) {
        tongGiaTri += hoaDon.giaTien;
      }

      return tongGiaTri / danhSachHoaDon.length;
    } catch (e) {
      print('Lỗi khi tính giá trị trung bình hóa đơn: $e');
      return 0;
    }
  }


  Future<Map<String, dynamic>> soSanhDoanhThuHaiThang(
      int thang1, int nam1, int thang2, int nam2, {String? maKhu}) async {
    try {
      final doanhThuThang1 = await getDoanhThuTheoThang(thang1, nam1, maKhu: maKhu);
      final doanhThuThang2 = await getDoanhThuTheoThang(thang2, nam2, maKhu: maKhu);

      final double tyLeTangGiam = doanhThuThang1 != 0
          ? ((doanhThuThang2 - doanhThuThang1) / doanhThuThang1) * 100
          : (doanhThuThang2 > 0 ? 100 : 0);

      return {
        'doanhThuThang1': doanhThuThang1,
        'doanhThuThang2': doanhThuThang2,
        'chenhLech': doanhThuThang2 - doanhThuThang1,
        'tyLeTangGiam': tyLeTangGiam,
      };
    } catch (e) {
      print('Lỗi khi so sánh doanh thu hai tháng: $e');
      return {
        'doanhThuThang1': 0.0,
        'doanhThuThang2': 0.0,
        'chenhLech': 0.0,
        'tyLeTangGiam': 0.0,
      };
    }
  }
}