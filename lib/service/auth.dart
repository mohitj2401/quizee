import 'package:athena/models/user.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  String error;

  // FirebaseAuth _auth = FirebaseAuth.instance;
  // UserModel _userFromFirebase(User user) {
  //   return user != null ? UserModel(uid: user.uid) : null;
  // }

  // Future signInEmailAndPass(String email, String password) async {
  //   try {
  //     UserCredential authResult = await _auth.signInWithEmailAndPassword(
  //         email: email, password: password);
  //     User firebaseUser = authResult.user;
  //     return _userFromFirebase(firebaseUser);
  //   } catch (e) {
  //     error = e.message;
  //     print(e.toString());
  //   }
  // }

  // Future changedPassword(String password) async {
  //   try {
  //     _auth.currentUser.updatePassword(password).catchError((onError) {
  //       print(onError.toString());
  //     });
  //   } catch (e) {
  //     error = e.message;
  //     print(e.toString());
  //   }
  // }

  // Future signUpWithEmailAndPass(String email, String password) async {
  //   try {
  //     UserCredential authResult = await _auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     User firebaseUser = authResult.user;
  //     return _userFromFirebase(firebaseUser);
  //   } catch (e) {
  //     error = e.message;
  //     print(e.toString());
  //   }
  // }

  // signOut() async {
  //   try {
  //     await _auth.signOut();
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
}
