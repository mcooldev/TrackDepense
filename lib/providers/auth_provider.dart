import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:track_depenses/helpers/error_helper.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';

import '../models/user_model.dart';

abstract class AuthenticationProvider with ChangeNotifier {
  //
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pb = PocketBaseDb.instance;

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
    if (!loginFormKey.currentState!.validate()) return;
    //
    _isLoading = true;
    notifyListeners();
    //
    try {
      final newUserToLogin = UserModel(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await pb.loginUser(newUserToLogin);

      final currentUser = pb.pb.authStore.record;
      if (currentUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      ///
      if (!kIsWeb) {
        String? deviceId;
        if (Platform.isAndroid) {
          final deviceInfo = await deviceInfoPlugin.androidInfo;
          deviceId = deviceInfo.id;
        } else if (Platform.isIOS) {
          final deviceInfo = await deviceInfoPlugin.iosInfo;
          deviceId = deviceInfo.identifierForVendor;
        }

        ///
        String storedDeviceId = currentUser.getStringValue("deviceId");
        if (storedDeviceId.isEmpty) {
          await pb.pb
              .collection('users')
              .update(currentUser.id, body: {"deviceId": deviceId});
        } else if (storedDeviceId != deviceId) {
          pb.pb.authStore.clear();
          _isLoading = false;
          notifyListeners();
          //
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "❌ • Vous êtes déjà connecté sur un autre appareil",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: const StadiumBorder(),
            ),
          );
          return;
        }
      }

      ///
      emailController.clear();
      passwordController.clear();
      notifyListeners();

      ///
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, "/authGate");
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
          shape: const StadiumBorder(),
        ),
      );
    } catch (e) {
      log(e.toString());
      //
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ • ${parsePbError(e)}",
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
      _isLoading = false;
      notifyListeners();
    }
  }

  //

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
}

/// Signup provider
class SignupProvider extends AuthenticationProvider {
  //
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //
  final signupFormKey = GlobalKey<FormState>();

  //
  // Future<void> signup(BuildContext context) async {
  //   //
  //   if (signupFormKey.currentState!.validate()) {
  //     //
  //     _isLoading = true;
  //     notifyListeners();
  //     //
  //     try {
  //       //
  //       final newUserToSignup = UserModel(
  //         email: emailController.text.trim(),
  //         name: nameController.text.trim(),
  //         password: passwordController.text.trim(),
  //         passwordConfirm: passwordController.text.trim(),
  //       );
  //       await pb.createAndLogUser(newUserToSignup);
  //       log("User created successfully");
  //       //
  //       if (!context.mounted) return;
  //       Navigator.pushReplacementNamed(context, "/authGate");
  //       //
  //       if (!context.mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "🎊✅🎉 • Vous êtes connecté !",
  //             style: Theme.of(
  //               context,
  //             ).textTheme.titleMedium!.copyWith(color: Colors.white),
  //           ),
  //           backgroundColor: Theme.of(context).colorScheme.primary,
  //           behavior: SnackBarBehavior.floating,
  //           shape: const StadiumBorder(),
  //         ),
  //       );
  //       //
  //       nameController.clear();
  //       emailController.clear();
  //       passwordController.clear();
  //       confirmPasswordController.clear();
  //       //
  //       notifyListeners();
  //     } catch (e) {
  //       log(e.toString());
  //       _isLoading = false;
  //       notifyListeners();
  //       //
  //       if (!context.mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "❌ • ${parsePbError(e)}",
  //             style: Theme.of(
  //               context,
  //             ).textTheme.titleMedium!.copyWith(color: Colors.white),
  //           ),
  //           backgroundColor: Theme.of(context).colorScheme.error,
  //           behavior: SnackBarBehavior.floating,
  //           shape: const StadiumBorder(),
  //         ),
  //       );
  //     }
  //   }
  // }

  /// Disposer
  @override
  void dispose() {
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
