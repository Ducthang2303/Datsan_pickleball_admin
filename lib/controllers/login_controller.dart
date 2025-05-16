import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickleball_admin/services/auth.dart';
import 'package:pickleball_admin/views/TrangChu.dart';

class LoginController extends GetxController {
  // Reactive state variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;

  // Text controllers for input fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // AuthService instance
  final AuthService _authService = AuthService();

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Handle login process
  Future<void> handleLogin() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Get email and password
      final email = emailController.text.trim();
      final password = passwordController.text;

      // Validate input
      if (email.isEmpty || password.isEmpty) {
        errorMessage.value = 'Vui lòng nhập đầy đủ thông tin đăng nhập';
        isLoading.value = false;
        return;
      }

      // Perform login
      final user = await _authService.signInWithEmailAndPassword(email, password);

      // Navigate to HomeScreen if login is successful
      if (user != null) {
        Get.off(() => HomeScreen(user: user), transition: Transition.fadeIn);
      }
    } catch (e) {
      // Handle login errors
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }


}