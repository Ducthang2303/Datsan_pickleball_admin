import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nguoi_dung.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<NguoiDung?> signInWithEmailAndPassword(String email, String password) async {
    try {
      FirebaseAuth.instance.setLanguageCode("vi");
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception("Người dùng không tồn tại.");
      }

      String uid = user.uid;

      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore.collection("NGUOIDUNG").doc(uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception("Không tìm thấy dữ liệu người dùng.");
      }


      final userData = userDoc.data()!;
      if (userData["VAI_TRO"] != "ADMIN") {
        await _auth.signOut();
        throw Exception("Bạn không có quyền truy cập. Chỉ ADMIN mới được phép đăng nhập.");
      }
      return NguoiDung.fromMap(uid, userData);
    } catch (e) {
      throw Exception("Lỗi đăng nhập: ${e.toString()}");
    }
  }

  Future<NguoiDung?> getCurrentUser() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      String uid = currentUser.uid;

      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore.collection("NGUOIDUNG").doc(uid).get();

      if (!userDoc.exists) {
        return null;
      }

      return NguoiDung.fromMap(uid, userDoc.data()!);
    } catch (e) {
      print("Lỗi lấy thông tin người dùng hiện tại: ${e.toString()}");
      return null;
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}