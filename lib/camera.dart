import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'constants.dart';
import 'new_question.dart';

class CameraButton extends StatefulWidget {
  const CameraButton({super.key});

  @override
  _CameraButtonState createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _takePhoto(BuildContext context) async {
    final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);

    if (photo != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateQuestion(image: photo))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () {_takePhoto(context);},
      shape: RoundedRectangleBorder(
          side: BorderSide(width: 3, color: mainColor),
          borderRadius: BorderRadius.circular(100)
        ),
        backgroundColor: backgroundColor,
        child: Icon(Icons.add_a_photo_rounded, color: mainColor,),
    );
  }
}