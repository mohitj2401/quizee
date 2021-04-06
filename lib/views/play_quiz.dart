import 'dart:convert';
import 'package:athena/helper/helper.dart';
import 'package:athena/models/questions.dart';
import 'package:athena/views/subjects.dart';
import 'package:ndialog/ndialog.dart';
import 'package:athena/views/quiz_play_widget.dart';
import 'package:athena/views/signin.dart';
import 'package:athena/widget/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PlayQuiz extends StatefulWidget {
  final String quizId;
  PlayQuiz(this.quizId);
  @override
  _PlayQuizState createState() => _PlayQuizState();
}

Map userResultMap = {};
int total = 0, _correct = 0, _incorrect = 0, _notAttempted = 0;

class _PlayQuizState extends State<PlayQuiz> {
  // DatabaseService databaseService = new DatabaseService();
  String apiToken;

  List questionSnapshot;

  QuestionModel getQuestionModelFromDataSnapshot(questionSnapshot) {
    QuestionModel questionModel = new QuestionModel();
    questionModel.question = questionSnapshot['title'];
    questionModel.questionId = questionSnapshot['id'];
    List<String> options = [
      questionSnapshot['option1'],
      questionSnapshot['option2'],
      questionSnapshot['option3'],
      questionSnapshot['option4'],
    ];

    options.shuffle();
    questionModel.option1 = options[0];
    questionModel.option2 = options[1];
    questionModel.option3 = options[2];
    questionModel.option4 = options[3];
    questionModel.answred = false;
    questionModel.correctOption = questionSnapshot['option1'];
    return questionModel;
  }

  @override
  void initState() {
    loadQuestions();
    super.initState();
  }

