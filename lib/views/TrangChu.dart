import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickleball_admin/views/DuyetDon.dart';
import 'package:pickleball_admin/views/QuanLy/QuanLySan.dart';
import 'package:pickleball_admin/views/QuanLy/ThongKe.dart';
import 'package:pickleball_admin/views/QuanLy/QuanLyKhachHang.dart';
import 'package:pickleball_admin/models/nguoi_dung.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:pickleball_admin/utils/colors.dart';

class HomeScreen extends StatelessWidget {
  final NguoiDung user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Ensure no white background
      body: Container(
        width: double.infinity, // Full width
        height: double.infinity, // Full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.Blue, // Blue
              AppColors.Blue, // Pink
            ],
          ),
        ),
        child: SafeArea(
          left: true,
          right: true,
          top: true,
          bottom: false, // Allow content to extend to bottom
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildGrid(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/logo.jpg'),
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          SizedBox(height: 12),
          Text(
            'Pickleball Admin',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Welcome, ${user.hoTen ?? "Admin"}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _buildGridItem(
            context,
            'Quản lý sân',
            Icons.grid_on,
            Color(0xFFFFB300), // Amber
                () => Get.to(() => QuanLySanScreen(userId: user.id), transition: Transition.zoom),
          ),
          _buildGridItem(
            context,
            'Thống kê',
            Icons.bar_chart,
            Color(0xFFEF5350), // Red
                () => Get.to(() => ThongKeDoanhThuScreen(), transition: Transition.zoom),
          ),
          _buildGridItem(
            context,
            'Quản lý khách hàng',
            Icons.people,
            Color(0xFF42A5F5), // Blue
                () => Get.to(() => QuanLyKhachHangScreen(user: user.id), transition: Transition.zoom),
          ),
          _buildGridItem(
            context,
            'Duyệt đơn',
            Icons.calendar_today,
            Color(0xFFAB47BC), // Purple
                () => Get.to(() => DuyetdonScreen(), transition: Transition.zoom),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: MediaQuery.of(context).size.width * 0.42,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: color,
                  ),
                  SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.Black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}