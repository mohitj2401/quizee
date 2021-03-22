import 'package:athena/service/database.dart';
import 'package:athena/views/home.dart';
import 'package:athena/views/signin.dart';
import 'package:athena/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:athena/helper/helper.dart';

class CreateQuestions extends StatefulWidget {
  final String quizId;
  CreateQuestions(this.quizId);
  @override
  _CreateQuestionsState createState() => _CreateQuestionsState();
}

class _CreateQuestionsState extends State<CreateQuestions> {
  bool imagedQuestions = false;

  final formKey = GlobalKey<FormState>();
  TextEditingController questionTextEditingController =
      new TextEditingController();
  TextEditingController option1TextEditingController =
      new TextEditingController();
  TextEditingController option2TextEditingController =
      new TextEditingController();
  TextEditingController option3TextEditingController =
      new TextEditingController();
  TextEditingController option4TextEditingController =
      new TextEditingController();
  bool isLoading = false;
  // DatabaseService databaseService = new DatabaseService();

  uploadQuizData(String choice) async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        FormData formData = FormData.fromMap({
          "question": questionTextEditingController.text,
          "option1": option1TextEditingController.text,
          "option2": option2TextEditingController.text,
          "option3": option3TextEditingController.text,
          "option4": option4TextEditingController.text,
        });

        Response response = await Dio().post(
            "http://192.168.137.139/flutter/public/api/question/create/1610699043LzzFWZHFKbaiatVLjO6kYvaWBJ6zFg/" +
                widget.quizId,
            data: formData);

        // print(response.data['email']);
        // print(response);
        if (response.data['email'] != null) {
          // print(response.data['email'][0].toString());
          setState(() {
            isLoading = false;
          });
        } else {
          if (response.data['status'] == '200') {
            if (choice == "sub") {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (context) => false);
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateQuestions(widget.quizId)));
            }
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
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMainWithoutSignout(context),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please Enter Question";
                            } else {
                              return null;
                            }
                          },
                          controller: questionTextEditingController,
                          decoration: InputDecoration(
                            hintText: "Question",
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please Enter ";
                            } else {
                              return null;
                            }
                          },
                          controller: option1TextEditingController,
                          decoration: InputDecoration(
                            hintText: "Option 1 (Correct Answer)",
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
                          controller: option2TextEditingController,
                          decoration: InputDecoration(
                            hintText: "Option 2",
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
                          controller: option3TextEditingController,
                          decoration: InputDecoration(
                            hintText: "Option 3",
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Option 1 (Corrent Answer)";
                            } else {
                              return null;
                            }
                          },
                          controller: option4TextEditingController,
                          decoration: InputDecoration(
                            hintText: "Option 4",
                          ),
                        ),
                        SizedBox(height: 50),
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                uploadQuizData("sub");
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                width:
                                    MediaQuery.of(context).size.width / 2 - 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            GestureDetector(
                              onTap: () {
                                uploadQuizData("more");
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                width:
                                    MediaQuery.of(context).size.width / 2 - 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  "Add Question",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
    );
  }
}
