import 'package:athena/helper/helper.dart';
import 'package:athena/views/change_pass.dart';
import 'package:athena/views/play_quiz.dart';
import 'package:athena/views/played_quiz.dart';
import 'package:athena/views/signin.dart';
import 'package:athena/views/subjects.dart';
import 'package:athena/views/update_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

String api_token;

class _MyAccountState extends State<MyAccount> {
  bool isLoading = true;
  bool isStarted = false;
  Map quizdetails = {};
  getData() async {
    var api = await HelperFunctions.getUserApiKey();
    if (api != null || api != '') {
      String url =
          "http://192.168.43.109/flutter/public/api/get/user/" + api_token;

      try {
        Response response = await Dio().get(url);
        print(response);
        if (response.data['status'] == '200') {
          quizdetails = response.data['user'];
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
        print(e);
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
          'My Account',
          style: TextStyle(color: Colors.blueAccent, fontSize: 22),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) async {
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => Subjects(message: '')));
          }
          if (index == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => PlayedQuiz()));
          }
          if (index == 3) {
            ProgressDialog progressDialog =
                ProgressDialog(context, message: Text("Logging Out"));

            progressDialog.show();
            await HelperFunctions.saveUserLoggedIn(false);
            await HelperFunctions.saveUserApiKey("");
            progressDialog.dismiss();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignIn()),
                (route) => false);
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined), label: 'Results'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined), label: 'Account'),
          BottomNavigationBarItem(
              icon: Icon(Icons.exit_to_app_outlined), label: 'Logout')
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.all(20),
              child: ListView(
                children: [
                  Center(
                      child: Icon(
                    Icons.person_rounded,
                    size: 100,
                  )),
                  Spacer(),
                  Expanded(
                    child: Row(
                      children: [
                        Text('Name'),
                        Spacer(),
                        Text(quizdetails['name']),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Text('Email'),
                        Spacer(),
                        Text(quizdetails['email']),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Text('Quiz Attempted'),
                        Spacer(),
                        Text(quizdetails['result_count'].toString()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateDetails(),
                                ),
                              );
                            },
                            child: Text('Update Details'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePass(),
                                ),
                              );
                            },
                            child: Text('Change Password'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
