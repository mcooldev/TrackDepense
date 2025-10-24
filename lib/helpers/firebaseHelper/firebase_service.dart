import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user_model.dart';

class Authentication {
  ///
  Authentication._();

  static final Authentication instance = Authentication._();

  ///
  final auth = FirebaseAuth.instance;

  // Login method
  Future<UserCredential> login(UserModel user) async {
    return await auth.signInWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );
  }

  // Signup method
  Future<UserCredential> signup(UserModel user) async {
    return await auth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );
  }

  // Sign in with Google method
  final GoogleSignIn gSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      if (!gSignIn.supportsAuthenticate()) return null;
      final GoogleSignInAccount? gUser = await gSignIn.authenticate();
      //
      if (gUser == null) return null;
      // Obtain the auth details from the request
      final GoogleSignInClientAuthorization? gAuth = await gUser
          .authorizationClient
          .authorizationForScopes(["email", "profile"]);
      final idToken = gUser.authentication.idToken;
      if (gAuth == null || idToken == null) {
        log(
          "Erreur: Autorisation refusée et impossible d'obtenir le jeton d'ID",
        );
        return null;
      }
      final accessToken = gAuth.accessToken;
      //
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw Exception(e);
    }
  }

  // Reset password method
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  // Sign out method
  Future<void> signOut() async {
    await auth.signOut();
  }
}
