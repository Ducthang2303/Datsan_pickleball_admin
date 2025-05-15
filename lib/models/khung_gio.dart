class KhungGio {
  final String gioBatDau;
  final String gioKetThuc;
  int trangThai; // Using int: 0=Available, 1=Booked, 2=Locked
  int giaTien;

  KhungGio({
    required this.gioBatDau,
    required this.gioKetThuc,
    this.trangThai = 0, // Default is 0 (available)
    required this.giaTien,
  });

  factory KhungGio.fromMap(Map<String, dynamic> map) {
    return KhungGio(
      gioBatDau: map['gioBatDau'] ?? '',
      gioKetThuc: map['gioKetThuc'] ?? '',
      trangThai: map['trangThai'] ?? 0, // Default to 0 if null
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