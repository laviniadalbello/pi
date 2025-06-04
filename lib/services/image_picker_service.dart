import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:universal_html/html.dart' as html;

class ImagePickerService {
  static Future<Uint8List?> pickImage() async {
    if (kIsWeb) {
      return _pickImageWeb();
    } else {
      return _pickImageMobile();
    }
  }

  static Future<Uint8List?> _pickImageMobile() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return await pickedFile.readAsBytes();
      }
    } catch (e) {
      print('Erro ao selecionar imagem (mobile): $e');
    }
    return null;
  }

  static Future<Uint8List?> _pickImageWeb() async {
    try {
      final pickedFile = await ImagePickerWeb.getImageAsBytes();
      return pickedFile;
    } catch (e) {
      print('Erro ao selecionar imagem (web): $e');
    }
    return null;
  }
}