import 'package:athena/helper/helper.dart';
import 'package:athena/models/questions.dart';

// import 'package:athena/service/database.dart';
import 'package:athena/views/quiz_play_widget.dart';
// import 'package:athena/views/result.dart';
import 'package:athena/widget/widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PlayQuiz extends StatefulWidget {
  final String quizId;
  PlayQuiz(this.quizId);
  @override
  _PlayQuizState createState() => _PlayQuizState();
}

Map userResultMap = {};
String api_token;

class _PlayQuizState extends State<PlayQuiz> {
  // DatabaseService databaseService = new DatabaseService();

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
    storeapi();
    getdata();
    super.initState();
  }

  storeapi() async {
    api_token = await HelperFunctions.getUserApiKey();
    if (api_token == '') {
      await HelperFunctions.saveUserLoggedIn(false);
    }
  }

  getdata() async {
    Response response = await Dio().get(
        "http://192.168.43.109/flutter/public/api/question/get/" +
            api_token +
            "/" +
            widget.quizId);
    setState(() {
      questionSnapshot = response.data['data'];
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
          Response response = await Dio().post(
              "http://192.168.43.109/flutter/public/api/result/get/" +
                  api_token,
              data: {
                "data": userResultMap,
                'quizId': widget.quizId,
              });
          print(response);
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

            if (widget.questionModel.option1 ==
                widget.questionModel.correctOption) {
              optionSelected = widget.questionModel.option1;
              widget.questionModel.answred = true;
              // _correct = _correct + 1;
              // _notAttempted = _notAttempted + 1;
              setState(() {});
            } else {
              optionSelected = widget.questionModel.option1;
              widget.questionModel.answred = true;
              // _incorrect = _incorrect + 1;
              // _notAttempted = _notAttempted + 1;
              setState(() {});
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
