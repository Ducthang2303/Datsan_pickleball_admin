class Khu {
  String id;
  String ma;
  String ten;

  Khu({required this.id, required this.ma, required this.ten});

  factory Khu.fromMap(Map<String, dynamic> data, String docId) {
    return Khu(
      id: docId,
      ma: data["MA"] ?? "",
      ten: data["TEN"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "MA": ma,
      "TEN": ten,
    };
  }
}
