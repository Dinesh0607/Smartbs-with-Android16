import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbs/models/user_model.dart';
import 'package:smartbs/utils/app_strings.dart';
import 'package:smartbs/utils/firebase_utility.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User> getActiveUser() async {
  return _auth.currentUser;
}

Future<User> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
      await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final User currentUser = _auth.currentUser;
  assert(user.uid == currentUser.uid);

  setUserData(user);
  // print('signInWithGoogle succeeded: $user');
  return user;
}

void setUserData(User user) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (user != null) {
    UserModel userModel = UserModel(
        displayName: user.displayName,
        email: user.email,
        emailVerified: user.emailVerified,
        memberSince: DateTime.now().toString(),
        phoneNumber: user.phoneNumber,
        photoURL: user.photoURL,
        uid: user.uid,
        isBlocked: 0,
        verified: true);
    FirebaseUtility().setUserData(user.uid, userModel.toJson());
    FirebaseUtility().setUserVerifed(user.uid, true, user.displayName);
    prefs.setString(AppStrings.USER_PREF_KEY, jsonEncode(userModel));
  }
}

void signOutGoogle() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await googleSignIn.signOut();
  prefs.remove(AppStrings.USER_PREF_KEY);
  print("User Sign Out");
}
