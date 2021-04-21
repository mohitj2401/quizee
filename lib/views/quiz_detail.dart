import 'package:athena/helper/helper.dart';
import 'package:athena/views/signin.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ndialog/ndialog.dart';
import 'package:athena/views/play_quiz.dart';

class QuizDetails extends StatefulWidget {
  final String quizId;

  QuizDetails(this.quizId);

  @override
  _QuizDetailsState createState() => _QuizDetailsState();
}

String api_token;

class _QuizDetailsState extends State<QuizDetails> {
  bool isLoading = true;
  bool isStarted = false;
  Map quizdetails = {};
  getData() async {
    var api = await HelperFunctions.getUserApiKey();
    if (api != null || api != '') {
      String url = "http://192.168.43.109/flutter/public/api/quiz/get/" +
          widget.quizId +
          "/" +
          api_token;

      try {
        Response response = await Dio().get(url);

        if (response.data['status'] == '200') {
          quizdetails = response.data['data'][0];
          if (DateTime.parse(quizdetails['start_time'])
                  .isBefore(DateTime.now()) &&
              DateTime.parse(quizdetails['end_time']).isAfter(DateTime.now())) {
            isStarted = true;
          }
          setState(() {
            isLoading = false;
          });
        } else if (response.data['status'] == '404') {
          await HelperFunctions.saveUserLoggedIn(false);
          await HelperFunctions.saveUserApiKey("");
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignIn()),
              (route) => false);
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

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
    }
  }

  storeapi() async {
    api_token = await HelperFunctions.getUserApiKey();

    if (api_token == '' || api_token == null) {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey("");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => SignIn()), (route) => false);
    }
  }

  @override
  void initState() {
    storeapi();
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Details',
          style: TextStyle(color: Colors.blueAccent, fontSize: 22),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () async {
              setState(() {
                isLoading = true;
              });

              getData();
            },
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(
                Icons.refresh,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: isStarted
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayQuiz(
                              quizdetails['id'].toString(),
                              quizdetails['duration']),
                        ),
                      );
                    }
                  : null,
              child: Text('Start'),
            ),
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.all(20),
              child: ListView(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        "http://192.168.43.109/flutter/storage/app/public/" +
                            quizdetails['image'],
                        width: MediaQuery.of(context).size.width - 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      quizdetails['title'],
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: RichText(
                      text: TextSpan(
                        text: "Description  :-  ",
                        style: TextStyle(color: Colors.black87, fontSize: 20),
                        children: [
                          TextSpan(
                              text: quizdetails['description'],
                              style: TextStyle(
                                  wordSpacing: 5,
                                  color: Colors.black45,
                                  fontSize: 16))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Start Time',
                            style: TextStyle(
                                wordSpacing: 5,
                                color: Colors.black45,
                                fontSize: 16)),
                        Text(
                            DateFormat('dd MMMM , yyyy hh:mm aaa')
                                .format(
                                    DateTime.parse(quizdetails['start_time']))
                                .toString(),
                            style: TextStyle(
                                wordSpacing: 5,
                                color: Colors.black45,
                                fontSize: 16))
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('End Time',
                            style: TextStyle(
                                wordSpacing: 5,
                                color: Colors.black45,
                                fontSize: 16)),
                        Text(
                            DateFormat('dd MMMM , yyyy hh:mm aaa')
                                .format(DateTime.parse(quizdetails['end_time']))
                                .toString(),
                            style: TextStyle(
                                wordSpacing: 5,
                                color: Colors.black45,
                                fontSize: 16))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: isStarted
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayQuiz(
                                      quizdetails['id'].toString(),
                                      quizdetails['duration']),
                                ),
                              );
                            }
                          : null,
                      child: Text('Start'),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
