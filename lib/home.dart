import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'), // Đặt hình nền toàn bộ
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 40), // Thêm khoảng trống để tránh tràn vào status bar
            Stack(
              children: [
                Container(
                  height: 200,
                ),
                Positioned(
                  top: 100,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/logo.jpg'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Sân pickleball quản lý',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Chữ trắng nổi bật trên nền
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(16),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildGridItem('Quản lý sân', Icons.grid_on, Colors.orange),
                  _buildGridItem('Thống kê', Icons.bar_chart, Colors.pinkAccent),
                  _buildGridItem('Quản lý khách hàng', Icons.people, Colors.blueAccent),
                  _buildGridItem('Quản lý đơn tháng', Icons.calendar_today, Colors.deepPurpleAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(String title, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.8), // Làm màu nhẹ để nhìn rõ chữ
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
