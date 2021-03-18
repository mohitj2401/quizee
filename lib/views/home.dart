import 'dart:async';
import 'package:athena/helper/helper.dart';
import 'package:athena/views/create_quiz.dart';
import 'package:athena/views/play_quiz.dart';
import 'package:athena/views/signin.dart';
import 'package:flutter/material.dart';
import 'package:athena/widget/dialog.dart';
import 'package:dio/dio.dart';
import 'package:ndialog/ndialog.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

String api_token;

class _HomeState extends State<Home> {
  StreamController _quizcontroller;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  static String userRole;

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
                  return QuizTile(
                    title: snapshot.data[index]['title'],
                    description: snapshot.data[index]['description'],
                    imgUrl: snapshot.data[index]['image'],
                    quizId: snapshot.data[index]['id'].toString(),
                    userRole: userRole,
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
      await HelperFunctions.saveUserRole("");
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
      await HelperFunctions.getUserRole().then((value) {
        setState(() {
          userRole = value;
        });
      });

      String url =
          "http://192.168.137.1/flutter/public/api/quiz/get/" + api_token;

      try {
        Response response = await Dio().get(url);
        // print(response.data['email']);
        // authService.error = null;

        if (response.data['email'] != null) {
          authService.error = response.data['email'][0].toString();
        } else {
          if (response.data['status'] == '200') {
            return response.data['data'];
          } else {
            authService.error = response.data['msg'];
          }
        }
      } catch (e) {
        print(e);
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
      await HelperFunctions.saveUserRole("");
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
            "Athena",
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
            GestureDetector(
              onTap: () async {
                await HelperFunctions.saveUserRole("");
                await HelperFunctions.saveUserLoggedIn(false);
                await HelperFunctions.saveUserApiKey("");
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                    (route) => false);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app),
              ),
            ),
          ],
        ),
        body: Container(
          child: quizList(),
        ),
        floatingActionButton: userRole != "student"
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CreateQuiz()));
                },
              )
            : null);
  }
}

class QuizTile extends StatelessWidget {
  final String imgUrl;
  final String title;
  final String quizId;
  final String description;
  final String userRole;
  final Function func;
  QuizTile({
    @required this.imgUrl,
    @required this.title,
    @required this.description,
    @required this.quizId,
    @required this.userRole,
    @required this.func,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        if (userRole != "student") {
          await DialogBackground(
            dialog: AlertDialog(
              title: Text("Delete Quiz"),
              content: Text("Are You Sure?."),
              actions: <Widget>[
                TextButton(
                    child: Text("Yes"),
                    onPressed: () async {
                      try {
                        Response response = await Dio().post(
                          "http://192.168.137.1/flutter/public/api/quiz/delete/" +
                              api_token +
                              '/' +
                              quizId,
                        );

                        // print(response.data['email']);

                        if (response.data['email'] != null) {
                          print(response.data['email'][0].toString());
                        } else {
                          if (response.data['status'] == '200') {
                            Navigator.pop(context);
                            func();
                          } else if (response.data['status'] == '404') {
                            HelperFunctions.saveUserApiKey('');
                            HelperFunctions.saveUserLoggedIn(false);
                            HelperFunctions.saveUserRole('');
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignIn()),
                                (context) => false);
                          } else {}
                        }
                      } catch (e) {
                        print(e);
                        await NAlertDialog(
                          dismissable: false,
                          dialogStyle: DialogStyle(titleDivider: true),
                          title: Text("Opps Something Went Worng!"),
                          content: Text(
                              "Please check your connectivity and try Again.."),
                          actions: <Widget>[
                            TextButton(
                                child: Text("Ok"),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ],
                        ).show(context);
                      }
                    }),
                TextButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            ),
          ).show(context);
        }
      },
      onTap: () {
        if (userRole == "student") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayQuiz(quizId),
            ),
          );
        }
      },
      child: Container(
        height: 150,
        margin: EdgeInsets.only(bottom: 8, top: 2),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                "http://192.168.137.1/flutter/storage/app/public/" + imgUrl,
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
