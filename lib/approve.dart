import 'package:flutter/material.dart';
import 'package:pickleball_admin/colors.dart';

class ApproveScreen extends StatelessWidget {
  const ApproveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Duyệt đơn",style: TextStyle(color: AppColors.textColor)),
        backgroundColor: AppColors.Blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildBookingCard(
              title: "Đơn ngày",
              statusColor: Colors.red,
              statusText: "Chưa thanh toán",
              name: "Vy",
              service: "Sân 6",
              time: "18h00 - 20h00 |\nNgày 23/10/2023",
            ),
            const SizedBox(height: 12),
            _buildBookingCard(
              title: "Đơn cố định",
              statusColor: Colors.red,
              statusText: "Chưa thanh toán",
              name: "Vy",
              service: "Sân 2",
              time: "05h00 - 7h00 | \nT3, 5, 7 hàng tuần | Tháng 10",
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.Orange,
        label: const Row(
          children: [
            Icon(Icons.checklist, color: Colors.white),
            SizedBox(width: 8),
            Text("Duyệt đơn", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required String title,
    required Color statusColor,
    required String statusText,
    required String name,
    required String service,
    required String time,
  }) {
    return Card(
      color: AppColors.Blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nhãn trạng thái
            Row(
              children: [
                _buildTag(title, Colors.blue),
                const SizedBox(width: 8),
                _buildTag(statusText, statusColor),
              ],
            ),
            const SizedBox(height: 8),

            // Tên khách hàng
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),

            // Thông tin dịch vụ + Nút XÁC NHẬN
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dịch vụ: $service", style: const TextStyle(color: Colors.white)),
                      Text("Thời gian: $time", style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("XÁC NHẬN", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
