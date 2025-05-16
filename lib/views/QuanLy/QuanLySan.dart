import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pickleball_admin/utils/colors.dart';
import 'package:pickleball_admin/models/khu.dart';
import 'package:pickleball_admin/models/san.dart';
import 'package:pickleball_admin/models/san_khunggio.dart';
import 'package:pickleball_admin/models/khung_gio.dart';
import 'package:provider/provider.dart';
import 'package:pickleball_admin/controllers/san_controller.dart';

class QuanLySanScreen extends StatelessWidget {
  final String userId;
  const QuanLySanScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SanController(userId),
      child: Consumer<SanController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Quản lý sân",
                style: TextStyle(color: AppColors.textColor),
              ),
              backgroundColor: AppColors.Blue,
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ngày: ${DateFormat('dd/MM/yyyy').format(controller.selectedDate)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.Blue,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => controller.selectDate(context),
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text("Chọn ngày"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.Blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ExpansionTile(
                      title: Text(
                        controller.selectedKhuMa != null
                            ? controller.danhSachKhu
                            .firstWhere((khu) => khu.ma == controller.selectedKhuMa)
                            .ten
                            : "Chọn khu",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.selectedKhuMa != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      trailing: Icon(
                        controller.expandedKhu ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                      ),
                      initiallyExpanded: false,
                      onExpansionChanged: (expanded) {
                        controller.expandedKhu = expanded;
                        controller.notifyListeners();
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: controller.danhSachKhu.map((khu) {
                              return Container(
                                color: controller.selectedKhuMa == khu.ma
                                    ? AppColors.Blue
                                    : Colors.transparent,
                                child: ListTile(
                                  title: Text(
                                    khu.ten,
                                    style: TextStyle(
                                      color: controller.selectedKhuMa == khu.ma
                                          ? AppColors.textColor
                                          : Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    controller.selectedKhuMa = khu.ma;
                                    controller.expandedKhu = false;
                                    controller.fetchSanVaKhungGio(khu.ma);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (controller.selectedKhuMa != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Danh sách sân",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, color: AppColors.textColor, size: 18),
                          label: const Text(
                            "Thêm sân",
                            style: TextStyle(color: AppColors.textColor),
                          ),
                          onPressed: () => _showAddSanDialog(context, controller),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.Blue,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.danhSachSan.length,
                      itemBuilder: (context, index) {
                        San san = controller.danhSachSan[index];
                        List<SanKhungGio> lichSanList = controller.danhSachKhungGio
                            .where((lich) => lich.maSan == san.ma)
                            .toList();
                        return Card(
                          color: AppColors.Blue,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Icon(
                                  san.trangThai ? Icons.check_circle : Icons.cancel,
                                  color: san.trangThai ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(san.ten, style: TextStyle(color: AppColors.textColor))),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    san.trangThai ? Icons.toggle_on : Icons.toggle_off,
                                    color: san.trangThai ? Colors.green : Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await controller.toggleSanStatus(san);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đã cập nhật trạng thái sân thành ${san.trangThai ? "hoạt động" : "ngưng hoạt động"}',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('$e')),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: Colors.red,
                                  onPressed: () => _showDeleteConfirmDialog(context, controller, san),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ngày: ${DateFormat('dd/MM/yyyy').format(controller.selectedDate)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: AppColors.textColor),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            await controller.addAllKhungGioForSan(san);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Thêm khung giờ thành công')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('$e')),
                                            );
                                          }
                                        },
                                        child: const Text("Thêm tất cả khung giờ",
                                            style: TextStyle(color: AppColors.Black)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                              if (lichSanList.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      "Chưa có khung giờ nào cho sân này",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              else
                                ...lichSanList.map((sanKhungGio) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            double itemWidth = 90;
                                            int crossAxisCount = (constraints.maxWidth / itemWidth).floor();
                                            crossAxisCount = crossAxisCount < 2 ? 2 : crossAxisCount;

                                            return GridView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                childAspectRatio: 1.2,
                                                crossAxisSpacing: 8,
                                                mainAxisSpacing: 8,
                                              ),
                                              itemCount: sanKhungGio.khungGio.length,
                                              itemBuilder: (context, idx) {
                                                KhungGio khungGio = sanKhungGio.khungGio[idx];
                                                return InkWell(
                                                  onTap: khungGio.trangThai != 1
                                                      ? () async {
                                                    try {
                                                      await controller.toggleKhungGioStatus(
                                                          sanKhungGio, idx);
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('$e')),
                                                      );
                                                    }
                                                  }
                                                      : null,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: controller.getStatusBackgroundColor(khungGio.trangThai),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color: controller.getStatusColor(khungGio.trangThai),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.all(8),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Center(
                                                            child: Text(
                                                              "${khungGio.gioBatDau}\n${khungGio.gioKetThuc}",
                                                              textAlign: TextAlign.center,
                                                              style:
                                                              const TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          controller.getStatusIcon(khungGio.trangThai),
                                                          color: controller.getStatusColor(khungGio.trangThai),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 16,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                                const SizedBox(width: 4),
                                                Text("Hoạt động", style: TextStyle(color: AppColors.textColor)),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.event_busy, color: Colors.orange, size: 16),
                                                const SizedBox(width: 4),
                                                Text("Đã đặt", style: TextStyle(color: AppColors.textColor)),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.cancel, color: Colors.red, size: 16),
                                                const SizedBox(width: 4),
                                                Text("Khóa", style: TextStyle(color: AppColors.textColor)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddSanDialog(BuildContext context, SanController controller) async {
    final TextEditingController maController = TextEditingController();
    final TextEditingController tenController = TextEditingController();
    String? selectedKhu = controller.selectedKhuMa;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: Colors.white,
            primaryColor: AppColors.Blue,
            hintColor: AppColors.Blue,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.Blue,
              ),
            ),
          ),
          child: AlertDialog(
            title: const Text('Thêm sân mới', style: TextStyle(color: Colors.black)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Khu',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.Blue, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    value: selectedKhu,
                    items: controller.danhSachKhu.map((Khu khu) {
                      return DropdownMenuItem<String>(
                        value: khu.ma,
                        child: Text(khu.ten),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      selectedKhu = newValue;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: maController,
                    cursorColor: AppColors.Blue,
                    decoration: InputDecoration(
                      labelText: 'Mã sân',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.Blue, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: tenController,
                    cursorColor: AppColors.Blue,
                    decoration: InputDecoration(
                      labelText: 'Tên sân',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.Blue, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Hủy'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Thêm'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.Blue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () async {
                  if (maController.text.isEmpty || tenController.text.isEmpty || selectedKhu == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                    );
                    return;
                  }

                  San newSan = San(
                    id: '',
                    ma: maController.text,
                    maKhu: selectedKhu!,
                    ten: tenController.text,
                    trangThai: true,
                  );

                  try {
                    await controller.addSan(newSan);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm sân thành công')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$e')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, SanController controller, San san) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa sân "${san.ten}" không?'),
                const SizedBox(height: 8),
                const Text(
                  'Lưu ý: Tất cả khung giờ liên quan đến sân này cũng sẽ bị xóa.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await controller.deleteSan(san);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa sân thành công')),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}