// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class DatabaseService {
//   Future<void> addQuizData(Map quizData, String quizId) async {
//     await FirebaseFirestore.instance
//         .collection("Quiz")
//         .doc(quizId)
//         .set(quizData)
//         .catchError((e) => print(e.toString()));
//   }

//   Future<void> addQuestionData(Map questionData, String quizId) async {
//     await FirebaseFirestore.instance
//         .collection("Quiz")
//         .doc(quizId)
//         .collection("QNA")
//         .add(questionData)
//         .catchError((e) => print(e.toString()));
//   }

//   getQuizData(uid) async {
//     List<String> quizData = [];

//     QuerySnapshot snapshotUserInfo = await FirebaseFirestore.instance
//         .collection("users")
//         .doc(uid)
//         .collection("QuizResult")
//         .get()
//         .catchError((e) {
//       print(e.toString());
//     });
//     if (snapshotUserInfo.docs.length > 0) {
//       snapshotUserInfo.docs.forEach((element) {
//         quizData.add(element.data()['quizId']);
//       });
//       return FirebaseFirestore.instance
//           .collection("Quiz")
//           .where('quizId', whereNotIn: quizData)
//           .snapshots();
//     } else {
//       return FirebaseFirestore.instance.collection("Quiz").snapshots();
//     }
//   }

//   deleteQuiz(quizId) async {
//     await FirebaseFirestore.instance
//         .collection('Quiz')
//         .doc(quizId)
//         .collection("QNA")
//         .get()
//         .then((snapshot) {
//       for (DocumentSnapshot ds in snapshot.docs) {
//         ds.reference.delete();
//       }
//     });
//     await FirebaseFirestore.instance
//         .collection('Quiz')
//         .doc(quizId)
//         .get()
//         .then((res) {
//       // FirebaseStorage.instance
//       //     .getReferenceFromUrl(res.data()['quizImgUrl'])
//       //     .then((res) {
//       //   res.delete().then((res) {
//       //     print("Deleted!");
//       //   });
//       // });
//     });
//     await FirebaseFirestore.instance.collection("Quiz").doc(quizId).delete();
//   }

//   uploadUserInfo(userMap, uid) {
//     FirebaseFirestore.instance
//         .collection("users")
//         .doc(uid)
//         .set(userMap)
//         .catchError((e) {
//       print(e.toString());
//     });
//   }

//   Future<void> saveQuizResult(String uid, Map userResult) async {
//     await FirebaseFirestore.instance
//         .collection("users")
//         .doc(uid)
//         .collection("QuizResult")
//         .add(userResult)
//         .catchError((e) {
//       print(e.toString());
//     });
//   }

//   Future<QuerySnapshot> getUserByUserEmail(String userEmail) async {
//     return await FirebaseFirestore.instance
//         .collection("users")
//         .where("email", isEqualTo: userEmail)
//         .get();
//   }

//   changeUserName(String userid, String userName) async {
//     return await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userid)
//         .update({'name': userName});
//   }

//   getQuestionData(String quizId) async {
//     return FirebaseFirestore.instance
//         .collection("Quiz")
//         .doc(quizId)
//         .collection("QNA")
//         .get();
//   }

//   // getUserQuizData() async {
//   //   return FirebaseFirestore.instance
//   //       .collection("Quiz")
//   //       .where('quizId', isEqualTo: quizsesData)
//   //       .get();
//   // }
// }
