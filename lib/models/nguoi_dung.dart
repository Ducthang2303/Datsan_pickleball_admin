class NguoiDung {
  final String id;
  final String email;
  late final String hoTen;
  final String tenDangNhap;
  late final String soDienThoai;
  final String vaiTro;
  late final String? anhDaiDien;

  NguoiDung({
    required this.id,
    required this.email,
    required this.hoTen,
    required this.tenDangNhap,
    required this.soDienThoai,
    required this.vaiTro,
    required this.anhDaiDien,
  });

  factory NguoiDung.fromMap(String id, Map<String, dynamic> json) {
    return NguoiDung(
      id: id,
      email: json['EMAIL'] ?? '',
      hoTen: json['HO_TEN'] ?? '',
      tenDangNhap: json['TEN_DANG_NHAP'] ?? '',
      soDienThoai: json['SO_DIEN_THOAI']?? '',
      vaiTro: json['VAI_TRO'] ?? 'user',
      anhDaiDien: json['ANH_DAI_DIEN'] ?? '',
    );
  }
}
