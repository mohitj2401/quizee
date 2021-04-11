import 'dart:convert';
import 'package:athena/helper/helper.dart';
import 'package:athena/models/questions.dart';
import 'package:athena/views/subjects.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:ndialog/ndialog.dart';
import 'package:athena/views/quiz_play_widget.dart';
import 'package:athena/views/signin.dart';
import 'package:athena/widget/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class PlayQuiz extends StatefulWidget {
  final String quizId;
  PlayQuiz(this.quizId);
  @override
  _PlayQuizState createState() => _PlayQuizState();
}

Map userResultMap = {};

class _PlayQuizState extends State<PlayQuiz> with WidgetsBindingObserver {
  // DatabaseService databaseService = new DatabaseService();
  get wantKeepAlive => true;
  String apiToken;
  int alertCount = 3;
  List questionSnapshot;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 210;
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
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    loadQuestions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      if (alertCount != 0) {
        await NAlertDialog(
          dismissable: false,
          dialogStyle: DialogStyle(titleDivider: true),
          title: Text("Abnormal Activity Detected"),
          content: Text("Remaing Abnormal Activity is $alertCount"),
          actions: <Widget>[
            TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ).show(context);
        alertCount--;
      } else {
        submitQuiz();
      }
    }
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

  submitQuiz() async {
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
          "http://192.168.137.1/flutter/public/api/result/store/" + apiToken,
          data: {
            "data1": jsonEncode(userResultList),
            'quizId': widget.quizId,
          });

      userResultMap = {};

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
                builder: (context) => Subjects(message: 'Quiz Attempted')),
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
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: questionSnapshot != null
            ? Column(
                children: [
                  CountdownTimer(
                    endTime: endTime,
                    widgetBuilder: (_, CurrentRemainingTime time) {
                      if (time == null || time.sec < 5 && time.min == null) {
                        return Text(
                          'Quiz is going to submit',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 21,
                          ),
                        );
                      }
                      if (time.sec < 25 && time.min == null) {
                        return Text(
                          'Quiz is going to submit after ${time.sec} sec',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 21,
                          ),
                        );
                      }
                      return Text(
                          'Remaning Time:- ${time.min ?? '00'}:${time.sec} ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 21,
                          ));
                    },
                    onEnd: submitQuiz,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      physics: ClampingScrollPhysics(),
                      itemCount: questionSnapshot.length,
                      itemBuilder: (context, index) {
                        return QuizPlayTile(
                            questionModel: getQuestionModelFromDataSnapshot(
                                questionSnapshot[index]),
                            index: index);
                      },
                    ),
                  ),
                ],
              )
            : Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: submitQuiz,
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

class _QuizPlayTileState extends State<QuizPlayTile>
    with AutomaticKeepAliveClientMixin {
  get wantKeepAlive => true;
  String optionSelected = "";
  @override
  Widget build(BuildContext context) {
    super.build(context);
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

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option1;

                setState(() {});
              }
            } else {
              if (widget.questionModel.option1 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option1;
                widget.questionModel.answred = true;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option1;
                widget.questionModel.answred = true;

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

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option2;

                setState(() {});
              }
            } else {
              if (widget.questionModel.option2 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option2;
                widget.questionModel.answred = true;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option2;
                widget.questionModel.answred = true;

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

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option3;

                setState(() {});
              }
            } else {
              if (widget.questionModel.option3 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option3;
                widget.questionModel.answred = true;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option3;
                widget.questionModel.answred = true;

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

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option4;

                setState(() {});
              }
            } else {
              if (widget.questionModel.option4 ==
                  widget.questionModel.correctOption) {
                optionSelected = widget.questionModel.option4;
                widget.questionModel.answred = true;

                setState(() {});
              } else {
                optionSelected = widget.questionModel.option4;
                widget.questionModel.answred = true;

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