  getdata() async {
    await HelperFunctions.getUserApiKey().then((value) {
      setState(() {
        apiToken = value;
      });
    });

    if (apiToken == '' || apiToken == null) {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey("");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => SignIn()), (route) => false);
    }
    String url = apiToken + "/" + widget.quizId;
    Response response = await Dio()
        .get("http://192.168.137.1/flutter/public/api/question/get/" + url);
    return response.data['data'];
  }

  loadQuestions() async {
    getdata().then((res) async {
      setState(() {
        questionSnapshot = res;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: questionSnapshot != null
            ? ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24),
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: questionSnapshot.length,
                itemBuilder: (context, index) {
                  _notAttempted = questionSnapshot.length;
                  total = questionSnapshot.length;
                  return QuizPlayTile(
                      questionModel: getQuestionModelFromDataSnapshot(
                          questionSnapshot[index]),
                      index: index);
                },
              )
            : Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          CustomProgressDialog progressDialog =
              CustomProgressDialog(context, blur: 10);

          progressDialog.show();
          List userResultList = [];
          userResultMap.forEach((key, value) {
            userResultList.add({
              'id': key,
              'answer': value,
            });
          });

          try {
            Response response = await Dio().post(
                "http://192.168.137.1/flutter/public/api/result/store/" +
                    apiToken,
                data: {
                  "data1": jsonEncode(userResultList),
                  'quizId': widget.quizId,
                  'total': total,
                  'correct': _correct,
                  'incorrect': _incorrect,
                  'notAttempted': _notAttempted,
                });
            userResultMap = {};
            total = 0;
            _correct = 0;
            _incorrect = 0;
            _notAttempted = 0;
            if (response.data['status'] == '200') {
              userResultList = [];

              progressDialog.dismiss();
              NAlertDialog(
                blur: 10,
                dismissable: false,
                dialogStyle: DialogStyle(),
                title: Text("Your Quiz is Completed"),
              ).show(context);
              await Future.delayed(Duration(seconds: 2));
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Subjects(message: 'Quiz Attempted')),
                  (route) => false);
            } else {
              progressDialog.dismiss();
              await NAlertDialog(
                dismissable: false,
                dialogStyle: DialogStyle(titleDivider: true),
                title: Text("Opps Something Went Worng!"),
                content: Text("Please check your connectivity and try Again.."),
                actions: <Widget>[
                  TextButton(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ).show(context);
            }
          } catch (e) {
            await NAlertDialog(
              dismissable: false,
              dialogStyle: DialogStyle(titleDivider: true),
              title: Text("Opps Something Went Worng!"),
              content: Text("Please check your connectivity and try Again.."),
              actions: <Widget>[
                TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            ).show(context);
          }
        },
      ),
    );
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  QuizPlayTile({this.questionModel, this.index});

  @override
  _QuizPlayTileState createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile> {
  String optionSelected = "";
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Q${widget.index + 1} " + widget.questionModel.question,
          style: TextStyle(
            fontSize: 17,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            userResultMap.addAll({
              widget.questionModel.questionId: widget.questionModel.option1,
            });
            if (widget.questionModel.answred) {
              if (widget.questionModel.option1 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option1;

                _correct = _correct + 1;
                _incorrect = _incorrect - 1;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option1;

                _incorrect = _incorrect + 1;
                _correct = _correct - 1;

                setState(() {});
              }
            } else {
              if (widget.questionModel.option1 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option1;
                widget.questionModel.answred = true;
                _correct = _correct + 1;
                _notAttempted = _notAttempted - 1;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option1;
                widget.questionModel.answred = true;
                _incorrect = _incorrect + 1;
                _notAttempted = _notAttempted - 1;

                setState(() {});
              }
            }
          },
          child: QuestionTile(
            correctAnswer: widget.questionModel.correctOption,
            description: widget.questionModel.option1,
            optionSelcted: optionSelected,
            option: "A",
          ),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            userResultMap.addAll({
              widget.questionModel.questionId: widget.questionModel.option2,
            });
            if (widget.questionModel.answred) {
              if (widget.questionModel.option2 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option2;

                _correct = _correct + 1;
                _incorrect = _incorrect - 1;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option2;

                _incorrect = _incorrect + 1;
                _correct = _correct - 1;

                setState(() {});
              }
            } else {
              if (widget.questionModel.option2 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option2;
                widget.questionModel.answred = true;
                _correct = _correct + 1;
                _notAttempted = _notAttempted - 1;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option2;
                widget.questionModel.answred = true;
                _incorrect = _incorrect + 1;
                _notAttempted = _notAttempted - 1;

                setState(() {});
              }
            }
          },
          child: QuestionTile(
            correctAnswer: widget.questionModel.correctOption,
            description: widget.questionModel.option2,
            optionSelcted: optionSelected,
            option: "B",
          ),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            userResultMap.addAll({
              widget.questionModel.questionId: widget.questionModel.option3,
            });
            if (widget.questionModel.answred) {
              if (widget.questionModel.option3 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option3;

                _correct = _correct + 1;
                _incorrect = _incorrect - 1;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option3;

                _incorrect = _incorrect + 1;
                _correct = _correct - 1;

                setState(() {});
              }
            } else {
              if (widget.questionModel.option3 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option3;
                widget.questionModel.answred = true;
                _correct = _correct + 1;
                _notAttempted = _notAttempted - 1;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option3;
                widget.questionModel.answred = true;
                _incorrect = _incorrect + 1;
                _notAttempted = _notAttempted - 1;

                setState(() {});
              }
            }
          },
          child: QuestionTile(
            correctAnswer: widget.questionModel.correctOption,
            description: widget.questionModel.option3,
            optionSelcted: optionSelected,
            option: "C",
          ),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            userResultMap.addAll({
              widget.questionModel.questionId: widget.questionModel.option4,
            });
            if (widget.questionModel.answred) {
              if (widget.questionModel.option4 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option4;

                _correct = _correct + 1;
                _incorrect = _incorrect - 1;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option4;

                _incorrect = _incorrect + 1;
                _correct = _correct - 1;

                setState(() {});
              }
            } else {
              if (widget.questionModel.option4 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option4;
                widget.questionModel.answred = true;
                _correct = _correct + 1;
                _notAttempted = _notAttempted - 1;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option4;
                widget.questionModel.answred = true;
                _incorrect = _incorrect + 1;
                _notAttempted = _notAttempted - 1;

                setState(() {});
              }
            }
          },
          child: QuestionTile(
            correctAnswer: widget.questionModel.correctOption,
            description: widget.questionModel.option4,
            optionSelcted: optionSelected,
            option: "D",
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
