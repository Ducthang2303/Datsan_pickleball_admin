import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pickleball_admin/services/thong_ke.dart';
import 'package:pickleball_admin/models/khu.dart';
import 'package:pickleball_admin/services/san_khu_service.dart';
import 'package:pickleball_admin/utils/colors.dart';

class ThongKeDoanhThuScreen extends StatefulWidget {
  const ThongKeDoanhThuScreen({Key? key}) : super(key: key);

  @override
  State<ThongKeDoanhThuScreen> createState() => _ThongKeDoanhThuScreenState();
}

class _ThongKeDoanhThuScreenState extends State<ThongKeDoanhThuScreen> {
  final DoanhThuThongKeService _thongKeService = DoanhThuThongKeService();
  final SanKhuService _sanKhuService = SanKhuService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  double _tongDoanhThu = 0;
  int _tongDonHang = 0;
  Map<int, double> _doanhThuTheoNgay = {};
  List<Khu> _khuList = [];
  Khu? _selectedKhu;

  // Biến để lưu tháng và năm hiện tại
  late int _thang;
  late int _nam;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _thang = now.month;
    _nam = now.year;
    _loadKhuAndData();
  }

  // Định dạng tiền VND
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  Future<void> _loadKhuAndData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không tìm thấy người dùng. Vui lòng đăng nhập lại.');
      }
      final userId = user.uid;

      // Fetch Khu list for the user
      _khuList = await _sanKhuService.getKhuByUserId(userId);
      print('Fetched khuList: ${_khuList.map((k) => k.id).toList()}');

      // Set default selected Khu
      if (_khuList.isNotEmpty) {
        _selectedKhu = _khuList.first;
      }

      // Load statistics data
      await _loadData();
    } catch (e) {
      print('Lỗi khi tải danh sách khu hoặc dữ liệu thống kê: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi tải dữ liệu')),
      );
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      print('Loaded doanh thu: $_tongDoanhThu');
    });

    try {
      // If no Khu is selected, reset data
      if (_selectedKhu == null) {
        setState(() {
          _tongDoanhThu = 0;
          _tongDonHang = 0;
          _doanhThuTheoNgay = {};
          _isLoading = false;
        });
        return;
      }

      // Lấy doanh thu tháng
      final doanhThu = await _thongKeService.getDoanhThuTheoThang(_thang, _nam, maKhu: _selectedKhu!.id);

      // Lấy số lượng đơn hàng đã duyệt
      final tongDonHang =
      await _thongKeService.getTongSoHoaDonDaDuyetTrongThang(_thang, _nam, maKhu: _selectedKhu!.id);

      // Lấy doanh thu theo ngày
      final doanhThuNgay =
      await _thongKeService.getDoanhThuTheoNgayTrongThang(_thang, _nam, maKhu: _selectedKhu!.id);

      setState(() {
        _tongDoanhThu = doanhThu;
        _tongDonHang = tongDonHang;
        _doanhThuTheoNgay = doanhThuNgay;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu thống kê: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi tải dữ liệu thống kê')),
      );
    }
  }

  void _thayDoiThang(int thang, int nam) {
    setState(() {
      _thang = thang;
      _nam = nam;
    });
    _loadData();
  }

  void _showThangPicker() {
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
                      value: _thang,
                      items: List.generate(12, (index) => index + 1)
                          .map((month) => DropdownMenuItem<int>(
                        value: month,
                        child: Text('Tháng $month'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _thang = value;
                          });
                        }
                      },
                    ),
                    DropdownButton<int>(
                      value: _nam,
                      items: List.generate(5, (index) => DateTime.now().year - 2 + index)
                          .map((year) => DropdownMenuItem<int>(
                        value: year,
                        child: Text('$year'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _nam = value;
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
                _thayDoiThang(_thang, _nam);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.Blue,
        title: Text('Thống kê doanh thu',style: TextStyle(color: AppColors.textColor)),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            color: AppColors.textColor,
            onPressed: _showThangPicker,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadKhuAndData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown chọn khu
              if (_khuList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<Khu>(
                    value: _selectedKhu,
                    decoration: InputDecoration(
                      labelText: 'Chọn khu',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _khuList.map((Khu khu) {
                      return DropdownMenuItem<Khu>(
                        value: khu,
                        child: Text(khu.ten),
                      );
                    }).toList(),
                    onChanged: (Khu? newKhu) {
                      setState(() {
                        _selectedKhu = newKhu;
                      });
                      _loadData();
                    },
                  ),
                ),
              // Tiêu đề tháng hiện tại
              Center(
                child: Text(
                  'Thống kê tháng $_thang/$_nam${_selectedKhu != null ? ' - ${ _selectedKhu!.ten}' : ''}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Thông báo nếu không có khu
              if (_khuList.isEmpty)
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
                        'Không có khu nào được phân công',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                        label: Text('Quay lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Card hiển thị tổng doanh thu
              if (_khuList.isNotEmpty)
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
                          formatCurrency.format(_tongDoanhThu),
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
                              '$_tongDonHang đơn hàng đã duyệt',
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
              if (_khuList.isNotEmpty) SizedBox(height: 24),

              // Tiêu đề biểu đồ
              if (_khuList.isNotEmpty)
                Text(
                  'Doanh thu theo ngày',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              if (_khuList.isNotEmpty) SizedBox(height: 16),

              // Biểu đồ doanh thu theo ngày sử dụng fl_chart
              if (_khuList.isNotEmpty)
                _doanhThuTheoNgay.isNotEmpty
                    ? Container(
                  height: 300,
                  padding: EdgeInsets.only(right: 20, top: 20),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _findMaxDoanhThuNgay() * 2,
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
                                _formatCurrencyShort(value),
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
                        horizontalInterval: _findMaxDoanhThuNgay() / 5,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 1),
                          left: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      barGroups: _getBarGroups(),
                    ),
                  ),
                )
                    : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Không có dữ liệu doanh thu trong tháng này cho khu ${_selectedKhu!.ten}',
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
  }

  // Hỗ trợ cho biểu đồ

  // Tìm doanh thu cao nhất cho việc scale biểu đồ
  double _findMaxDoanhThuNgay() {
    double max = 0;
    _doanhThuTheoNgay.forEach((ngay, doanhThu) {
      if (doanhThu > max) {
        max = doanhThu;
      }
    });
    return max > 0 ? max : 1000000; // Giá trị mặc định nếu không có doanh thu
  }

  // Định dạng tiền tệ ngắn gọn cho trục Y
  String _formatCurrencyShort(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  // Tạo dữ liệu cho biểu đồ cột
  List<BarChartGroupData> _getBarGroups() {
    List<BarChartGroupData> barGroups = [];

    // Sắp xếp các ngày theo thứ tự tăng dần
    List<int> sortedDays = _doanhThuTheoNgay.keys.toList()..sort();

    for (int i = 0; i < sortedDays.length; i++) {
      int ngay = sortedDays[i];
      double doanhThu = _doanhThuTheoNgay[ngay] ?? 0;

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