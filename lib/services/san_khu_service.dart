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

  //  Lấy danh sách khu theo MA_NGUOI_DUNG
  Future<List<Khu>> getKhuByUserId(String userId) async {
    try {
      // Bước 1: Lấy các bản ghi từ collection PHAN_KHU theo MA_NGUOI_DUNG
      QuerySnapshot phanKhuSnapshot = await _phanKhuCollection
          .where('MA_NGUOI_DUNG', isEqualTo: userId)
          .get();

      // Nếu không có bản ghi nào, trả về danh sách rỗng
      if (phanKhuSnapshot.docs.isEmpty) {
        print("Không có khu nào được phân cho người dùng $userId");
        return [];
      }

      // Bước 2: Lấy danh sách MA_KHU từ các bản ghi PHAN_KHU
      List<String> maKhuList = phanKhuSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['MA_KHU'] as String)
          .toList();

      // Bước 3: Lấy thông tin chi tiết của từng KHU
      List<Khu> khuList = [];

      for (String maKhu in maKhuList) {
        DocumentSnapshot khuDoc = await _khuCollection.doc(maKhu).get();

        if (khuDoc.exists) {
          khuList.add(Khu.fromMap(khuDoc.data() as Map<String, dynamic>, khuDoc.id));
        }
      }

      return khuList;
    } catch (e) {
      print("Lỗi khi lấy danh sách khu theo người dùng: $e");
      return [];
    }
  }

  //  Lấy danh sách khu
  Future<List<Khu>> getAllKhu() async {
    try {
      QuerySnapshot snapshot = await _khuCollection.get();
      return snapshot.docs.map((doc) => Khu.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Lỗi khi lấy danh sách khu: $e");
      return [];
    }
  }

  //  Lấy danh sách sân
  Future<List<San>> getAllSan() async {
    try {
      QuerySnapshot snapshot = await _sanCollection.get();
      return snapshot.docs.map((doc) => San.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Lỗi khi lấy danh sách sân: $e");
      return [];
    }
  }

  //  Lấy danh sách sân theo khu
  Future<List<San>> getSanByKhu(String maKhu) async {
    try {
      QuerySnapshot snapshot = await _sanCollection.where('MA_KHU', isEqualTo: maKhu).get();
      return snapshot.docs.map((doc) => San.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Lỗi khi lấy danh sách sân theo khu: $e");
      return [];
    }
  }

  //  Lấy danh sách khung giờ của một sân theo ngày
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

  //  Thêm tất cả khung giờ cho một sân trong ngày
  Future<void> addAllKhungGioForSan(String maSan, String ngay) async {
    try {
      // Danh sách khung giờ từ 06:00 - 22:00
      List<KhungGio> khungGios = [
        KhungGio(gioBatDau: "06:00", gioKetThuc: "07:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "07:00", gioKetThuc: "08:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "08:00", gioKetThuc: "09:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "09:00", gioKetThuc: "10:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "10:00", gioKetThuc: "11:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "11:00", gioKetThuc: "12:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "12:00", gioKetThuc: "13:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "13:00", gioKetThuc: "14:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "14:00", gioKetThuc: "15:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "15:00", gioKetThuc: "16:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "16:00", gioKetThuc: "17:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "17:00", gioKetThuc: "18:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "18:00", gioKetThuc: "19:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "19:00", gioKetThuc: "20:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "20:00", gioKetThuc: "21:00", trangThai: 0,giaTien: 100000),
        KhungGio(gioBatDau: "21:00", gioKetThuc: "22:00", trangThai: 0,giaTien: 100000),
      ];

      // Tạo document mới trong Firestore
      SanKhungGio sanKhungGio = SanKhungGio(maSan: maSan, ngay: ngay, khungGio: khungGios);

      await _lichSanCollection
          .doc("${maSan}_$ngay") // Đặt ID document theo dạng "SAN_001_2025-03-30"
          .set(sanKhungGio.toMap());

      print(" Đã thêm tất cả khung giờ cho sân $maSan vào ngày $ngay");
    } catch (e) {
      print("Lỗi khi thêm khung giờ: $e");
    }
  }

  //  Cập nhật trạng thái khung giờ
  Future<void> updateKhungGioStatus(String maSan, String ngay, int khungGioIndex, int newStatus) async {
    try {
      // Reference to the document
      DocumentReference documentRef = _lichSanCollection.doc("${maSan}_$ngay");

      // Get current document data
      DocumentSnapshot docSnapshot = await documentRef.get();
      if (!docSnapshot.exists) {
        print(" Document ${maSan}_$ngay does not exist");
        return;
      }

      // Extract data
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> khungGioList = data["KHUNG_GIO"] as List<dynamic>;

      // Update the specific time slot
      if (khungGioIndex >= 0 && khungGioIndex < khungGioList.length) {
        // Ensure newStatus is valid (0, 1, or 2)
        if (newStatus >= 0 && newStatus <= 2) {
          khungGioList[khungGioIndex]["trangThai"] = newStatus;

          // Update Firestore
          await documentRef.update({"KHUNG_GIO": khungGioList});
          print(" Đã cập nhật trạng thái khung giờ cho ${maSan}_$ngay thành $newStatus");
        } else {
          print(" Giá trị trạng thái không hợp lệ: $newStatus. Phải là 0, 1, hoặc 2");
        }
      } else {
        print(" Chỉ số khungGioIndex không hợp lệ: $khungGioIndex");
      }
    } catch (e) {
      print(" Lỗi khi cập nhật trạng thái khung giờ: $e");
    }
  }

  //  Thêm sân mới
  Future<String?> addSan(San san) async {
    try {
      // // Kiểm tra xem khu có tồn tại không
      // DocumentSnapshot khuDoc = await _khuCollection.doc(san.maKhu).get();
      // if (!khuDoc.exists) {
      //   print(" Khu với mã ${san.maKhu} không tồn tại");
      //   return null;
      // }

      // Thêm sân mới vào Firestore
      DocumentReference docRef = await _sanCollection.add(san.toMap());
      print("✅ Đã thêm sân mới với ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print(" Lỗi khi thêm sân mới: $e");
      return null;
    }
  }

  //  Cập nhật thông tin sân
  Future<bool> updateSan(String sanId, San san) async {
    try {
      // Kiểm tra xem sân có tồn tại không
      DocumentSnapshot sanDoc = await _sanCollection.doc(sanId).get();
      if (!sanDoc.exists) {
        print(" Sân với ID $sanId không tồn tại");
        return false;
      }

      // Kiểm tra xem khu có tồn tại không nếu có cập nhật mã khu
      DocumentSnapshot khuDoc = await _khuCollection.doc(san.maKhu).get();
      if (!khuDoc.exists) {
        print(" Khu với mã ${san.maKhu} không tồn tại");
        return false;
      }

      // Cập nhật thông tin sân
      await _sanCollection.doc(sanId).update(san.toMap());
      print(" Đã cập nhật thông tin sân với ID: $sanId");
      return true;
    } catch (e) {
      print(" Lỗi khi cập nhật thông tin sân: $e");
      return false;
    }
  }

  //  Xóa sân
  Future<bool> deleteSan(String sanId) async {
    try {
      // Kiểm tra xem sân có tồn tại không
      DocumentSnapshot sanDoc = await _sanCollection.doc(sanId).get();
      if (!sanDoc.exists) {
        print(" Sân với ID $sanId không tồn tại");
        return false;
      }

      // Xóa tất cả khung giờ liên quan đến sân này
      QuerySnapshot lichSanDocs = await _lichSanCollection
          .where('MA_SAN', isEqualTo: sanId)
          .get();

      // Batch delete để xóa nhiều documents cùng lúc
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in lichSanDocs.docs) {
        batch.delete(doc.reference);
      }

      // Xóa sân
      batch.delete(_sanCollection.doc(sanId));

      // Commit batch
      await batch.commit();

      print(" Đã xóa sân với ID: $sanId và các khung giờ liên quan");
      return true;
    } catch (e) {
      print(" Lỗi khi xóa sân: $e");
      return false;
    }
  }

  //  Cập nhật trạng thái sân
  Future<bool> updateSanStatus(String sanId, bool newStatus) async {
    try {
      await _sanCollection.doc(sanId).update({'TRANG_THAI': newStatus});
      return true;
    } catch (e) {
      print(" Lỗi khi cập nhật trạng thái sân: $e");
      return false;
    }
  }


  //  Lấy thông tin chi tiết của một sân
  Future<San?> getSanById(String sanId) async {
    try {
      DocumentSnapshot doc = await _sanCollection.doc(sanId).get();
      if (!doc.exists) {
        print(" Sân với ID $sanId không tồn tại");
        return null;
      }

      return San.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print(" Lỗi khi lấy thông tin sân: $e");
      return null;
    }
  }
}