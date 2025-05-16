import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/san.dart';

class SanService {
  final CollectionReference sanCollection = FirebaseFirestore.instance.collection('SAN');


  Future<List<San>> getAllSan() async {
    try {
      QuerySnapshot snapshot = await sanCollection.get();
      return snapshot.docs.map((doc) => San.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Lỗi khi lấy danh sách sân: $e");
      return [];
    }
  }


  Future<List<San>> getSanByKhu(String maKhu) async {
    try {
      QuerySnapshot snapshot = await sanCollection.where('MA_KHU', isEqualTo: maKhu).get();
      return snapshot.docs.map((doc) => San.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Lỗi khi lấy danh sách sân theo khu: $e");
      return [];
    }
  }


  Future<void> addSan(San san) async {
    try {
      await sanCollection.add(san.toMap());
    } catch (e) {
      print("Lỗi khi thêm sân: $e");
    }
  }


  Future<void> updateSan(San san) async {
    try {
      await sanCollection.doc(san.id).update(san.toMap());
    } catch (e) {
      print("Lỗi khi cập nhật sân: $e");
    }
  }


  Future<void> deleteSan(String sanId) async {
    try {
      await sanCollection.doc(sanId).delete();
    } catch (e) {
      print("Lỗi khi xóa sân: $e");
    }
  }
}
