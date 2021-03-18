import 'dart:convert';

import 'package:athena/helper/helper.dart';
import 'package:athena/service/auth.dart';
import 'package:athena/service/database.dart';
import 'package:athena/views/home.dart';
import 'package:athena/views/signin.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthService authService = new AuthService();
  // DatabaseService databaseService = new DatabaseService();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  signUp() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        Response response = await Dio()
            .post("http://192.168.137.143/flutter/public/api/register", data: {
          "name": nameTextEditingController.text,
          "email": emailTextEditingController.text,
          "role": "student",
          'password': passwordTextEditingController.text,
        });
        print(response);
        if (response.data['email'] != null) {
          authService.error = response.data['email'][0].toString();
          print(response.data['email'][0].toString());
          setState(() {
            isLoading = false;
          });
        } else {
          if (response.data['status'] == '200') {
            authService.error = response.data['msg'];
            nameTextEditingController.text = '';
            emailTextEditingController.text = '';
            passwordTextEditingController.text = '';
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        }
      } catch (e) {
        print(e);
      }
      // await authService
      //     .signUpWithEmailAndPass(emailTextEditingController.text,
      //         passwordTextEditingController.text)
      //     .then((value) {
      //   if (value != null) {
      //     setState(() {
      //       isLoading = false;
      //     });
      //     Map<String, String> userInfoMap = {
      //       "name": nameTextEditingController.text,
      //       "email": emailTextEditingController.text,
      //       "role": "student",
      //     };
      //     FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      //     databaseService.uploadUserInfo(
      //         userInfoMap, firebaseAuth.currentUser.uid);
      //     HelperFunctions.saveUserLoggedIn(true);
      //     HelperFunctions.saveUserRole(userInfoMap['role']);

      //     Navigator.pushReplacement(
      //         context, MaterialPageRoute(builder: (context) => Home()));
      //   } else {
      //     setState(() {
      //       isLoading = false;
      //     });
      //   }
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Athena",
          style: TextStyle(color: Colors.blue, fontSize: 24),
        )),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 60,
                child: Form(
                  key: formKey,
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: <Widget>[
                          showAlert(),
                          Spacer(),
                          TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please Enter Name";
                              } else {
                                return null;
                              }
                            },
                            controller: nameTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Name",
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                                return null;
                              } else {
                                return "Enter correct email";
                              }
                            },
                            controller: emailTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Email",
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            obscureText: true,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please Enter Password";
                              } else {
                                return null;
                              }
                            },
                            controller: passwordTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Password",
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          GestureDetector(
                            onTap: () {
                              signUp();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              width: MediaQuery.of(context).size.width - 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Have An Account? ",
                                style: TextStyle(fontSize: 16),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignIn()));
                                },
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 60,
                          )
                        ],
                      )),
                ),
              ),
            ),
    );
  }

  Widget showAlert() {
    if (authService.error != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: Text(authService.error),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  authService.error = null;
                });
              },
            )
          ],
        ),
      );
    } else {
      return SizedBox(height: 0);
    }
  }
}
