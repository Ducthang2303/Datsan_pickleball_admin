import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pickleball_admin/services/upload_anh.dart';

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _image;
  String? _imageUrl;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      final url = await CloudinaryService.uploadImage(_image!);
      setState(() {
        _imageUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload ảnh lên Cloudinary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageUrl != null
                ? Image.network(_imageUrl!)
                : Text('Chưa có ảnh'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              child: Text('Chọn và Upload ảnh'),
            ),
          ],
        ),
      ),
    );
  }
}
