class KhungGio {
  final String gioBatDau;
  final String gioKetThuc;
  int trangThai;
  int giaTien;

  KhungGio({
    required this.gioBatDau,
    required this.gioKetThuc,
    this.trangThai = 0,
    required this.giaTien,
  });

  factory KhungGio.fromMap(Map<String, dynamic> map) {
    return KhungGio(
      gioBatDau: map['gioBatDau'] ?? '',
      gioKetThuc: map['gioKetThuc'] ?? '',
      trangThai: map['trangThai'] ?? 0,
      giaTien: map['giaTien'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gioBatDau': gioBatDau,
      'gioKetThuc': gioKetThuc,
      'trangThai': trangThai,
      'giaTien': giaTien,
    };
  }
}