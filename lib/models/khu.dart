class Khu {
  String id;
  String ma;
  String ten;

  Khu({required this.id, required this.ma, required this.ten});

  // Chuyển dữ liệu từ Firestore sang đối tượng Khu
  factory Khu.fromMap(Map<String, dynamic> data, String docId) {
    return Khu(
      id: docId,
      ma: data["MA"] ?? "",
      ten: data["TEN"] ?? "",
    );
  }

  // Chuyển đối tượng Khu thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      "MA": ma,
      "TEN": ten,
    };
  }
}
