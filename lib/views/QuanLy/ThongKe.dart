import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pickleball_admin/models/khu.dart';
import 'package:pickleball_admin/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:pickleball_admin/controllers/thong_ke_doanh_thu_controller.dart';

class ThongKeDoanhThuScreen extends StatefulWidget {
  const ThongKeDoanhThuScreen({Key? key}) : super(key: key);

  @override
  State<ThongKeDoanhThuScreen> createState() => _ThongKeDoanhThuScreenState();
}

class _ThongKeDoanhThuScreenState extends State<ThongKeDoanhThuScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThongKeDoanhThuController(),
      child: Consumer<ThongKeDoanhThuController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.Blue,
              title: Text('Thống kê doanh thu', style: TextStyle(color: AppColors.textColor,fontWeight: FontWeight.w600,)),
              actions: [
                IconButton(
                  icon: Icon(Icons.calendar_month),
                  color: AppColors.textColor,
                  onPressed: () => _showThangPicker(context, controller),
                ),
              ],
            ),
            body: controller.isLoading
                ? Center(child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(AppColors.Blue),))
                : RefreshIndicator(
              onRefresh: controller.refreshData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown chọn khu
                    if (controller.khuList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DropdownButtonFormField<Khu>(
                          value: controller.selectedKhu,
                          decoration: InputDecoration(
                            labelText: 'Chọn khu',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: controller.khuList.map((Khu khu) {
                            return DropdownMenuItem<Khu>(
                              value: khu,
                              child: Text(khu.ten),
                            );
                          }).toList(),
                          onChanged: (Khu? newKhu) {
                            controller.selectKhu(newKhu);
                          },
                        ),
                      ),
                    // Tiêu đề tháng hiện tại
                    Center(
                      child: Text(
                        'Thống kê tháng ${controller.thang}/${controller.nam}${controller.selectedKhu != null ? ' - ${controller.selectedKhu!.ten}' : ''}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Thông báo nếu không có khu hoặc lỗi
                    if (controller.errorMessage != null)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              controller.errorMessage!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: controller.refreshData,
                              icon: Icon(Icons.refresh),
                              label: Text('Thử lại'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Card hiển thị tổng doanh thu
                    if (controller.khuList.isNotEmpty && controller.errorMessage == null)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.blue[50],
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Tổng doanh thu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[800],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                controller.formatCurrency.format(controller.tongDoanhThu),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt, color: Colors.blue[800]),
                                  SizedBox(width: 8),
                                  Text(
                                    '${controller.tongDonHang} đơn hàng đã duyệt',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (controller.khuList.isNotEmpty && controller.errorMessage == null)
                      SizedBox(height: 24),

                    // Tiêu đề biểu đồ
                    if (controller.khuList.isNotEmpty && controller.errorMessage == null)
                      Text(
                        'Doanh thu theo ngày',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    if (controller.khuList.isNotEmpty && controller.errorMessage == null)
                      SizedBox(height: 16),

                    // Biểu đồ doanh thu theo ngày sử dụng fl_chart
                    if (controller.khuList.isNotEmpty && controller.errorMessage == null)
                      controller.doanhThuTheoNgay.isNotEmpty
                          ? Container(
                        height: 300,
                        padding: EdgeInsets.only(right: 20, top: 20),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: controller.findMaxDoanhThuNgay() * 2,
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int ngay = value.toInt();
                                    // Chỉ hiển thị cách 3 ngày một lần để tránh chồng chéo
                                    if (ngay % 3 != 0) return Container();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        '$ngay',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  },
                                  reservedSize: 28,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 80,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      controller.formatCurrencyShort(value),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              horizontalInterval: controller.findMaxDoanhThuNgay() / 5,
                              drawVerticalLine: false,
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey, width: 1),
                                left: BorderSide(color: Colors.grey, width: 1),
                              ),
                            ),
                            barGroups: _getBarGroups(controller),
                          ),
                        ),
                      )
                          : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Không có dữ liệu doanh thu trong tháng này cho khu ${controller.selectedKhu!.ten}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showThangPicker(BuildContext context, ThongKeDoanhThuController controller) {
    int tempThang = controller.thang;
    int tempNam = controller.nam;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn tháng'),
          content: Container(
            width: double.maxFinite,
            height: 130,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<int>(
                      value: tempThang,
                      items: List.generate(12, (index) => index + 1)
                          .map((month) => DropdownMenuItem<int>(
                        value: month,
                        child: Text('Tháng $month'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            tempThang = value;
                          });
                        }
                      },
                    ),
                    DropdownButton<int>(
                      value: tempNam,
                      items: List.generate(5, (index) => DateTime.now().year - 2 + index)
                          .map((year) => DropdownMenuItem<int>(
                        value: year,
                        child: Text('$year'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            tempNam = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xác nhận'),
              onPressed: () {
                Navigator.of(context).pop();
                controller.thayDoiThang(tempThang, tempNam);
              },
            ),
          ],
        );
      },
    );
  }

  // Tạo dữ liệu cho biểu đồ cột
  List<BarChartGroupData> _getBarGroups(ThongKeDoanhThuController controller) {
    List<BarChartGroupData> barGroups = [];

    // Sắp xếp các ngày theo thứ tự tăng dần
    List<int> sortedDays = controller.doanhThuTheoNgay.keys.toList()..sort();

    for (int i = 0; i < sortedDays.length; i++) {
      int ngay = sortedDays[i];
      double doanhThu = controller.doanhThuTheoNgay[ngay] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: ngay,
          barRods: [
            BarChartRodData(
              toY: doanhThu,
              color: Colors.blue,
              width: 12,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }
}