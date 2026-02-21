import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:track_depenses/core/config.dart';
import 'package:track_depenses/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PocketBaseDb {
  PocketBaseDb._();

  static final PocketBaseDb instance = PocketBaseDb._();

  late PocketBase pb;

  static final config = TDConfig();

  ///

  void initPb(AuthStore store) {
    pb = PocketBase(config.baseUrl, authStore: store);
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

  Future<void> resetPassword(BuildContext context, String? enteredEmail) async {
    try {
      final existedEmail =
          pb.authStore.record?.getStringValue("email") ?? enteredEmail;
      //
      if (existedEmail == null || existedEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ • Pas d'email fourni !",
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
      await pb.collection("users").requestPasswordReset(existedEmail);
      //
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎊 • Email envoyé avec succès !",
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
            "⚠️ • Problème lors de l'envoie !",
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
      //
      final authData = await pb
          .collection("users")
          .authWithOAuth2(
            "google",
            (url) async {
              final urlString = url.toString();
              final modifiedUrl = Uri.parse(
                urlString.contains('?')
                    ? '$urlString&prompt=select_account'
                    : '$urlString?prompt=select_account',
              );

              await launchUrl(
                modifiedUrl,
                mode: LaunchMode.externalApplication,
              );
            },
            scopes: ["email", "profile"],
            createData: {"emailVisibility": true},
          );

      if (authData.token.isEmpty) {
        throw Exception("Token vide");
      }
      log("✅ Connexion Google réussie - User: ${authData.record.id}");
      //
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed("/authGate");
      //
    } catch (e) {
      log(e.toString());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ • Erreur: Connexion Google impossible !",
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
