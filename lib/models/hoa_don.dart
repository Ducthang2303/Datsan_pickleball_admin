import 'package:cloud_firestore/cloud_firestore.dart';

class KhungGioHoaDon {
  final String ngay;
  final String gioBatDau;
  final String gioKetThuc;

  KhungGioHoaDon({
    required this.ngay,
    required this.gioBatDau,
    required this.gioKetThuc,
  });

  factory KhungGioHoaDon.fromMap(Map<String, dynamic> data) {
    return KhungGioHoaDon(
      ngay: data['ngay'] ?? '',
      gioBatDau: data['gioBatDau'] ?? '',
      gioKetThuc: data['gioKetThuc'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ngay': ngay,
      'gioBatDau': gioBatDau,
      'gioKetThuc': gioKetThuc,
    };
  }
}

class HoaDon {
  final String id;
  final String maNguoiDung;
  final String hoTenNguoiDung;
  final String maSan;
  final String maKhu;
  final String tenSan;
  final String tenKhu;
  final List<KhungGioHoaDon> khungGio;
  final int giaTien;
  final String? anhChuyenKhoan;
  final String trangThai;
  final DateTime? thoiGianTao;

  HoaDon({
    required this.id,
    required this.maNguoiDung,
    required this.hoTenNguoiDung,
    required this.maSan,
    required this.maKhu,
    required this.tenSan,
    required this.tenKhu,
    required this.khungGio,
    required this.giaTien,
    required this.anhChuyenKhoan,
    required this.trangThai,
    required this.thoiGianTao,
  });

  factory HoaDon.fromMap(Map<String, dynamic> data, String documentId) {
    List<KhungGioHoaDon> khungGio = [];
    if (data['khungGio'] != null) {
      khungGio = (data['khungGio'] as List<dynamic>)
          .map((item) => KhungGioHoaDon.fromMap(item))
          .toList();
    } else if (data['ngay'] != null) {
      khungGio = [
        KhungGioHoaDon(
          ngay: data['ngay'] ?? '',
          gioBatDau: data['gioBatDau'] ?? '',
          gioKetThuc: data['gioKetThuc'] ?? '',
        )
      ];
    }

    return HoaDon(
      id: documentId,
      maNguoiDung: data['maNguoiDung'] ?? '',
      hoTenNguoiDung: data['hoTenNguoiDung'] ?? '',
      maSan: data['maSan'] ?? '',
      maKhu: data['maKhu'] ?? '',
      tenSan: data['tenSan'] ?? '',
      tenKhu: data['tenKhu'] ?? '',
      khungGio: khungGio,
      giaTien: data['giaTien'] ?? 0,
      anhChuyenKhoan: data['anhChuyenKhoan'],
      trangThai: data['trangThai'] ?? 'Chờ xác nhận',
      thoiGianTao: data['thoiGianTao'] != null
          ? (data['thoiGianTao'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maNguoiDung': maNguoiDung,
      'hoTenNguoiDung': hoTenNguoiDung,
      'maKhu': maKhu,
      'maSan': maSan,
      'tenSan': tenSan,
      'tenKhu': tenKhu,
      'khungGio': khungGio.map((item) => item.toMap()).toList(),
      'giaTien': giaTien,
      'anhChuyenKhoan': anhChuyenKhoan,
      'trangThai': trangThai,
      'thoiGianTao': thoiGianTao,
    };
  }
}