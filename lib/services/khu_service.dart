// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/khu.dart';
//
// class KhuService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   // Lấy danh sách khu từ Firestore
//   Future<List<Khu>> fetchKhuList() async {
//     try {
//       QuerySnapshot snapshot = await _db.collection("KHU").get();
//       return snapshot.docs.map((doc) => Khu.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
//     } catch (e) {
//       print("Lỗi lấy danh sách khu: $e");
//       return [];
//     }
//   }
//
//   // Thêm khu mới
//   Future<void> addKhu(Khu khu) async {
//     try {
//       await _db.collection("KHU").add(khu.toMap());
//     } catch (e) {
//       print("Lỗi thêm khu: $e");
//     }
//   }
//
//   // Cập nhật khu
//   Future<void> updateKhu(Khu khu) async {
//     try {
//       await _db.collection("KHU").doc(khu.id).update(khu.toMap());
//     } catch (e) {
//       print("Lỗi cập nhật khu: $e");
//     }
//   }
//
//   // Xóa khu
//   Future<void> deleteKhu(String khuId) async {
//     try {
//       await _db.collection("KHU").doc(khuId).delete();
//     } catch (e) {
//       print("Lỗi xóa khu: $e");
//     }
//   }
// }
