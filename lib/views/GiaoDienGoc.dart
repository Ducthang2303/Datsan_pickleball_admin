import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickleball_admin/models/nguoi_dung.dart';
import 'package:pickleball_admin/views/TrangChu.dart';
import 'package:pickleball_admin/views/DatDon.dart';
import 'package:pickleball_admin/views/DuyetDon.dart';
import 'package:pickleball_admin/utils/colors.dart';

class DefaultLayout extends StatelessWidget {


  final List<Widget> screens = [
      // Màn hình Home

  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavigationController>(
      init: NavigationController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(controller.getTitle(),style: TextStyle(color: AppColors.textColor),),
            backgroundColor: AppColors.Blue,
          ),
          body: IndexedStack(
            index: controller.currentIndex,
            children: screens,
          ),
          // bottomNavigationBar: BottomNavigationBar(
          //   currentIndex: controller.currentIndex,
          //   backgroundColor: AppColors.Blue,
          //   selectedItemColor: AppColors.Orange,
          //   unselectedItemColor: AppColors.textColor,
          //   onTap: controller.changePage,
          //   items: const [
          //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          //
          //
          //   ],
          // ),
        );
      },
    );
  }
}

// Controller để quản lý trạng thái tab hiện tại
class NavigationController extends GetxController {
  var currentIndex = 0;

  void changePage(int index) {
    currentIndex = index;
    update();
  }

  String getTitle() {
    switch (currentIndex) {
      case 0:
        return "Trang chủ";
      case 1:
        return "Đặt đơn";
      case 2:
        return "Duyệt đơn";
      default:
        return "App";
    }
  }
}
