import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'package:pickleball_admin/services/auth.dart';
import 'package:pickleball_admin/views/TrangChu.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  // Controllers cho các trường nhập liệu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Đối tượng AuthService để xử lý đăng nhập
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Xử lý đăng nhập
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Lấy email/sdt và mật khẩu
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Kiểm tra nhập liệu
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'Vui lòng nhập đầy đủ thông tin đăng nhập';
          _isLoading = false;
        });
        return;
      }

      // Gọi hàm đăng nhập từ AuthService
      final user = await _authService.signInWithEmailAndPassword(email, password);

      // Nếu đăng nhập thành công, chuyển đến trang chính
      if (user != null) {
        if (!mounted) return;

        // Sử dụng GetX để điều hướng đến HomeScreen và truyền user
        Get.off(() => HomeScreen(user: user), transition: Transition.fadeIn);
      }
    } catch (e) {
      // Xử lý lỗi đăng nhập
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      // Kết thúc trạng thái loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
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
                  "Quản lý sân thể thao",
                  style: TextStyle(color: AppColors.Blue),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Số điện thoại hoặc email",
                    prefixIcon: Icon(Icons.email, color: AppColors.Blue),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
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
                SizedBox(height: 8),

                // Hiển thị thông báo lỗi nếu có
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.Blue,
                    minimumSize: Size(double.infinity, 50),
                    disabledBackgroundColor: AppColors.Blue.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
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
                    // Xử lý click vào hướng dẫn
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
      ),
    );
  }
}

void main() {
  runApp(GetMaterialApp(
    home: LoginScreen(),
  ));
}