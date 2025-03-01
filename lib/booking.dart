import 'package:flutter/material.dart';
import 'colors.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textColor,
      appBar: AppBar(
        backgroundColor: AppColors.Blue,
        title: Text('Đặt lịch'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.Blue,
                  ),
                  child: Text('CLB cầu lông Cây Đa CN1',style: TextStyle(color: AppColors.textColor) ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.Blue,
                  ),
                  child: Row(
                    children: [
                      Text('15/01/2024',style: TextStyle(color: AppColors.textColor),),
                      SizedBox(width: 5),
                      Icon(Icons.calendar_today, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Đơn ngày', style: TextStyle(color: AppColors.Blue)),

              ),
              TextButton(
                onPressed: () {},
                child: Text('Đơn cố định', style: TextStyle(color: AppColors.Blue)),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Tất cả', style: TextStyle(color: AppColors.Blue)),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                _buildBookingCard('Chi', 'Sân 4: 12h00 - 15h00', '15/01/2024', 'Hoàn thành', Colors.green),
                _buildBookingCard('Kien', 'Sân 3: 17h00 - 18h00', '15/01/2024', 'Hoàn thành', Colors.green),
                _buildBookingCard('Ai', 'Sân 1: 22h01 - Chưa xác định', '15/01/2024', 'Chưa cọc', Colors.red),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text('+ Tạo lịch đặt', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildBookingCard(String name, String details, String date, String status, Color statusColor) {
    return Card(
      color: AppColors.Blue,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('$details | Ngày $date', style: TextStyle(color: Colors.white70)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}