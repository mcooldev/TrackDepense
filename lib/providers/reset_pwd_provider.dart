import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:track_depenses/helpers/firebaseHelper/firebase_service.dart';

class ResetPasswordProvider with ChangeNotifier {
  final auth = Authentication.instance;
  final resetEmailController = TextEditingController();
  bool isLoading = false;

  Future<void> resetPassword(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      await auth.resetPassword(resetEmailController.text.trim());
      //
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Un lien a été envoyé à votre adresse mail."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        //
        Navigator.pop(context);
        //
        resetEmailController.clear();
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(e.message ?? "Une erreur est survenue."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
