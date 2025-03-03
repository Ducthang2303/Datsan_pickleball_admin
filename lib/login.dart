import 'package:flutter/material.dart';
import 'colors.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Đăng nhập - Chủ sân",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.Blue,
                ),
              ),
              SizedBox(height: 8),
              Text(
                " Quản lý sân thể thao",
                style: TextStyle(color: AppColors.Blue),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "Số điện thoại hoặc email",
                  prefixIcon: Icon(Icons.email, color: AppColors.Blue),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: Icon(Icons.lock, color: AppColors.Blue),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.Blue,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.Blue,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "ĐĂNG NHẬP",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Chuyển hướng tải app khách chơi
                },
                child: Text(
                  "Nếu bạn là KHÁCH CHƠI, vui lòng tải ứng dụng Tìm kiếm và đặt lịch",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {

                },
                child: Text(
                  "Bạn chưa có tài khoản? Xem hướng dẫn",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}
