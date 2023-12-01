import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hku_guesser/image.dart';
import 'package:image_picker/image_picker.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hku_guesser/question_database.dart';

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
          child: NewAnswerPage(image: image),
        ),
      ),
    );
  }
}

class NewAnswerPage extends StatefulWidget {
  final XFile image;
  const NewAnswerPage({super.key, required this.image});

  @override
  State<NewAnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<NewAnswerPage> {
  var x = -100.0;
  var y = -100.0;
  var floor = 0;

  final viewTransformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    const zoomFactor = 0.34;
    const xTranslate = 35.0;
    const yTranslate = 55.0;
    viewTransformationController.value.setEntry(0, 0, zoomFactor);
    viewTransformationController.value.setEntry(1, 1, zoomFactor);
    viewTransformationController.value.setEntry(2, 2, zoomFactor);
    viewTransformationController.value.setEntry(0, 3, -xTranslate);
    viewTransformationController.value.setEntry(1, 3, -yTranslate);
  }

  @override
  Widget build(BuildContext context) {

    const List<(String, int)> floor_options = [
      ("G/F", 0),
      ("1/F", 1),
      ("2/F", 2),
      ("3/F", 3),
      ("4/F", 4),
      ("5/F+", 5),
    ];

    var image = Image.asset('assets/images/hku_image.jpg');

    print("x: " + x.toString() + " y: " + y.toString());
    return Stack(
      children: <Widget>[
        InteractiveViewer(
          transformationController: viewTransformationController,
          constrained: false,
          minScale: 0.1,
          maxScale: 3,
          child: GestureDetector(
            // store the position of the tap
            onTapUp: (details) {
              setState(() {
                x = details.localPosition.dx;
                y = details.localPosition.dy;
              });
              print("x: " + x.toString() + " y: " + y.toString());
              print(viewTransformationController.value);
            },
            child: CustomPaint(
              foregroundPainter: CirclePainter(x, y),
              child: image,
            ),
          ),
        ),
        if (x >= 0)
          Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      width: 80,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: DropdownButton(
                          isDense: true,
                          borderRadius: BorderRadius.circular(5),
                          value: floor_options[floor].$2,
                          items: floor_options
                              .map((value) {
                                return DropdownMenuItem<int>(
                                  value: value.$2,
                                  alignment: Alignment.centerRight,
                                  child: Text(value.$1),
                                );
                              })
                              .toList()
                              .reversed
                              .toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              floor = newValue!;
                            });
                          },
                        ),
                      )),
                  Container(
                    //submit button
                    margin: const EdgeInsets.only(bottom: 5),
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        widget.image.readAsBytes().then((value) async {
                          String b64 = base64.encode(value);
                          final Map<String, dynamic> data = {
                            'image': b64,
                            'x': x,
                            'y': y,
                            'floor': floor,
                          };

                          try {
                            final response = await http.post(
                              Uri.parse("$serverIP/create_question"),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode(data)
                            );

                            if (response.statusCode == 200) {
                              final String qid = json.decode(response.body)["id"];
                              await QuestionDatabase.instance.insertQuestion(qid,
                                jsonEncode({
                                  "x-coordinate": x,
                                  "y-coordinate": y,
                                  "floor": floor
                                }),
                                await saveImageToStorageFromBytes(b64, qid)
                              );
                              Fluttertoast.showToast(
                                msg: "Successfully Created New Question"
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: "Error Creating New Question"
                              );
                            }
                          } on SocketException {
                            Fluttertoast.showToast(
                              msg: "Error Connecting to Server"
                            );
                          } catch (e) {
                            print(e);
                          }
                        })
                        .then((value) {
                          Navigator.pop(context);
                        });
                      },
                      child: const Center(
                        child: Text(
                          'Submit',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ))
      ],
    );
  }
}

