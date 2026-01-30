import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:track_depenses/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PocketBaseDb {
  PocketBaseDb._();

  static final PocketBaseDb instance = PocketBaseDb._();

  late PocketBase pb;



  final schemeString =
      "com.googleusercontent.apps.699525924030-v6gsmugnbp3dr97u6l535oopl89e83r7:/";

  ///

  void initPb(AuthStore store) {
    pb = PocketBase(
      'https://divisi-angella-slumberous.ngrok-free.dev',
      authStore: store,
    );
  }

  Future<void> createAndLogUser(UserModel user) async {
    try {
      await pb.collection('users').create(body: user.toMap());
      await pb.collection("users").authWithPassword(user.email, user.password);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<bool> loginUser(UserModel user) async {
    try {
      await pb.collection("users").authWithPassword(user.email, user.password);
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    try {
      final email = pb.authStore.record?.getStringValue("email");
      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌⚠️❌ • Impossible de récupérer l'email !",
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
      //
      await pb.collection("users").requestPasswordReset(email);
      //
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎊✅🎉 • Email envoyé avec succès !",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌⚠️❌ • Erreur lors de l'envoie du mail !",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    }
  }

  Future<void> signWithGoogle(BuildContext context) async {
    try {
      await pb
          .collection("users")
          .authWithOAuth2(
            "google",
            (url) async {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
            scopes: ["email", "profile"],
            createData: {"emailVisibility": true},
          );
      if (!context.mounted) return;
      //
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎊✅🎉 • Connexion Google réussie !",
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
      Navigator.of(context).pushReplacementNamed("/authGate");
      //
    } catch (e) {
      log(e.toString());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌⚠️❌ • Erreur: Connexion Google impossible !",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    }
  }
}
