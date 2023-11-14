import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateQuestion extends StatelessWidget {
  final XFile image;

  const CreateQuestion({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Question'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
          child: Image.file(File(image.path)),
        ),
      ),
    );
  }
}