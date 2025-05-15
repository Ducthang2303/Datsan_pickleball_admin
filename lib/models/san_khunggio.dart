import 'khung_gio.dart';

class SanKhungGio {
  final String maSan;
  final String ngay;
  final List<KhungGio> khungGio;

  SanKhungGio({
    required this.maSan,
    required this.ngay,
    required this.khungGio,
  });

  // Chuyển từ Map Firestore sang Object
  factory SanKhungGio.fromMap(Map<String, dynamic> map, String id) {
    return SanKhungGio(
      maSan: map["MA_SAN"] ?? "",
      ngay: map["NGAY"] ?? "",
      khungGio: (map["KHUNG_GIO"] as List<dynamic>).map((item) => KhungGio.fromMap(item)).toList(),

    );
  }



  // Chuyển Object thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      "MA_SAN": maSan,
      "NGAY": ngay,
      "KHUNG_GIO": khungGio.map((item) => item.toMap()).toList(),

    };
  }
}
