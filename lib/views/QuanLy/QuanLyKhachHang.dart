import 'package:flutter/material.dart';
import 'package:pickleball_admin/models/nguoi_dung.dart';
import 'package:pickleball_admin/utils/colors.dart';
import 'package:pickleball_admin/services/nguoi_dung.dart';

class QuanLyKhachHangScreen extends StatefulWidget {
  final String user;

  const QuanLyKhachHangScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<QuanLyKhachHangScreen> createState() => _UsersPageState();
}

class _UsersPageState extends State<QuanLyKhachHangScreen> {
  final NguoiDungService _nguoiDungService = NguoiDungService();
  List<NguoiDung> _users = [];
  List<NguoiDung> _filteredUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _filterUsers();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final users = await _nguoiDungService.getUsersByRole('Người dùng'); // Changed to fetch only users with vaiTro == "user"
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách người dùng: $e';
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = _users;
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredUsers = _users.where((user) {
        return user.hoTen.toLowerCase().contains(query) || user.email.toLowerCase().contains(query);
      }).toList();
    }
    setState(() {});
  }

  Future<void> _toggleLockStatus(NguoiDung user) async {
    final isLocked = user.trangThai == 'locked';
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _nguoiDungService.lockUserAccount(user.id, !isLocked);
      if (success) {
        await _fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLocked ? 'Đã mở khóa tài khoản ${user.hoTen}' : 'Đã khóa tài khoản ${user.hoTen}'),
            backgroundColor: isLocked ? Colors.green : Colors.redAccent,
          ),
        );
      } else {
        throw Exception('Không thể ${isLocked ? "mở khóa" : "khóa"} tài khoản');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(NguoiDung user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _nguoiDungService.deleteUser(user.id);
      if (success) {
        await _fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa tài khoản ${user.hoTen}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Không thể xóa tài khoản');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.Blue,
        elevation: 2,
        title: const Text(
          'Danh Sách Người Dùng',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên hoặc email',
                      prefixIcon: Icon(Icons.search, color: AppColors.Blue),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.Blue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.Blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Thử Lại',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy người dùng',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.Blue,
      onRefresh: _fetchUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          final isLocked = user.trangThai == 'locked';
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.Blue.withOpacity(0.1),
                child: Text(
                  user.hoTen.isNotEmpty ? user.hoTen[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.Blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                user.hoTen,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Vai trò: ${user.vaiTro}${isLocked ? ' (Khóa)' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: isLocked ? Colors.redAccent : Colors.grey[600],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isLocked ? Icons.lock_open : Icons.lock,
                      color: isLocked ? Colors.green : Colors.redAccent,
                      size: 20,
                    ),
                    tooltip: isLocked ? 'Mở khóa' : 'Khóa',
                    onPressed: () => _toggleLockStatus(user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    tooltip: 'Xóa',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: Text('Bạn có chắc muốn xóa tài khoản của "${user.hoTen}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteUser(user);
                              },
                              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailsPage(userId: user.id)));
              },
            ),
          );
        },
      ),
    );
  }
}