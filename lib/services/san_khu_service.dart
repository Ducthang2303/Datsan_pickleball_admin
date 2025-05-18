import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/khung_gio.dart';
import '../models/san.dart';
import '../models/khu.dart';
import '../models/san_khunggio.dart';

class SanKhuService {
  final CollectionReference _sanCollection = FirebaseFirestore.instance.collection('SAN');
  final CollectionReference _khuCollection = FirebaseFirestore.instance.collection('KHU');
  final CollectionReference _lichSanCollection = FirebaseFirestore.instance.collection('SAN_KHUNGGIO');
  final CollectionReference _phanKhuCollection = FirebaseFirestore.instance.collection('PHAN_KHU');

  Future<List<Khu>> getKhuByUserId(String userId) async {
    try {
      QuerySnapshot phanKhuSnapshot = await _phanKhuCollection
          .where('MA_NGUOI_DUNG', isEqualTo: userId)
          .get();

      if (phanKhuSnapshot.docs.isEmpty) {
        print("Không có khu nào được phân cho người dùng $userId");
        return [];
      }

      List<String> maKhuList = phanKhuSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['MA_KHU'] as String)
          .toList();

      List<Khu> khuList = [];

      for (String maKhu in maKhuList) {
        DocumentSnapshot khuDoc = await _khuCollection.doc(maKhu).get();

        if (khuDoc.exists) {
          khuList.add(Khu.fromMap(khuDoc.data() as Map<String, dynamic>, khuDoc.id));
        }
      }

      // Sort khuList by MA in ascending order
      khuList.sort((a, b) => a.ma.compareTo(b.ma));

      return khuList;
    } catch (e) {
      print("Lỗi khi lấy danh sách khu theo người dùng: $e");
      return [];
    }
  }

  Future<List<Khu>> getAllKhu() async {
    try {
      QuerySnapshot snapshot = await _khuCollection.get();
      return snapshot.docs.map((doc) => Khu.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Lỗi khi lấy danh sách khu: $e");
      return [];
    }
  }

  Future<List<San>> getAllSan() async {
    try {
      QuerySnapshot snapshot = await _sanCollection.get();
      return snapshot.docs.map((doc) => San.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Lỗi khi lấy danh sách sân: $e");
      return [];
    }
  }

  Future<List<San>> getSanByKhu(String maKhu) async {
    try {
      QuerySnapshot snapshot = await _sanCollection.where('MA_KHU', isEqualTo: maKhu).get();
      List<San> sanList = snapshot.docs
          .map((doc) => San.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Sort sanList by TEN in ascending order
      sanList.sort((a, b) => a.ten.compareTo(b.ten));

      return sanList;
    } catch (e) {
      print("Lỗi khi lấy danh sách sân theo khu: $e");
      return [];
    }
  }

  Future<List<SanKhungGio>> getKhungGioBySan(String maSan, String ngay) async {
    try {
      QuerySnapshot snapshot = await _lichSanCollection
          .where('MA_SAN', isEqualTo: maSan)
          .where('NGAY', isEqualTo: ngay)
          .get();

      return snapshot.docs.map((doc) => SanKhungGio.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Lỗi khi lấy khung giờ của sân $maSan vào ngày $ngay: $e");
      return [];
    }
  }

  Future<void> addAllKhungGioForSan(String maSan, String ngay) async {
    try {
      List<KhungGio> khungGios = [
        KhungGio(gioBatDau: "06:00", gioKetThuc: "07:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "07:00", gioKetThuc: "08:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "08:00", gioKetThuc: "09:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "09:00", gioKetThuc: "10:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "10:00", gioKetThuc: "11:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "11:00", gioKetThuc: "12:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "12:00", gioKetThuc: "13:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "13:00", gioKetThuc: "14:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "14:00", gioKetThuc: "15:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "15:00", gioKetThuc: "16:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "16:00", gioKetThuc: "17:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "17:00", gioKetThuc: "18:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "18:00", gioKetThuc: "19:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "19:00", gioKetThuc: "20:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "20:00", gioKetThuc: "21:00", trangThai: 0, giaTien: 100000),
        KhungGio(gioBatDau: "21:00", gioKetThuc: "22:00", trangThai: 0, giaTien: 100000),
      ];

      SanKhungGio sanKhungGio = SanKhungGio(maSan: maSan, ngay: ngay, khungGio: khungGios);
      await _lichSanCollection
          .doc("${maSan}_$ngay")
          .set(sanKhungGio.toMap());

      print("Đã thêm tất cả khung giờ cho sân $maSan vào ngày $ngay");
    } catch (e) {
      print("Lỗi khi thêm khung giờ: $e");
    }
  }

  Future<void> updateKhungGioStatus(String maSan, String ngay, int khungGioIndex, int newStatus) async {
    try {
      DocumentReference documentRef = _lichSanCollection.doc("${maSan}_$ngay");
      DocumentSnapshot docSnapshot = await documentRef.get();
      if (!docSnapshot.exists) {
        print("Document ${maSan}_$ngay does not exist");
        return;
      }

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> khungGioList = data["KHUNG_GIO"] as List<dynamic>;

      if (khungGioIndex >= 0 && khungGioIndex < khungGioList.length) {
        if (newStatus >= 0 && newStatus <= 2) {
          khungGioList[khungGioIndex]["trangThai"] = newStatus;

          await documentRef.update({"KHUNG_GIO": khungGioList});
          print("Đã cập nhật trạng thái khung giờ cho ${maSan}_$ngay thành $newStatus");
        } else {
          print("Giá trị trạng thái không hợp lệ: $newStatus. Phải là 0, 1, hoặc 2");
        }
      } else {
        print("Chỉ số khungGioIndex không hợp lệ: $khungGioIndex");
      }
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái khung giờ: $e");
    }
  }

  Future<int> getCourtCountByKhu(String maKhu) async {
    try {
      QuerySnapshot snapshot = await _sanCollection.where('MA_KHU', isEqualTo: maKhu).get();
      return snapshot.docs.length;
    } catch (e) {
      print("Lỗi khi đếm số sân trong khu $maKhu: $e");
      return 0;
    }
  }

  Future<String?> addSan(San san) async {
    try {
      // Get the current number of courts in the khu to determine the next number
      int courtCount = await getCourtCountByKhu(san.maKhu);
      // Generate ma as san{number}-{maKhu}
      String generatedMa = 'san${courtCount + 1}-${san.maKhu}';
      // Generate ten as Sân {number}
      String generatedTen = 'Sân ${courtCount + 1}';

      // Create a new San object with generated ma and ten
      San newSan = San(
        id: san.id,
        ma: generatedMa,
        maKhu: san.maKhu,
        ten: generatedTen,
        trangThai: san.trangThai,
      );

      DocumentReference docRef = await _sanCollection.add(newSan.toMap());
      print("Đã thêm sân mới với ID: ${docRef.id}, mã: ${newSan.ma}, tên: ${newSan.ten}");
      return docRef.id;
    } catch (e) {
      print("Lỗi khi thêm sân mới: $e");
      return null;
    }
  }

  Future<bool> updateSan(String sanId, San san) async {
    try {
      DocumentSnapshot sanDoc = await _sanCollection.doc(sanId).get();
      if (!sanDoc.exists) {
        print("Sân với ID $sanId không tồn tại");
        return false;
      }

      DocumentSnapshot khuDoc = await _khuCollection.doc(san.maKhu).get();
      if (!khuDoc.exists) {
        print("Khu với mã ${san.maKhu} không tồn tại");
        return false;
      }

      await _sanCollection.doc(sanId).update(san.toMap());
      print("Đã cập nhật thông tin sân với ID: $sanId");
      return true;
    } catch (e) {
      print("Lỗi khi cập nhật thông tin sân: $e");
      return false;
    }
  }

  Future<bool> deleteSan(String sanId) async {
    try {
      DocumentSnapshot sanDoc = await _sanCollection.doc(sanId).get();
      if (!sanDoc.exists) {
        print("Sân với ID $sanId không tồn tại");
        return false;
      }

      QuerySnapshot lichSanDocs = await _lichSanCollection
          .where('MA_SAN', isEqualTo: sanId)
          .get();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in lichSanDocs.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_sanCollection.doc(sanId));
      await batch.commit();

      print("Đã xóa sân với ID: $sanId và các khung giờ liên quan");
      return true;
    } catch (e) {
      print("Lỗi khi xóa sân: $e");
      return false;
    }
  }

  Future<bool> updateSanStatus(String sanId, bool newStatus) async {
    try {
      await _sanCollection.doc(sanId).update({'TRANG_THAI': newStatus});
      return true;
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái sân: $e");
      return false;
    }
  }

  Future<San?> getSanById(String sanId) async {
    try {
      DocumentSnapshot doc = await _sanCollection.doc(sanId).get();
      if (!doc.exists) {
        print("Sân với ID $sanId không tồn tại");
        return null;
      }

      return San.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print("Lỗi khi lấy thông tin sân: $e");
      return null;
    }
  }
}