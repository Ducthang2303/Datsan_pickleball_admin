import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickleball_admin/services/auth.dart';
import 'package:pickleball_admin/views/TrangChu.dart';

class LoginController extends GetxController {

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }


  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> handleLogin() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        errorMessage.value = 'Vui lòng nhập đầy đủ thông tin đăng nhập';
        isLoading.value = false;
        return;
      }
      final user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        Get.off(() => HomeScreen(user: user), transition: Transition.fadeIn);
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }


}