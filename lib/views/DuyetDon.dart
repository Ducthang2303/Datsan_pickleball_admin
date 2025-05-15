import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pickleball_admin/models/hoa_don.dart';
import 'package:pickleball_admin/models/khu.dart';
import 'package:pickleball_admin/services/hoa_don.dart';
import 'package:pickleball_admin/services/san_khu_service.dart';
import 'package:pickleball_admin/services/nguoi_dung.dart';
import 'package:intl/intl.dart';
import 'package:pickleball_admin/utils/colors.dart';
import 'package:pickleball_admin/services/dat_san.dart';

class DuyetdonScreen extends StatefulWidget {
  const DuyetdonScreen({Key? key}) : super(key: key);

  @override
  _HoaDonListScreenState createState() => _HoaDonListScreenState();
}

class _HoaDonListScreenState extends State<DuyetdonScreen> with SingleTickerProviderStateMixin {
  final HoaDonService _hoaDonService = HoaDonService();
  final SanKhuService _sanKhuService = SanKhuService();
  final NguoiDungService _nguoiDungService = NguoiDungService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<HoaDon> _hoaDonList = [];
  late TabController _tabController;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final dateFormat = DateFormat('dd/MM/yyyy');
  List<Khu> _khuList = [];
  Khu? _selectedKhu;
  DateTime? _selectedDate = DateTime.now(); // Default to current date

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUserKhuAndHoaDon();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchHoaDonList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserKhuAndHoaDon() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      print('Current user: ${user?.uid}');
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

