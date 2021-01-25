import 'package:athena/helper/helper.dart';
import 'package:athena/views/home.dart';
import 'package:athena/views/signin.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
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
    // bool loggedData = await HelperFunctions.getUserLoggedIn();
    // print(loggedData);
    // if (loggedData != null) {
    //   setState(() {
    //     _isLoggedIn = loggedData;
    //     isLoading = false;
    //   });
    // } else {
    //   await HelperFunctions.saveUserLoggedIn(false);
    //   setState(() {
    //     _isLoggedIn = false;
    //     isLoading = false;
    //   });
    // }
  }

  // checkstatus() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     setState(() {
  //       _connected = true;
  //     });
  //   } else {
  //     setState(() {
  //       _connected = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // checkstatus();
    return MaterialApp(
        title: 'Athena',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home:
            // _connected
            //     ?
            isLoading
                ? Container(
                    color: Colors.white,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _isLoggedIn
                    ? Home()
                    : SignIn()
        // : Scaffold(
        //     appBar: AppBar(
        //       title: Center(
        //           child: Text(
        //         "Athena",
        //         style: TextStyle(color: Colors.blue, fontSize: 24),
        //       )),
        //       backgroundColor: Colors.white,
        //       elevation: 0.0,
        //     ),
        //     body: Container(
        //       color: Colors.white,
        //       child: Center(
        //           child: Text(
        //         "Opps! Please Check Your Connectivity",
        //         style: TextStyle(color: Colors.black, fontSize: 17),
        //       )),
        //     ),
        //   ),
        );
  }
}
