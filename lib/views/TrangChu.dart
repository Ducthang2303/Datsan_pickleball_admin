import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickleball_admin/views/DuyetDon.dart';
import 'package:pickleball_admin/views/QuanLy/QuanLySan.dart';
import 'package:pickleball_admin/views/QuanLy/ThongKe.dart';
import 'package:pickleball_admin/views/QuanLy/QuanLyKhachHang.dart';
import 'package:pickleball_admin/models/nguoi_dung.dart';

class HomeScreen extends StatelessWidget {
  final NguoiDung user; // Type-safe NguoiDung model

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 150,
                  ),
                  Positioned(
                    top: 50,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/logo.jpg'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Sân pickleball quản lý',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15), // Removed redundant padding widget
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(12),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    _buildGridItem(
                      'Quản lý sân',
                      Icons.grid_on,
                      Colors.orange,
                          () => _navigateToScreen(QuanLySanScreen(userId: user.id)),
                    ),
                    _buildGridItem(
                      'Thống kê',
                      Icons.bar_chart,
                      Colors.pinkAccent,
                          () => _navigateToScreen(const ThongKeDoanhThuScreen()),
                    ),
                    _buildGridItem(
                      'Quản lý khách hàng',
                      Icons.people,
                      Colors.blueAccent,
                          () => _navigateToScreen(QuanLyKhachHangScreen(user: user.id)),
                    ),
                    _buildGridItem(
                      'Duyệt đơn',
                      Icons.calendar_today,
                      Colors.deepPurpleAccent,
                          () => _navigateToScreen(const DuyetdonScreen()), // Updated to match new constructor
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Get.to(() => screen, transition: Transition.fadeIn);
  }

  Widget _buildGridItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}