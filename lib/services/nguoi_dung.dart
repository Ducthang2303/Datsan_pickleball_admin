import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pickleball_admin/models/nguoi_dung.dart'; // Adjust import path as needed

class NguoiDungService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'NGUOIDUNG'; // Assuming this is your collection name

  // Get all users
  Future<List<NguoiDung>> getAllUsers() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .get();

      List<NguoiDung> users = querySnapshot.docs
          .map((doc) => NguoiDung.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      return users;
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng: $e');
      return [];
    }
  }

  // Get users by role
  Future<List<NguoiDung>> getUsersByRole(String role) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('VAI_TRO', isEqualTo: role)
          .get();

      List<NguoiDung> users = querySnapshot.docs
          .map((doc) => NguoiDung.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      return users;
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng theo vai trò: $e');
      return [];
    }
  }

  // Get user by ID
  Future<NguoiDung?> getUserById(String userId) async {
    try {
      final DocumentSnapshot docSnapshot = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        return NguoiDung.fromMap(
            docSnapshot.id, docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  // Search users by name
  Future<List<NguoiDung>> searchUsersByName(String searchTerm) async {
    try {
      // Convert search term to lowercase for case-insensitive search
      String searchTermLower = searchTerm.toLowerCase();

      // Get all users
      List<NguoiDung> allUsers = await getAllUsers();

      // Filter users whose names contain the search term
      List<NguoiDung> filteredUsers = allUsers
          .where((user) => user.hoTen.toLowerCase().contains(searchTermLower))
          .toList();

      return filteredUsers;
    } catch (e) {
      print('Lỗi khi tìm kiếm người dùng: $e');
      return [];
    }
  }

  // Count users by role
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
      return {};
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .update(data);
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin người dùng: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .delete();
      return true;
    } catch (e) {
      print('Lỗi khi xóa người dùng: $e');
      return false;
    }
  }
}