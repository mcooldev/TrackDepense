import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helpers/firebaseHelper/firebase_service.dart';
import '../models/user_model.dart';

abstract class AuthenticationProvider with ChangeNotifier {
  //
  final auth = Authentication.instance;

  //
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //
  bool passwordObscure = true;
  bool confirmPasswordObscure = true;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  //
  void togglePasswordObscure() {
    passwordObscure = !passwordObscure;
    notifyListeners();
  }

  void toggleConfirmPasswordObscure() {
    confirmPasswordObscure = !confirmPasswordObscure;
    notifyListeners();
  }

  /// Disposer
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

/// Login provider
class LoginProvider extends AuthenticationProvider {
  //
  final loginFormKey = GlobalKey<FormState>();

  //
  Future<void> login(BuildContext context) async {
    if (loginFormKey.currentState!.validate()) {
      //
      _isLoading = true;
      notifyListeners();
      //
      try {
        //
        final newUserToLogin = UserModel(
          id: "",
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        //
        await auth.login(newUserToLogin);
        //
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "🎊✅🎉 • Vous êtes connecté !",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(90)),
            ),
          ),
        );
        //
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, "/authGate");
        //
        emailController.clear();
        passwordController.clear();
        //
        notifyListeners();
      } catch (e) {
        //
        _isLoading = false;
        notifyListeners();
        //
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌⚠️❌ • Identifiants incorrects/inexistants !",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(90)),
            ),
          ),
        );
        //
      } finally {}
    }
  }

  // Login with Google
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      //
      final userCredential = await auth.signInWithGoogle();
      //
      final user = userCredential?.user;
      if (user == null) return;
      //
      final firestore = FirebaseFirestore.instance;
      final addUserToFirestore = {
        "id": user.uid,
        "name": user.displayName,
        "email": user.email,
      };
      firestore.collection("users").doc(user.uid).set(addUserToFirestore);
      //
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎊✅🎉 • Vous êtes connecté !",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(90)),
          ),
        ),
      );
      //
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, "/authGate");
      //
    } catch (e) {
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Signup provider
class SignupProvider extends AuthenticationProvider {
  //
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //
  final signupFormKey = GlobalKey<FormState>();

  //
  Future<void> signup(BuildContext context) async {
    //
    final firestore = FirebaseFirestore.instance;
    //
    if (signupFormKey.currentState!.validate()) {
      //
      _isLoading = true;
      notifyListeners();
      //
      try {
        //
        final newUserToSignup = UserModel(
          id: "",
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          name: nameController.text.trim(),
        );
        //
        final userCredential = await auth.signup(newUserToSignup);
        //
        final user = userCredential.user;
        if (user == null) return;
        final addUserToFirestore = {
          "id": user.uid,
          "name": newUserToSignup.name,
          "email": newUserToSignup.email,
        };
        await firestore
            .collection("users")
            .doc(user.uid)
            .set(addUserToFirestore);
        //
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "🎊✅🎉 • Vous êtes connecté !",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(90)),
            ),
          ),
        );
        //
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, "/authGate");
        //
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        //
        notifyListeners();
      } catch (e) {
        throw Exception(e);
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Signup with Google
  Future<void> signupWithGoogle(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      //
      final userCredential = await auth.signInWithGoogle();
      //
      final user = userCredential?.user;
      if (user == null) return;
      //
      final firestore = FirebaseFirestore.instance;
      final addUserToFirestore = {
        "id": user.uid,
        "name": user.displayName,
        "email": user.email,
      };
      firestore.collection("users").doc(user.uid).set(addUserToFirestore);
      //
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🎊✅🎉 • Vous êtes connecté !"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(90)),
          ),
        ),
      );
      //
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, "/authGate");
      //
    } catch (e) {
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Disposer
  @override
  void dispose() {
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
