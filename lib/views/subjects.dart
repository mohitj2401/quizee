import 'package:quizie/constant/constant.dart';
import 'package:quizie/helper/helper.dart';
import 'package:quizie/views/home.dart';
import 'package:quizie/views/myaccount.dart';
import 'package:quizie/views/played_quiz.dart';
import 'package:quizie/views/signin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

class Subjects extends StatefulWidget {
  final String message;

  Subjects({@required this.message});
  @override
  _SubjectsState createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  TextEditingController searchSubject = TextEditingController();
  List subjectsGet = [];
  bool notified = false;
  String api_token;

  Future getDataFun;
  final formKey = GlobalKey<FormState>();
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
    if (widget.message != '' && !notified) {
      Future(() {
        final snackBar = SnackBar(content: Text(widget.message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
    getDataFun = getData();
    super.initState();
  }

  getData() async {
    var api = await HelperFunctions.getUserApiKey();
    if (api != null || api != '') {
      String url = base_url + "/api/subjects/get/" + api_token;

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
    }
  }

  updateData(url) async {
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
      } else {}
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
  }

  Future<Null> _handleRefresh() async {
    setState(() {
      getDataFun = getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subjects',
          style: TextStyle(color: Colors.blueAccent, fontSize: 22),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () async {
              NAlertDialog(
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: searchSubject,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter subject name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Subject Name",
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      child: Text("Search"),
                      onPressed: () async {
                        if (formKey.currentState.validate()) {
                          Navigator.pop(context);

                          String url = base_url +
                              "/api/subjects/search/" +
                              api_token +
                              '/' +
                              searchSubject.text;
                          setState(() {
                            searchSubject.text = '';
                            getDataFun = updateData(url);
                          });
                        }
                      }),
                ],
              ).show(context);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 25),
              child: Icon(
                Icons.search,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                getDataFun = getData();
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(
                Icons.refresh,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) async {
          if (index == 2) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MyAccount(
                          message: '',
                        )));
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
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: FutureBuilder(
            future: getDataFun,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  List subjectsGet = snapshot.data;
                  return ListView.builder(
                      itemCount: subjectsGet.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home(
                                        subject_id: subjectsGet[index]['id'])));
                          },
                          leading: Icon(Icons.subject),
                          title: Text(subjectsGet[index]['name']),
                          subtitle: Text(subjectsGet[index]['code']),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF303030),
                            size: 20,
                          ),
                        );
                      });
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  return Center(
                      child: Text(
                    'No result Found',
                  ));
                }
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
