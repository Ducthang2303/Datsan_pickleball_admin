import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pickleball_admin/utils/colors.dart';
import 'package:pickleball_admin/models/khu.dart';
import 'package:pickleball_admin/models/san.dart';
import 'package:pickleball_admin/models/san_khunggio.dart';
import 'package:pickleball_admin/models/khung_gio.dart';
import 'package:pickleball_admin/services/san_khu_service.dart';

class QuanLySanScreen extends StatefulWidget {
  final String userId;
  const QuanLySanScreen({super.key, required this.userId,});

  @override
  _QuanLySanScreenState createState() => _QuanLySanScreenState();
}

class _QuanLySanScreenState extends State<QuanLySanScreen> {
  final SanKhuService _sanKhuService = SanKhuService();

  List<Khu> danhSachKhu = [];
  List<San> danhSachSan = [];
  List<SanKhungGio> danhSachKhungGio = [];

  String? selectedKhuMa;
  DateTime selectedDate = DateTime.now();
  String ngayHienTai = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _expandedKhu = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchKhu();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.Blue,
            colorScheme: ColorScheme.light(
              primary: AppColors.Blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.Blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        ngayHienTai = DateFormat('yyyy-MM-dd').format(selectedDate);
      });

      if (selectedKhuMa != null) {
        await _fetchSanVaKhungGio(selectedKhuMa!);
      }
    }
  }

  Future<void> _fetchKhu() async {
    setState(() => _isLoading = true);
    try {
      danhSachKhu = await _sanKhuService.getKhuByUserId(widget.userId);
      if (danhSachKhu.isNotEmpty && selectedKhuMa == null) {
        selectedKhuMa = danhSachKhu.first.ma;
        await _fetchSanVaKhungGio(selectedKhuMa!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách khu: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchSanVaKhungGio(String maKhu) async {
    setState(() => _isLoading = true);
    try {
      danhSachSan = await _sanKhuService.getSanByKhu(maKhu);
      danhSachKhungGio = [];

      if (danhSachSan.isNotEmpty) {
        final khungGioFutures = danhSachSan.map(
              (san) => _sanKhuService.getKhungGioBySan(san.ma, ngayHienTai),
        ).toList();

        final List<List<SanKhungGio>> khungGioResults = await Future.wait(khungGioFutures);
        danhSachKhungGio = khungGioResults.expand((list) => list).toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu sân: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addAllKhungGioForSan(San san) async {
    setState(() => _isLoading = true);
    try {
      await _sanKhuService.addAllKhungGioForSan(san.ma, ngayHienTai);
      await _fetchSanVaKhungGio(selectedKhuMa!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm khung giờ thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm khung giờ: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleKhungGioStatus(SanKhungGio sanKhungGio, int khungGioIndex) async {
    KhungGio khungGio = sanKhungGio.khungGio[khungGioIndex];
    if (khungGio.trangThai == 1) return;

    int newStatus = khungGio.trangThai == 0 ? 2 : 0;

    setState(() {
      sanKhungGio.khungGio[khungGioIndex].trangThai = newStatus;
    });

    try {
      await _sanKhuService.updateKhungGioStatus(
        sanKhungGio.maSan,
        ngayHienTai,
        khungGioIndex,
        newStatus,
      );
    } catch (e) {
      setState(() {
        sanKhungGio.khungGio[khungGioIndex].trangThai = khungGio.trangThai;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
      );
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: return Colors.green;
      case 1: return Colors.orange;
      case 2: return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor(int status) {
    switch (status) {
      case 0: return Colors.green.shade100;
      case 1: return Colors.orange.shade100;
      case 2: return Colors.red.shade100;
      default: return Colors.grey.shade100;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0: return Icons.check_circle;
      case 1: return Icons.event_busy;
      case 2: return Icons.cancel;
      default: return Icons.help;
    }
  }

  Future<void> _showAddSanDialog() async {
    final TextEditingController maController = TextEditingController();
    final TextEditingController tenController = TextEditingController();
    String? selectedKhu = selectedKhuMa;

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
            title: Text('Thêm sân mới', style: TextStyle(color: Colors.black)),
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
                    items: danhSachKhu.map((Khu khu) {
                      return DropdownMenuItem<String>(
                        value: khu.ma,
                        child: Text(khu.ten),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      selectedKhu = newValue;
                    },
                  ),
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
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
                child: Text('Hủy'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Thêm'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.Blue,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () async {
                  if (maController.text.isEmpty ||
                      tenController.text.isEmpty ||
                      selectedKhu == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
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

                  setState(() => _isLoading = true);
                  try {
                    String? sanId = await _sanKhuService.addSan(newSan);
                    if (sanId != null) {
                      await _fetchSanVaKhungGio(selectedKhuMa!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Thêm sân thành công')),
                      );
                    } else {
                      throw Exception('Failed to add court');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thêm sân thất bại: $e')),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(San san) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa sân "${san.ten}" không?'),
                SizedBox(height: 8),
                Text(
                  'Lưu ý: Tất cả khung giờ liên quan đến sân này cũng sẽ bị xóa.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  bool success = await _sanKhuService.deleteSan(san.id);
                  if (success) {
                    await _fetchSanVaKhungGio(selectedKhuMa!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xóa sân thành công')),
                    );
                  } else {
                    throw Exception('Failed to delete court');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xóa sân thất bại: $e')),
                  );
                } finally {
                  setState(() => _isLoading = false);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleSanStatus(San san) async {
    bool newStatus = !san.trangThai;

    setState(() {
      san.trangThai = newStatus;
    });

    try {
      bool success = await _sanKhuService.updateSanStatus(san.id, newStatus);
      if (!success) {
        throw Exception('Failed to update court status');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã cập nhật trạng thái sân thành ${newStatus ? "hoạt động" : "ngưng hoạt động"}',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        san.trangThai = !newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái sân thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quản lý sân",
          style: TextStyle(color: AppColors.textColor),
        ),
        backgroundColor: AppColors.Blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
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
                    "Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.Blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.calendar_today, size: 18),
                    label: Text("Chọn ngày"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ExpansionTile(
                title: Text(
                  selectedKhuMa != null
                      ? danhSachKhu.firstWhere((khu) => khu.ma == selectedKhuMa).ten
                      : "Chọn khu",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedKhuMa != null ? Colors.black : Colors.grey,
                  ),
                ),
                trailing: Icon(
                  _expandedKhu ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
                initiallyExpanded: false,
                onExpansionChanged: (expanded) {
                  setState(() => _expandedKhu = expanded);
                },
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: danhSachKhu.map((khu) => Container(
                        color: selectedKhuMa == khu.ma ? AppColors.Blue : Colors.transparent,
                        child: ListTile(
                          title: Text(
                            khu.ten,
                            style: TextStyle(
                              color: selectedKhuMa == khu.ma ? AppColors.textColor : Colors.black,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedKhuMa = khu.ma;
                              _expandedKhu = false;
                            });
                            _fetchSanVaKhungGio(khu.ma);
                          },
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (selectedKhuMa != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Danh sách sân",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add, color: AppColors.textColor, size: 18),
                    label: Text(
                      "Thêm sân",
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    onPressed: _showAddSanDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Blue,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: danhSachSan.length,
                itemBuilder: (context, index) {
                  San san = danhSachSan[index];
                  List<SanKhungGio> lichSanList = danhSachKhungGio
                      .where((lich) => lich.maSan == san.ma)
                      .toList();
                  return Card(
                    color: AppColors.Blue,
                    margin: EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Icon(
                            san.trangThai ? Icons.check_circle : Icons.cancel,
                            color: san.trangThai ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(child: Text(san.ten, style: TextStyle(color: AppColors.textColor))),
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
                            onPressed: () => _toggleSanStatus(san),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 20),
                            color: Colors.red,
                            onPressed: () => _showDeleteConfirmDialog(san),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor),
                              ),
                              SizedBox(height: 12),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () => _addAllKhungGioForSan(san),
                                  child: Text("Thêm tất cả khung giờ", style: TextStyle(color: AppColors.Black)),
                                ),
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                        if (lichSanList.isEmpty)
                          Padding(
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
                              padding: EdgeInsets.all(8.0),
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
                                        physics: NeverScrollableScrollPhysics(),
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
                                                ? () => _toggleKhungGioStatus(sanKhungGio, idx)
                                                : null,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _getStatusBackgroundColor(khungGio.trangThai),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _getStatusColor(khungGio.trangThai),
                                                  width: 1,
                                                ),
                                              ),
                                              padding: EdgeInsets.all(8),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        "${khungGio.gioBatDau}\n${khungGio.gioKetThuc}",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    _getStatusIcon(khungGio.trangThai),
                                                    color: _getStatusColor(khungGio.trangThai),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 16,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                                          SizedBox(width: 4),
                                          Text("Hoạt động", style: TextStyle(color: AppColors.textColor)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.event_busy, color: Colors.orange, size: 16),
                                          SizedBox(width: 4),
                                          Text("Đã đặt", style: TextStyle(color: AppColors.textColor)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.cancel, color: Colors.red, size: 16),
                                          SizedBox(width: 4),
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
  }
}