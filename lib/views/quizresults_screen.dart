// // import 'package:athena/service/database.dart';
// import 'package:athena/widget/widget.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class QuizResult extends StatefulWidget {
//   @override
//   _QuizResultState createState() => _QuizResultState();
// }

// class _QuizResultState extends State<QuizResult> {
//   List<Widget> data = [];
//   bool _isloading = true;
//   // DatabaseService databaseService = DatabaseService();
//   // FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//   @override
//   void initState() {
//     getData();
//     super.initState();
//   }

//   void getData() async {
//     List quizData = [];
//     // QuerySnapshot snapshotUserInfo = await FirebaseFirestore.instance
//     //     .collection("users")
//     //     .doc(firebaseAuth.currentUser.uid)
//     //     .collection("QuizResult")
//     //     .get()
//     //     .catchError((e) {
//     //   print(e.toString());
//     // });
//     // if (snapshotUserInfo.docs.length > 0) {
//     //   snapshotUserInfo.docs.forEach((element) {
//     //     quizData.add(element.data()['quizId']);
//     //   });
//     // }
//     // // print(quizsesData);

//     // QuerySnapshot snapshotUserAtemptedQuizName = await FirebaseFirestore
//     //     .instance
//     //     .collection("Quiz")
//     //     .where('quizId', whereIn: quizData)
//     //     .get();

//     // snapshotUserAtemptedQuizName.docs.forEach((element) {
//     //   var text = Container(
//     //     padding: EdgeInsets.all(10),
//     //     margin: EdgeInsets.all(10),
//     //     child: Text(
//     //       element.data()['quizTitle'],
//     //       style: TextStyle(color: Colors.black54, fontSize: 19),
//     //     ),
//     //   );

//     //   data.add(text);
//     });
//     setState(() {
//       _isloading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: appDrawer(context),
//       appBar: appBarMain(context),
//       body: _isloading
//           ? Container(
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             )
//           : Container(
//               color: Colors.white,
//               child: ListView(
//                 children: data,
//               ),
//             ),
//     );
//   }
// }
