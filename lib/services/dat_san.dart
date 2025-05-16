import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/khung_gio.dart';
import '../models/san_khunggio.dart';
import '../models/hoa_don.dart';

class DatSanService {
  final CollectionReference _lichSanCollection = FirebaseFirestore.instance.collection('SAN_KHUNGGIO');
  final CollectionReference _hoaDonCollection = FirebaseFirestore.instance.collection('HOA_DON');


  Future<bool> duyetDonDatSan(HoaDon hoaDon) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(_hoaDonCollection.doc(hoaDon.id), {
        'trangThai': 'Đã duyệt',
      });


      Map<String, List<KhungGioHoaDon>> groupedKhungGio = {};
      for (var khungGio in hoaDon.khungGio) {
        String docId = "${hoaDon.maSan}_${khungGio.ngay}";
        groupedKhungGio.putIfAbsent(docId, () => []).add(khungGio);
      }

      for (var entry in groupedKhungGio.entries) {
        String docId = entry.key;
        List<KhungGioHoaDon> khungGioList = entry.value;
        DocumentReference documentRef = _lichSanCollection.doc(docId);
        DocumentSnapshot docSnapshot = await documentRef.get();
        if (!docSnapshot.exists) {
          print(" Không tìm thấy document $docId");
          return false;
        }

        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> khungGioArray = List.from(data["KHUNG_GIO"]);

        bool allIndicesValid = true;
        for (var khungGio in khungGioList) {
          int? khungGioIndex = await _timKhungGioIndex(
            hoaDon.maSan,
            khungGio.ngay,
            khungGio.gioBatDau,
            khungGio.gioKetThuc,
          );

          if (khungGioIndex == null || khungGioIndex < 0 || khungGioIndex >= khungGioArray.length) {
            print(" Không tìm thấy hoặc chỉ số không hợp lệ cho khung giờ ${khungGio.gioBatDau}-${khungGio.gioKetThuc} trong $docId");
            allIndicesValid = false;
            break;
          }

          khungGioArray[khungGioIndex]["trangThai"] = 1;
        }

        if (!allIndicesValid) {
          return false;
        }
        batch.update(documentRef, {"KHUNG_GIO": khungGioArray});
      }
      await batch.commit();
      print(" Đã duyệt đơn đặt sân ${hoaDon.id} thành công");
      return true;
    } catch (e) {
      print(" Lỗi khi duyệt đơn đặt sân: $e");
      return false;
    }
  }


  Future<bool> huyDonDatSan(HoaDon hoaDon) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(_hoaDonCollection.doc(hoaDon.id), {
        'trangThai': 'Đã hủy',
      });

      Map<String, List<KhungGioHoaDon>> groupedKhungGio = {};
      for (var khungGio in hoaDon.khungGio) {
        String docId = "${hoaDon.maSan}_${khungGio.ngay}";
        groupedKhungGio.putIfAbsent(docId, () => []).add(khungGio);
      }

      for (var entry in groupedKhungGio.entries) {
        String docId = entry.key;
        List<KhungGioHoaDon> khungGioList = entry.value;
        DocumentReference documentRef = _lichSanCollection.doc(docId);
        DocumentSnapshot docSnapshot = await documentRef.get();
        if (!docSnapshot.exists) {
          print(" Không tìm thấy document $docId");
          return false;
        }

        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> khungGioArray = List.from(data["KHUNG_GIO"]);


        bool allIndicesValid = true;
        for (var khungGio in khungGioList) {
          int? khungGioIndex = await _timKhungGioIndex(
            hoaDon.maSan,
            khungGio.ngay,
            khungGio.gioBatDau,
            khungGio.gioKetThuc,
          );

          if (khungGioIndex == null || khungGioIndex < 0 || khungGioIndex >= khungGioArray.length) {
            print(" Không tìm thấy hoặc chỉ số không hợp lệ cho khung giờ ${khungGio.gioBatDau}-${khungGio.gioKetThuc} trong $docId");
            allIndicesValid = false;
            break;
          }
          khungGioArray[khungGioIndex]["trangThai"] = 0; // Có thể đặt
        }
        if (!allIndicesValid) {
          return false;
        }
        batch.update(documentRef, {"KHUNG_GIO": khungGioArray});
      }
      await batch.commit();
      print(" Đã hủy đơn đặt sân ${hoaDon.id} thành công");
      return true;
    } catch (e) {
      print(" Lỗi khi hủy đơn đặt sân: $e");
      return false;
    }
  }


  Future<int?> _timKhungGioIndex(String maSan, String ngay, String gioBatDau, String gioKetThuc) async {
    try {
      DocumentSnapshot docSnapshot = await _lichSanCollection.doc("${maSan}_$ngay").get();
      if (!docSnapshot.exists) {
        print(" Không tìm thấy lịch sân cho ${maSan}_$ngay");
        return null;
      }
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> khungGioList = data["KHUNG_GIO"] as List<dynamic>;

      for (int i = 0; i < khungGioList.length; i++) {
        if (khungGioList[i]["gioBatDau"] == gioBatDau &&
            khungGioList[i]["gioKetThuc"] == gioKetThuc) {
          return i;
        }
      }
      return null;
    } catch (e) {
      print(" Lỗi khi tìm chỉ mục khung giờ: $e");
      return null;
    }
  }


  Future<bool> _capNhatTrangThaiKhungGio(String maSan, String ngay, int khungGioIndex, int newStatus) async {
    try {
      DocumentReference documentRef = _lichSanCollection.doc("${maSan}_$ngay");
      DocumentSnapshot docSnapshot = await documentRef.get();
      if (!docSnapshot.exists) {
        print(" Không tìm thấy document ${maSan}_$ngay");
        return false;
      }


      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> khungGioList = data["KHUNG_GIO"] as List<dynamic>;

      if (khungGioIndex >= 0 && khungGioIndex < khungGioList.length) {
        if (newStatus >= 0 && newStatus <= 2) {
          khungGioList[khungGioIndex]["trangThai"] = newStatus;

          // Cập nhật Firestore
          await documentRef.update({"KHUNG_GIO": khungGioList});
          print(" Đã cập nhật trạng thái khung giờ cho ${maSan}_$ngay khung giờ $khungGioIndex thành $newStatus");
          return true;
        } else {
          print(" Giá trị trạng thái không hợp lệ: $newStatus. Phải là 0, 1, hoặc 2");
          return false;
        }
      } else {
        print(" Chỉ số khungGioIndex không hợp lệ: $khungGioIndex");
        return false;
      }
    } catch (e) {
      print(" Lỗi khi cập nhật trạng thái khung giờ: $e");
      return false;
    }
  }

  Future<bool> kiemTraKhungGioDaDat(String maSan, String ngay, String gioBatDau, String gioKetThuc) async {
    try {
      int? khungGioIndex = await _timKhungGioIndex(maSan, ngay, gioBatDau, gioKetThuc);

      if (khungGioIndex == null) {
        return false;
      }
      DocumentSnapshot docSnapshot = await _lichSanCollection.doc("${maSan}_$ngay").get();

      if (!docSnapshot.exists) {
        return false;
      }

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> khungGioList = data["KHUNG_GIO"] as List<dynamic>;
      int trangThai = khungGioList[khungGioIndex]["trangThai"];
      return trangThai == 1 || trangThai == 2;
    } catch (e) {
      print("❌ Lỗi khi kiểm tra khung giờ: $e");
      return false;
    }
  }
}