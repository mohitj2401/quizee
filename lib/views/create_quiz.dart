import 'dart:io';

import 'package:athena/helper/helper.dart';
// import 'package:athena/service/database.dart';
import 'package:athena/views/create_question.dart';
import 'package:athena/views/signin.dart';
import 'package:athena/widget/widget.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:random_string/random_string.dart';
import 'package:dio/dio.dart';

class CreateQuiz extends StatefulWidget {
  @override
  _CreateQuizState createState() => _CreateQuizState();
}

enum DialogAction { ok }

class _CreateQuizState extends State<CreateQuiz> {
  bool isLoading = false;
  String quizId;
  final formKey = GlobalKey<FormState>();
  // TextEditingController urlTextEditingController = new TextEditingController();
  TextEditingController titleTextEditingController =
      new TextEditingController();
  TextEditingController descriptionTextEditingController =
      new TextEditingController();

  // DatabaseService databaseService = new DatabaseService();

  File selectedImage;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = File(pickedFile.path);
    });
  }

  createQuiz() async {
    if (formKey.currentState.validate()) {
      if (selectedImage != null) {
        setState(() {
          isLoading = true;
        });

        try {
          FormData formData = FormData.fromMap({
            "title": titleTextEditingController.text,
            'description': descriptionTextEditingController.text,
            'image': await MultipartFile.fromFile(
              selectedImage.path,
            ),
          });
          Response response = await Dio().post(
              "http://192.168.137.143/flutter/public/api/quiz/create/1610699043LzzFWZHFKbaiatVLjO6kYvaWBJ6zFg",
              data: formData);
          // print(response.data['email']);
          // print(response);
          if (response.data['email'] != null) {
            print(response.data['email'][0].toString());
            setState(() {
              isLoading = false;
            });
          } else {
            if (response.data['status'] == '200') {
              quizId = response.data['quiz_id'].toString();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateQuestions(quizId)));
            } else if (response.data['status'] == '404') {
              HelperFunctions.saveUserApiKey('');
              HelperFunctions.saveUserLoggedIn(false);
              HelperFunctions.saveUserRole('');
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                  (context) => false);
            } else {
              setState(() {
                isLoading = false;
              });
            }
          }
        } catch (e) {
          print(e);
        }
        // Reference firebaseReference = FirebaseStorage.instance
        //     .ref()
        //     .child("quizimage")
        //     .child("${randomAlphaNumeric(9)}.jpg");

        // final UploadTask task = firebaseReference.putFile(selectedImage);

        // var downloadUrl = await (await task).ref.getDownloadURL();

        // quizId = randomAlphaNumeric(16);
        // Map<String, dynamic> quizMap = {
        //   "quizId": quizId,
        //   "quizImgUrl": downloadUrl,
        //   "quizTitle": titleTextEditingController.text,
        //   "quizDescription": descriptionTextEditingController.text,
        // };
        // await databaseService.addQuizData(quizMap, quizId).then((value) {
        //   setState(() {
        //     Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => CreateQuestions(quizId)));
        //   });
        // }).catchError((onError) {
        //   print(onError);
        //   HelperFunctions.saveUserLoggedIn(false);
        // });
      } else {
        print("no image uploaded");
        yesAbortDialog();
      }
    }
  }

  yesAbortDialog() async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text("Please Select an Image"),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(DialogAction.ok),
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
    return (action != null) ? action : DialogAction.ok;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMainWithoutSignout(context),
      body: isLoading
          ? Center(
              child: Container(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      // TextFormField(
                      //   validator: (value) {
                      //     if (value.isEmpty) {
                      //       return "Please Enter Url";
                      //     } else {
                      //       return null;
                      //     }
                      //   },
                      //   controller: urlTextEditingController,
                      //   decoration: InputDecoration(
                      //     hintText: "Quiz Image Url",
                      //   ),
                      // ),
                      GestureDetector(
                        onTap: () {
                          getImage();
                        },
                        child: selectedImage != null
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                height: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    selectedImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                height: 150,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please Enter Url";
                          } else {
                            return null;
                          }
                        },
                        controller: titleTextEditingController,
                        decoration: InputDecoration(
                          hintText: "Quiz Title",
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please Enter Description";
                          } else {
                            return null;
                          }
                        },
                        controller: descriptionTextEditingController,
                        decoration: InputDecoration(
                          hintText: "Quiz Description",
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      GestureDetector(
                        onTap: () {
                          createQuiz();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          width: MediaQuery.of(context).size.width - 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Create Quiz",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
