import 'package:quizie/helper/helper.dart';
import 'package:quizie/service/auth.dart';
import 'package:quizie/views/signin.dart';
import 'package:quizie/views/subjects.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthService authService = new AuthService();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isHidden = true;
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();

  signUp() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        Response response = await Dio()
            .post("http://192.168.43.109/flutter/public/api/register", data: {
          "name": nameTextEditingController.text,
          "email": emailTextEditingController.text,
          'password': passwordTextEditingController.text,
        });

        if (response.data['email'] != null) {
          authService.error = response.data['email'][0].toString();

          setState(() {
            isLoading = false;
          });
        } else {
          if (response.data['status'] == '200') {
            await HelperFunctions.saveUserApiKey(response.data['api_token']);
            await HelperFunctions.saveUserLoggedIn(true);
            await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Subjects(message: 'Resgiter Successfully')));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Quizie",
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
                child: Form(
                  autovalidateMode: AutovalidateMode.always,
                  key: formKey,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: <Widget>[
                        showAlert(),
                        SizedBox(height: 20),
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Welcome to Quizie!',
                              textStyle: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                              speed: Duration(milliseconds: 100),
                            ),
                          ],
                          isRepeatingAnimation: true,
                          pause: Duration(milliseconds: 500),
                          displayFullTextOnTap: true,
                        ),
                        SizedBox(height: 50),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please Enter Name";
                            }

                            if (!RegExp(r"^[a-zA-Z][a-zA-Z ]+$")
                                .hasMatch(value)) {
                              return 'Please enter valid name';
                            }
                            return null;
                          },
                          controller: nameTextEditingController,
                          decoration: InputDecoration(
                              labelText: "Name",
                              icon: Icon(Icons.person_rounded)),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter email';
                            }
                            if (!RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                              return "Please enter valid email";
                            }
                            return null;
                          },
                          controller: emailTextEditingController,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.email_rounded,
                            ),
                            labelText: "Email",
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          obscureText: _isHidden,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please Enter Password";
                            }
                            if (!RegExp(
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                .hasMatch(value)) {
                              return 'Please enter strong password';
                            }
                            return null;
                          },
                          controller: passwordTextEditingController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock),
                            suffix: InkWell(
                              onTap: _togglePasswordView,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 20),
                                child: Icon(
                                  Icons.visibility,
                                  size: 24,
                                  color:
                                      _isHidden ? Colors.grey : Colors.blueGrey,
                                ),
                              ),
                            ),
                            labelText: "Password",
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
                              "Sign Up",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
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
                              "Already have an account? ",
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
                                "Sign in",
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
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
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
