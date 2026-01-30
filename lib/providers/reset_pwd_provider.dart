import 'dart:developer';

import 'package:flutter/material.dart';

import '../helpers/pocketBaseHelper/pocketbase_db.dart';

class ResetPasswordProvider with ChangeNotifier {
  final newPwdController = TextEditingController();
  final confirmNewPwdController = TextEditingController();
  bool isLoading = false;
  final pb = PocketBaseDb.instance.pb;

  Future<void> resetPassword(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      //
      await pb
          .collection('users')
          .confirmPasswordReset(
            pb.authStore.token,
            newPwdController.text.trim(),
            confirmNewPwdController.text.trim(),
          );
      //
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎊✅🎉 • Mot de passe réinitialisé avec succès !",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
      //
      if (!context.mounted) return;
      Navigator.pop(context);
      //
      newPwdController.clear();
      confirmNewPwdController.clear();
      notifyListeners();
    } catch (e) {
      log(e.toString());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌⚠️❌ • Échec du reset du mot de passe !",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    newPwdController.dispose();
    confirmNewPwdController.dispose();
    super.dispose();
  }
}
