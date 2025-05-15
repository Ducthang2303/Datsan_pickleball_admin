import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/khung_gio.dart';
import '../models/san_khunggio.dart';
import '../models/hoa_don.dart';

class DatSanService {
  final CollectionReference _lichSanCollection = FirebaseFirestore.instance.collection('SAN_KHUNGGIO');
  final CollectionReference _hoaDonCollection = FirebaseFirestore.instance.collection('HOA_DON');

  // Cập nhật trạng thái hóa đơn và khung giờ của sân khi duyệt đơn
  Future<bool> duyetDonDatSan(HoaDon hoaDon) async {
    try {
      // Khởi tạo batch
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 1. Cập nhật trạng thái hóa đơn
      batch.update(_hoaDonCollection.doc(hoaDon.id), {
        'trangThai': 'Đã duyệt',
      });

      // 2. Nhóm các khung giờ theo docId (maSan_ngay)
      Map<String, List<KhungGioHoaDon>> groupedKhungGio = {};
      for (var khungGio in hoaDon.khungGio) {
        String docId = "${hoaDon.maSan}_${khungGio.ngay}";
        groupedKhungGio.putIfAbsent(docId, () => []).add(khungGio);
      }

      // 3. Cập nhật trạng thái khung giờ cho từng docId
      for (var entry in groupedKhungGio.entries) {
        String docId = entry.key;
        List<KhungGioHoaDon> khungGioList = entry.value;

        // Lấy document SAN_KHUNGGIO
        DocumentReference documentRef = _lichSanCollection.doc(docId);
        DocumentSnapshot docSnapshot = await documentRef.get();
        if (!docSnapshot.exists) {
          print("❌ Không tìm thấy document $docId");
          return false;
        }

        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> khungGioArray = List.from(data["KHUNG_GIO"]);

        // Cập nhật trạng thái cho tất cả khung giờ trong ngày
        bool allIndicesValid = true;
        for (var khungGio in khungGioList) {
          int? khungGioIndex = await _timKhungGioIndex(
            hoaDon.maSan,
            khungGio.ngay,
            khungGio.gioBatDau,
            khungGio.gioKetThuc,
          );

          if (khungGioIndex == null || khungGioIndex < 0 || khungGioIndex >= khungGioArray.length) {
            print("❌ Không tìm thấy hoặc chỉ số không hợp lệ cho khung giờ ${khungGio.gioBatDau}-${khungGio.gioKetThuc} trong $docId");
            allIndicesValid = false;
            break;
          }

          khungGioArray[khungGioIndex]["trangThai"] = 1; // Đã duyệt
        }

        if (!allIndicesValid) {
          return false;
        }

        // Thêm cập nhật vào batch
        batch.update(documentRef, {"KHUNG_GIO": khungGioArray});
      }

      // Thực hiện batch
      await batch.commit();
      print("✅ Đã duyệt đơn đặt sân ${hoaDon.id} thành công");
      return true;
    } catch (e) {
      print("❌ Lỗi khi duyệt đơn đặt sân: $e");
      return false;
    }
  }

  // Hủy đơn đặt sân và mở lại các khung giờ
  Future<bool> huyDonDatSan(HoaDon hoaDon) async {
    try {
      // Khởi tạo batch
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 1. Cập nhật trạng thái hóa đơn
      batch.update(_hoaDonCollection.doc(hoaDon.id), {
        'trangThai': 'Đã hủy',
      });

      // 2. Nhóm các khung giờ theo docId (maSan_ngay)
      Map<String, List<KhungGioHoaDon>> groupedKhungGio = {};
      for (var khungGio in hoaDon.khungGio) {
        String docId = "${hoaDon.maSan}_${khungGio.ngay}";
        groupedKhungGio.putIfAbsent(docId, () => []).add(khungGio);
      }

      // 3. Cập nhật trạng thái khung giờ cho từng docId
      for (var entry in groupedKhungGio.entries) {
        String docId = entry.key;
        List<KhungGioHoaDon> khungGioList = entry.value;

        // Lấy document SAN_KHUNGGIO
        DocumentReference documentRef = _lichSanCollection.doc(docId);
        DocumentSnapshot docSnapshot = await documentRef.get();
        if (!docSnapshot.exists) {
          print("❌ Không tìm thấy document $docId");
          return false;
        }

        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> khungGioArray = List.from(data["KHUNG_GIO"]);

        // Cập nhật trạng thái cho tất cả khung giờ trong ngày
        bool allIndicesValid = true;
        for (var khungGio in khungGioList) {
          int? khungGioIndex = await _timKhungGioIndex(
            hoaDon.maSan,
            khungGio.ngay,
            khungGio.gioBatDau,
            khungGio.gioKetThuc,
          );

          if (khungGioIndex == null || khungGioIndex < 0 || khungGioIndex >= khungGioArray.length) {
            print("❌ Không tìm thấy hoặc chỉ số không hợp lệ cho khung giờ ${khungGio.gioBatDau}-${khungGio.gioKetThuc} trong $docId");
            allIndicesValid = false;
            break;
          }

          khungGioArray[khungGioIndex]["trangThai"] = 0; // Có thể đặt
        }

        if (!allIndicesValid) {
          return false;
        }

        // Thêm cập nhật vào batch
        batch.update(documentRef, {"KHUNG_GIO": khungGioArray});
      }

      // Thực hiện batch
      await batch.commit();
      print("✅ Đã hủy đơn đặt sân ${hoaDon.id} thành công");
      return true;
    } catch (e) {
      print("❌ Lỗi khi hủy đơn đặt sân: $e");
      return false;
    }
  }

