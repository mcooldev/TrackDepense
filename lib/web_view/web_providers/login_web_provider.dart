import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:track_depenses/helpers/error_helper.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/models/user_model.dart';

class LoginWebProvider with ChangeNotifier {
  //
  TextEditingController emailWebController = TextEditingController();
  TextEditingController passwordWebController = TextEditingController();

  //
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  //
  final pb = PocketBaseDb.instance;

  //
  Future<void> loginWeb(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) return;
    if (_isLoading) return;
    //
    _isLoading = true;
    notifyListeners();
    //
    try {
      final email = emailWebController.text.trim();
      final password = passwordWebController.text.trim();
      //
      final adminToLogin = UserModel(email: email, password: password);
      //
      await pb.loginUser(adminToLogin);
      //
      emailWebController.clear();
      passwordWebController.clear();
      notifyListeners();
      //
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/authGate');
    } catch (e) {
      log(e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ • ${parsePbError(e)}"),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            width: 400,
            shape: const StadiumBorder(),
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailWebController.dispose();
    passwordWebController.dispose();
    super.dispose();
  }
}
