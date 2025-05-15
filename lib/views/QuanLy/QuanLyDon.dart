import 'package:flutter/material.dart';

class QuanLyDonScreen extends StatefulWidget {
  const QuanLyDonScreen({super.key});

  @override
  _QuanLyDonScreenState createState() => _QuanLyDonScreenState();
}

class _QuanLyDonScreenState extends State<QuanLyDonScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> orders = [
    {"name": "Nguyễn Văn A", "date": "2025-03-20", "status": "Chờ xác nhận"},
    {"name": "Trần Thị B", "date": "2025-03-21", "status": "Đã xác nhận"},
    {"name": "Lê Văn C", "date": "2025-03-22", "status": "Đã hủy"},
  ];
  List<Map<String, dynamic>> filteredOrders = [];

  @override
  void initState() {
    super.initState();
    filteredOrders = orders;
  }

  void _filterOrders(String query) {
    setState(() {
      filteredOrders = orders
          .where((order) =>
      order["name"].toLowerCase().contains(query.toLowerCase()) ||
          order["date"].contains(query))
          .toList();
    });
  }

  void _confirmOrder(int index) {
    setState(() {
      filteredOrders[index]["status"] = "Đã xác nhận";
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đơn đã được xác nhận")));
  }

  void _cancelOrder(int index) {
    setState(() {
      filteredOrders[index]["status"] = "Đã hủy";
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đơn đã bị hủy")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý đơn đặt sân"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Ô tìm kiếm
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Tìm kiếm đơn hàng",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _filterOrders,
            ),
            SizedBox(height: 16),

            // Danh sách đơn hàng
            Expanded(
              child: ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  var order = filteredOrders[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orangeAccent,
                        child: Icon(Icons.receipt, color: Colors.white),
                      ),
                      title: Text(order["name"]),
                      subtitle: Text("Ngày đặt: ${order["date"]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (order["status"] == "Chờ xác nhận")
                            IconButton(
                              icon: Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _confirmOrder(index),
                            ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _cancelOrder(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