  // Tìm chỉ mục của khung giờ dựa vào giờ bắt đầu và kết thúc
  Future<int?> _timKhungGioIndex(String maSan, String ngay, String gioBatDau, String gioKetThuc) async {
    try {
      // Lấy document chứa thông tin khung giờ của sân trong ngày
      DocumentSnapshot docSnapshot = await _lichSanCollection.doc("${maSan}_$ngay").get();

      if (!docSnapshot.exists) {
        print("❌ Không tìm thấy lịch sân cho ${maSan}_$ngay");
        return null;
      }

      // Trích xuất dữ liệu
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> khungGioList = data["KHUNG_GIO"] as List<dynamic>;

      // Tìm chỉ mục của khung giờ
      for (int i = 0; i < khungGioList.length; i++) {
        if (khungGioList[i]["gioBatDau"] == gioBatDau &&
            khungGioList[i]["gioKetThuc"] == gioKetThuc) {
          return i;
        }
      }

      // Không tìm thấy khung giờ phù hợp
      return null;
    } catch (e) {
      print("❌ Lỗi khi tìm chỉ mục khung giờ: $e");
      return null;
    }
  }

  // Cập nhật trạng thái của khung giờ
  Future<bool> _capNhatTrangThaiKhungGio(String maSan, String ngay, int khungGioIndex, int newStatus) async {
    try {
      // Tham chiếu đến document
      DocumentReference documentRef = _lichSanCollection.doc("${maSan}_$ngay");

      // Lấy dữ liệu document hiện tại
      DocumentSnapshot docSnapshot = await documentRef.get();
      if (!docSnapshot.exists) {
        print("❌ Không tìm thấy document ${maSan}_$ngay");
        return false;
      }

      // Trích xuất dữ liệu
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> khungGioList = data["KHUNG_GIO"] as List<dynamic>;

      // Cập nhật trạng thái cho khung giờ cụ thể
      if (khungGioIndex >= 0 && khungGioIndex < khungGioList.length) {
        // Đảm bảo newStatus hợp lệ (0, 1, hoặc 2)
        if (newStatus >= 0 && newStatus <= 2) {
          khungGioList[khungGioIndex]["trangThai"] = newStatus;

          // Cập nhật Firestore
          await documentRef.update({"KHUNG_GIO": khungGioList});
          print("✅ Đã cập nhật trạng thái khung giờ cho ${maSan}_$ngay khung giờ $khungGioIndex thành $newStatus");
          return true;
        } else {
          print("❌ Giá trị trạng thái không hợp lệ: $newStatus. Phải là 0, 1, hoặc 2");
          return false;
        }
      } else {
        print("❌ Chỉ số khungGioIndex không hợp lệ: $khungGioIndex");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi khi cập nhật trạng thái khung giờ: $e");
      return false;
    }
  }

  // Kiểm tra xem khung giờ đã được đặt chưa
  Future<bool> kiemTraKhungGioDaDat(String maSan, String ngay, String gioBatDau, String gioKetThuc) async {
    try {
      int? khungGioIndex = await _timKhungGioIndex(maSan, ngay, gioBatDau, gioKetThuc);

      if (khungGioIndex == null) {
        return false;
      }

      // Lấy document chứa thông tin khung giờ của sân trong ngày
      DocumentSnapshot docSnapshot = await _lichSanCollection.doc("${maSan}_$ngay").get();

      if (!docSnapshot.exists) {
        return false;
      }

      // Trích xuất dữ liệu
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> khungGioList = data["KHUNG_GIO"] as List<dynamic>;

      // Kiểm tra trạng thái của khung giờ
      int trangThai = khungGioList[khungGioIndex]["trangThai"];

      // Nếu trạng thái là 1 (đã duyệt) hoặc 2 (đã đặt) thì trả về true
      return trangThai == 1 || trangThai == 2;
    } catch (e) {
      print("❌ Lỗi khi kiểm tra khung giờ: $e");
      return false;
    }
  }
}