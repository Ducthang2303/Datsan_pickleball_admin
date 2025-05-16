import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickleball_admin/utils/colors.dart';
import 'package:pickleball_admin/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final LoginController controller = Get.put(LoginController());

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
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Số điện thoại hoặc email",
                    prefixIcon: Icon(Icons.email, color: AppColors.Blue),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Obx(
                      () => TextField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      prefixIcon: Icon(Icons.lock, color: AppColors.Blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.Blue,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Display error message
                Obx(
                      () => controller.errorMessage.value.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : SizedBox.shrink(),
                ),
                SizedBox(height: 16),
                Obx(
                      () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Blue,
                      minimumSize: Size(double.infinity, 50),
                      disabledBackgroundColor: AppColors.Blue.withOpacity(0.5),
                    ),
                    child: controller.isLoading.value
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
                ),
                SizedBox(height: 16),

                SizedBox(height: 16),

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