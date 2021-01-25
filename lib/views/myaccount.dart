// import 'package:athena/helper/helper.dart';
// import 'package:athena/service/auth.dart';
// import 'package:athena/service/database.dart';
// import 'package:athena/widget/widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MyAccount extends StatefulWidget {
//   @override
//   _MyAccountState createState() => _MyAccountState();
// }

// class _MyAccountState extends State<MyAccount> {
//   bool isLoading = false;

//   String userName = "";
//   FirebaseAuth auth = FirebaseAuth.instance;
//   final formKey = GlobalKey<FormState>();
//   // AuthService authService = new AuthService();
//   TextEditingController emailTextEditingController = TextEditingController();
//   TextEditingController passwordTextEditingController = TextEditingController();
//   // DatabaseService databaseService = new DatabaseService();

//   // getNameUser() {
//   //   databaseService.getUserByUserEmail(auth.currentUser.email).then((value) {
//   //     QuerySnapshot snapshotUserInfo = value;

//   //     setState(() {
//   //       userName = snapshotUserInfo.docs[0].data()['name'];
//   //     });
//   //   });
//   // }

//   @override
//   void initState() {
//     getNameUser();

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: appDrawer(context),
//       appBar: appBarMain(context),
//       body: Container(
//           padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.account_circle),
//                   SizedBox(
//                     width: 24,
//                   ),
//                   Text(
//                     userName,
//                     style: TextStyle(fontSize: 18, color: Colors.black),
//                   ),
//                   Spacer(),
//                   GestureDetector(
//                     onTap: () {
//                       showModalBottomSheet<void>(
//                         isScrollControlled: true,
//                         context: context,
//                         builder: (BuildContext context) {
//                           return SingleChildScrollView(
//                             child: Container(
//                               padding: EdgeInsets.only(
//                                   bottom:
//                                       MediaQuery.of(context).viewInsets.bottom),
//                               color: Colors.amber,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 24, horizontal: 10),
//                                 child: Column(
//                                   children: <Widget>[
//                                     Text('Type Name'),
//                                     Container(
//                                       child: Form(
//                                         key: formKey,
//                                         child: Container(
//                                           child: TextFormField(
//                                             obscureText: true,
//                                             validator: (value) {
//                                               if (value.isEmpty) {
//                                                 return "Please Enter Name";
//                                               } else {
//                                                 return null;
//                                               }
//                                             },
//                                             controller:
//                                                 passwordTextEditingController,
//                                             decoration: InputDecoration(
//                                               hintText: "Password",
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     RaisedButton(
//                                       child: isLoading
//                                           ? CircularProgressIndicator()
//                                           : Text('Close BottomSheet'),
//                                       onPressed: isLoading
//                                           ? null
//                                           : () {
//                                               setState(() {
//                                                 isLoading = true;
//                                               });

//                                               if (formKey.currentState
//                                                   .validate()) {
//                                                 authService
//                                                     .changedPassword(
//                                                         passwordTextEditingController
//                                                             .text)
//                                                     .then((value) {
//                                                   setState(() {
//                                                     isLoading = false;
//                                                   });
//                                                   Navigator.pop(context);

//                                                   showMyDialog(context,
//                                                       "Password Changed SuccessFully");
//                                                   passwordTextEditingController
//                                                       .text = "";
//                                                 }).catchError((e) {
//                                                   HelperFunctions
//                                                       .saveUserLoggedIn(false);
//                                                   print("enter here");
//                                                 });
//                                               }
//                                             },
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: Icon(Icons.edit),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 24,
//               ),
//               Row(
//                 children: [
//                   Icon(Icons.lock),
//                   SizedBox(
//                     width: 24,
//                   ),
//                   Text(
//                     userName,
//                     style: TextStyle(fontSize: 18, color: Colors.black),
//                   ),
//                   Spacer(),
//                   GestureDetector(
//                     onTap: () {
//                       showModalBottomSheet<void>(
//                         isScrollControlled: true,
//                         context: context,
//                         builder: (BuildContext context) {
//                           return SingleChildScrollView(
//                             child: Container(
//                               padding: EdgeInsets.only(
//                                   bottom:
//                                       MediaQuery.of(context).viewInsets.bottom),
//                               color: Colors.amber,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 24, horizontal: 10),
//                                 child: Column(
//                                   children: <Widget>[
//                                     Text('Type New Password'),
//                                     Container(
//                                       child: Form(
//                                         key: formKey,
//                                         child: Container(
//                                           child: TextFormField(
//                                             obscureText: true,
//                                             validator: (value) {
//                                               if (value.isEmpty) {
//                                                 return "Please Enter Password";
//                                               } else {
//                                                 return null;
//                                               }
//                                             },
//                                             controller:
//                                                 passwordTextEditingController,
//                                             decoration: InputDecoration(
//                                               hintText: "Password",
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     RaisedButton(
//                                       child: isLoading
//                                           ? CircularProgressIndicator()
//                                           : Text('Close BottomSheet'),
//                                       onPressed: isLoading
//                                           ? null
//                                           : () {
//                                               setState(() {
//                                                 isLoading = true;
//                                               });

//                                               if (formKey.currentState
//                                                   .validate()) {
//                                                 authService
//                                                     .changedPassword(
//                                                         passwordTextEditingController
//                                                             .text)
//                                                     .then((value) {
//                                                   setState(() {
//                                                     isLoading = false;
//                                                   });
//                                                   Navigator.pop(context);

//                                                   showMyDialog(context,
//                                                       "Password Changed SuccessFully");
//                                                   passwordTextEditingController
//                                                       .text = "";
//                                                 }).catchError((e) {
//                                                   HelperFunctions
//                                                       .saveUserLoggedIn(false);
//                                                   print("enter here");
//                                                 });
//                                               }
//                                             },
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: Icon(Icons.edit),
//                   ),
//                 ],
//               ),
//             ],
//           )),
//     );
//   }
// }
