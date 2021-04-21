import 'dart:async';
import 'package:athena/helper/helper.dart';
import 'package:athena/views/play_quiz.dart';
import 'package:athena/views/quiz_detail.dart';
import 'package:athena/views/signin.dart';
import 'package:flutter/material.dart';
import 'package:athena/widget/dialog.dart';
import 'package:dio/dio.dart';
import 'package:ndialog/ndialog.dart';

class Home extends StatefulWidget {
  final int subject_id;
  Home({@required this.subject_id});
  @override
  _HomeState createState() => _HomeState();
}

String api_token;

class _HomeState extends State<Home> {
  StreamController _quizcontroller;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool notified = false;
  Widget quizList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: StreamBuilder(
        stream: _quizcontroller.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error);
          }

          if (snapshot.hasData && snapshot.data.length > 0) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  if (DateTime.parse(snapshot.data[index]['start_time'])
                      .isAfter(DateTime.now())) {
                    print(DateTime.parse(snapshot.data[index]['start_time']));
                  }
                  // if (DateTime.now() < (snapshot.data[index]['start_time'])) {
                  //   print("Yes");
                  // }
                  return QuizTile(
                    title: snapshot.data[index]['title'],
                    description: snapshot.data[index]['description'],
                    imgUrl: snapshot.data[index]['image'],
                    quizId: snapshot.data[index]['id'].toString(),
                    duration: snapshot.data[index]['duration'],
                    startDate:
                        DateTime.parse(snapshot.data[index]['start_time']),
                    func: _handleRefresh,
                  );
                },
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.active) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            return Container(
              alignment: Alignment.center,
              child: Text('No Quiz Available or refresh'),
            );
          }
          return Container(
            alignment: Alignment.center,
            child: Text('No Quiz Available or refresh'),
          );
        },
      ),
    );
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

    _quizcontroller = StreamController();

    loadPosts();

    super.initState();
  }

  getData() async {
    var api = await HelperFunctions.getUserApiKey();
    if (api != null || api != '') {
      String url = "http://192.168.43.109/flutter/public/api/quiz/get/" +
          widget.subject_id.toString() +
          '/' +
          api_token;

      try {
        Response response = await Dio().get(url);

        if (response.data['status'] == '200') {
          return response.data['data'];
        } else if (response.data['status'] == '404') {
          await HelperFunctions.saveUserLoggedIn(false);
          await HelperFunctions.saveUserApiKey("");
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignIn()),
              (route) => false);
        } else {
          authService.error = response.data['msg'];
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
    } else {
      await HelperFunctions.saveUserLoggedIn(false);
      await Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignIn()));
    }
  }

  loadPosts() async {
    getData().then((res) async {
      _quizcontroller.add(res);
      return res;
    });
  }

  Future<Null> _handleRefresh() async {
    ProgressDialog progressDialog =
        ProgressDialog(context, message: Text("Loading"));

    //You can set Message using this function
    // progressDialog.setTitle(Text("Loading"));

    progressDialog.show();
    getData().then((res) async {
      _quizcontroller.add(res);
      progressDialog.dismiss();

      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: appDrawer(context),
      appBar: AppBar(
        title: Center(
            child: Text(
          "Quizie",
          style: TextStyle(color: Colors.blue, fontSize: 24),
        )),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),

      body: Container(
        child: quizList(),
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final String imgUrl;
  final String title;
  final String quizId;
  final String description;
  final int duration;
  final DateTime startDate;

  final Function func;
  QuizTile({
    @required this.imgUrl,
    @required this.title,
    @required this.description,
    @required this.quizId,
    @required this.func,
    @required this.duration,
    @required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          // startDate.isBefore(DateTime.now())
          //     ?
          () {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => PlayQuiz(quizId, duration),
        //   ),
        // );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetails(quizId),
          ),
        );
      },
      // : null,
      child: Container(
        height: 150,
        margin: EdgeInsets.only(bottom: 8, top: 2),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                "http://192.168.43.109/flutter/storage/app/public/" + imgUrl,
                width: MediaQuery.of(context).size.width - 48,
                fit: BoxFit.cover,
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black26,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        )),
                    SizedBox(height: 6),
                    Text(description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        )),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
