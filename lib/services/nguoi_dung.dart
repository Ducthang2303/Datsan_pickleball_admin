import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pickleball_admin/models/nguoi_dung.dart';

class NguoiDungService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'NGUOIDUNG';

  Future<List<NguoiDung>> getAllUsers() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => NguoiDung.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng: $e');
      rethrow;
    }
  }

  Future<List<NguoiDung>> getUsersByRole(String role) async {
    try {
      final QuerySnapshot querySnapshot =
      await _firestore.collection(_collection).where('VAI_TRO', isEqualTo: role).get();
      return querySnapshot.docs
          .map((doc) => NguoiDung.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng theo vai trò: $e');
      rethrow;
    }
  }

  Future<NguoiDung?> getUserById(String userId) async {
    try {
      final DocumentSnapshot docSnapshot =
      await _firestore.collection(_collection).doc(userId).get();
      if (docSnapshot.exists) {
        return NguoiDung.fromMap(docSnapshot.id, docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      rethrow;
    }
  }

  Future<List<NguoiDung>> searchUsersByName(String searchTerm) async {
    try {
      String searchTermLower = searchTerm.toLowerCase();
      List<NguoiDung> allUsers = await getAllUsers();
      return allUsers.where((user) => user.hoTen.toLowerCase().contains(searchTermLower)).toList();
    } catch (e) {
      print('Lỗi khi tìm kiếm người dùng: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> countUsersByRole() async {
    try {
      List<NguoiDung> allUsers = await getAllUsers();
      Map<String, int> roleCounts = {};
      for (var user in allUsers) {
        roleCounts[user.vaiTro] = (roleCounts[user.vaiTro] ?? 0) + 1;
      }
      return roleCounts;
    } catch (e) {
      print('Lỗi khi đếm người dùng theo vai trò: $e');
      rethrow;
    }
  }

  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(data);
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin người dùng: $e');
      return false;
    }
  }

  Future<bool> lockUserAccount(String userId, bool lock) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .update({'TRANG_THAI': lock ? 'locked' : 'active'});
      return true;
    } catch (e) {
      print('Lỗi khi ${lock ? "khóa" : "mở khóa"} tài khoản: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
      return true;
    } catch (e) {
      print('Lỗi khi xóa người dùng: $e');
      return false;
    }
  }
}