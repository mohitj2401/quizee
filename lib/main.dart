import 'package:athena/helper/helper.dart';
import 'package:athena/views/home.dart';
import 'package:athena/views/signin.dart';
import 'package:athena/views/subjects.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // bool _connected = false;
  bool _isLoggedIn = false;
  bool isLoading = true;

  @override
  void initState() {
    userLoggedInStatus();

    super.initState();
  }

  userLoggedInStatus() async {
    var api = await HelperFunctions.getUserApiKey();

    if (api != null && api != '') {
      setState(() {
        _isLoggedIn = true;
        isLoading = false;
      });
    } else {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey('');
      setState(() {
        _isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isLoading
          ? Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isLoggedIn
              ? Subjects()
              : SignIn(),
    );
  }
}
