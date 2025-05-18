class NguoiDung {
  final String id;
  final String email;
  final String hoTen;
  final String tenDangNhap;
  final String soDienThoai;
  final String vaiTro;
  final String? anhDaiDien;
  final String trangThai; // Changed from isLocked to trangThai

  NguoiDung({
    required this.id,
    required this.email,
    required this.hoTen,
    required this.tenDangNhap,
    required this.soDienThoai,
    required this.vaiTro,
    this.anhDaiDien,
    required this.trangThai,
  });

  factory NguoiDung.fromMap(String id, Map<String, dynamic> json) {
    return NguoiDung(
      id: id,
      email: json['EMAIL'] ?? '',
      hoTen: json['HO_TEN'] ?? '',
      tenDangNhap: json['TEN_DANG_NHAP'] ?? '',
      soDienThoai: json['SO_DIEN_THOAI'] ?? '',
      vaiTro: json['VAI_TRO'] ?? 'user',
      anhDaiDien: json['ANH_DAI_DIEN'],
      trangThai: json['TRANG_THAI'] ?? (json['IS_LOCKED'] == true ? 'locked' : 'active'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'EMAIL': email,
      'HO_TEN': hoTen,
      'TEN_DANG_NHAP': tenDangNhap,
      'SO_DIEN_THOAI': soDienThoai,
      'VAI_TRO': vaiTro,
      'ANH_DAI_DIEN': anhDaiDien,
      'TRANG_THAI': trangThai,
    };
  }
}