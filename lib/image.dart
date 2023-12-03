import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

Future<String> saveImageToStorageFromAssets(String assetPath, var n) async {
  final byteData = await rootBundle.load(assetPath);
  final directory = await getApplicationDocumentsDirectory();
  final imagePath = '${directory.path}/image$n.jpg'; // Replace "my_image.jpg" with a unique name for your image
  final newImageFile = File(imagePath);
  try {
    await newImageFile.writeAsBytes(byteData.buffer.asUint8List());
    return imagePath;
  } catch (e) {
    // print('Failed to save image to storage: $e');
    return '';
  }
}

Future<String> saveImageToStorageFromBytes(String byteB64, String name) async {
  final directory = await getApplicationDocumentsDirectory();
  final imagePath = '${directory.path}/$name.jpg'; // Replace "my_image.jpg" with a unique name for your image
  final newImageFile = File(imagePath);
  try {
    await newImageFile.writeAsBytes(base64Decode(byteB64));
    return imagePath;
  } catch (e) {
    // print('Failed to save image to storage: $e');
    return '';
  }
}