      // Fetch invoices for the selected Khu and date
      await _fetchHoaDonList();
    } catch (e) {
      print('Lỗi khi lấy danh sách khu hoặc hóa đơn: $e');
      setState(() {
        _isLoading = false;
        _hoaDonList = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải dữ liệu. Vui lòng thử lại sau.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchHoaDonList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<HoaDon> result;

      // If no Khu or date is selected, return empty list
      if (_selectedKhu == null || _khuList.isEmpty || _selectedDate == null) {
        setState(() {
          _hoaDonList = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch invoices based on selected tab, Khu, and date
      switch (_tabController.index) {
        case 0: // All invoices
          result = await _hoaDonService.getHoaDonByKhuListAndDate([_selectedKhu!.id], _selectedDate!);
          break;
        case 1: // Pending
          result = await _hoaDonService.getHoaDonByKhuListStatusAndDate(
              [_selectedKhu!.id], 'Chờ xác nhận', _selectedDate!);
          break;
        case 2: // Completed
          result = await _hoaDonService.getHoaDonByKhuListStatusAndDate(
              [_selectedKhu!.id], 'Đã duyệt', _selectedDate!);
          break;
        default:
          result = await _hoaDonService.getHoaDonByKhuListAndDate([_selectedKhu!.id], _selectedDate!);
      }

      setState(() {
        _hoaDonList = result;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi lấy danh sách hóa đơn: $e');
      setState(() {
        _hoaDonList = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải danh sách hóa đơn. Vui lòng thử lại sau.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF0047AB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _fetchHoaDonList();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đã duyệt':
      case 'Đã thanh toán':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Duyệt đơn', style: TextStyle(color: AppColors.textColor)),
        backgroundColor: Color(0xFF0047AB),
      ),
      body: Column(
        children: [
          // Khu and Date selection
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                if (_khuList.isNotEmpty)
                  DropdownButtonFormField<Khu>(
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
                      _fetchHoaDonList();
                    },
                  ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? dateFormat.format(_selectedDate!)

                              : 'Chọn ngày tạo',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        Icon(Icons.calendar_today, color: Color(0xFF0047AB)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
              color: Color(0xFF0047AB),
              child: TabBar(
                labelColor: AppColors.Orange,
                unselectedLabelColor: AppColors.textColor,
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Chờ xác nhận'),
                  Tab(text: 'Đã duyệt'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF0047AB)))
                : RefreshIndicator(
              onRefresh: _fetchUserKhuAndHoaDon,
              child: _hoaDonList.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _khuList.isEmpty
                          ? 'Không có khu nào được phân công'
                          : 'Không có hóa đơn nào trong khu này vào ngày tạo ${_selectedDate != null ? dateFormat.format(_selectedDate!) : ''}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Quay lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0047AB),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _hoaDonList.length,
                itemBuilder: (context, index) {
                  final hoaDon = _hoaDonList[index];
                  final DateTime? createdAt = hoaDon.thoiGianTao;

                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HoaDonDetailScreen(hoaDon: hoaDon),
                          ),
                        ).then((_) => _fetchHoaDonList());
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hoaDon.tenKhu,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0047AB),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Người đặt: ${hoaDon.hoTenNguoiDung}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Ngày: ${hoaDon.khungGio.map((k) => dateFormat.format(DateFormat('yyyy-MM-dd').parse(k.ngay))).join(', ')}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Giờ: ${hoaDon.khungGio.map((k) => '${k.gioBatDau}-${k.gioKetThuc}').join(', ')}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(hoaDon.trangThai).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    hoaDon.trangThai,
                                    style: TextStyle(
                                      color: _getStatusColor(hoaDon.trangThai),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tổng tiền:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  formatCurrency.format(hoaDon.giaTien),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0047AB),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ngày tạo: ${createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt) : 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HoaDonDetailScreen extends StatelessWidget {
  final HoaDon hoaDon;
  final DatSanService _datSanService = DatSanService();
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final dateFormat = DateFormat('dd/MM/yyyy');

  HoaDonDetailScreen({required this.hoaDon});

  Future<void> _acceptBooking(BuildContext context) async {
    final shouldAccept = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận đơn'),
          content: Text('Bạn có chắc chắn muốn xác nhận đơn này không? Hành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Xác nhận'),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ],
        );
      },
    );

    if (shouldAccept == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        bool success = await _datSanService.duyetDonDatSan(hoaDon);

        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã duyệt đơn đặt sân thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể duyệt đơn. Vui lòng thử lại sau.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi duyệt đơn đặt sân: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hủy đơn'),
          content: Text('Bạn có chắc chắn muốn hủy đơn này không? Hành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Hủy'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        bool success = await _datSanService.huyDonDatSan(hoaDon);

        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã hủy đơn đặt sân thành công'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể hủy đơn. Vui lòng thử lại sau.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi hủy đơn đặt sân: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canCancel = hoaDon.trangThai == 'Chờ xác nhận';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết hóa đơn'),
        backgroundColor: Color(0xFF0047AB),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Center(
          child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
              color: _getStatusColor(hoaDon.trangThai),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          hoaDon.trangThai,
          style: TextStyle(
            color: _getStatusColor(hoaDon.trangThai),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),
    SizedBox(height: 24),
    Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Thông tin đặt sân',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0047AB),
    ),
    ),
    SizedBox(height: 16),
    _buildInfoRow('Mã đơn:', hoaDon.id),
    Divider(),
    _buildInfoRow('Sân:', hoaDon.tenSan),
    Divider(),
    _buildInfoRow('Khu:', hoaDon.tenKhu),
    Divider(),
    _buildInfoRow(
    'Ngày:',
    hoaDon.khungGio.map((k) => dateFormat.format(DateFormat('yyyy-MM-dd').parse(k.ngay))).join(', '),
    ),
    Divider(),
    _buildInfoRow(
    'Giờ:',
    hoaDon.khungGio.map((k) => '${k.gioBatDau}-${k.gioKetThuc}').join(', '),
    ),
    Divider(),
    _buildInfoRow('Người đặt:', hoaDon.hoTenNguoiDung),
    Divider(),
    _buildInfoRow('Thành tiền:', formatCurrency.format(hoaDon.giaTien), isHighlighted: true),
    if (hoaDon.thoiGianTao != null) Divider(),
    if (hoaDon.thoiGianTao != null)
    _buildInfoRow(
    'Thời gian tạo:',
    DateFormat('dd/MM/yyyy HH:mm').format(hoaDon.thoiGianTao!),
    ),
    ],
    ),
    ),
    ),
    SizedBox(height: 24),
    if (hoaDon.anhChuyenKhoan != null && hoaDon.anhChuyenKhoan!.isNotEmpty)
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Ảnh chuyển khoản:',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Color(0xFF0047AB),
    ),
    ),
    SizedBox(height: 12),
    GestureDetector(
    onTap: () {
    showDialog(
    context: context,
    builder: (context) => Dialog(
    backgroundColor: Colors.black.withOpacity(0.8),
    insetPadding: EdgeInsets.all(16),
    child: Stack(
    children: [
    InteractiveViewer(
    child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
    hoaDon.anhChuyenKhoan!,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) => Container(
    padding: EdgeInsets.all(16),
    color: Colors.white,
    child: Text('Không thể tải ảnh.'),
    ),
    ),
    ),
    ),
    Positioned(
    top: 8,
    right: 8,
    child: GestureDetector(
    onTap: () => Navigator.of(context).pop(),
    child: CircleAvatar(
    backgroundColor: Colors.white,
    child: Icon(Icons.close, color: Colors.black),
    ),
    ),
    ),
    ],
    ),
    ),
    );
    },
    child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
    hoaDon.anhChuyenKhoan!,
    height: 200,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Text('Không thể tải ảnh.'),
    ),
    ),
    ),
    SizedBox(height: 24),
    ],
    ),
    if (canCancel) ...[
    SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
    onPressed: () => _acceptBooking(context),
    icon: Icon(Icons.check_circle, color: Colors.green),
    label: Text('Xác nhận đơn'),
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.Blue,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    ),
    ),
    SizedBox(height: 12),
    SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
    onPressed: () => _cancelBooking(context),
    icon: Icon(Icons.cancel, color: Colors.red),
    label: Text('Hủy đơn'),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red.withOpacity(0.1),
    foregroundColor: Colors.red,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    ),
    ),
    ],
    ],
    ),
    ),
    ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đã duyệt':
      case 'Đã thanh toán':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? Color(0xFF0047AB) : Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}