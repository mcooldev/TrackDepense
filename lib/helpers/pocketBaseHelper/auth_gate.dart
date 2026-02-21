import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/providers/onboarding_provider.dart';

import '../../pages/authPages/login.dart';
import '../../pages/home.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  ///
  final pb = PocketBaseDb.instance;
  bool _isCheckingAuth = true;
  StreamSubscription? _linkSubscription;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLink();
    _checkAuth();
  }

  void _initDeepLink() {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      if (uri.path.contains('oauth2-redirect')) {
        log("Lien de retour détecté : $uri");
        //
        if (uri.queryParameters.containsKey("code")) {
          log("✅ Code OAuth reçu, vérification de l'authentification...");
          await Future.delayed(const Duration(milliseconds: 800));
          //
          await _checkAuth();
          //
        } else {
          log("❌ Pas de code OAuth - authentification échouée");
          if (mounted) setState(() => _isCheckingAuth = false);
        }
      }
    });
  }

  Future<void> _checkAuth() async {
    //
    setState(() => _isCheckingAuth = true);
    //
    try {
      if (pb.pb.authStore.token.isNotEmpty && pb.pb.authStore.isValid) {
        log("Tentative de refresh du token...");
        await pb.pb.collection('users').authRefresh();
        log("Token refresh réussi !");
      } else {
        log("⚠️ Pas de token valide à refresh");
      }
    } catch (e) {
      log(e.toString());
      pb.pb.authStore.clear();
    } finally {
      if (mounted) {
        setState(() => _isCheckingAuth = false);
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    final obProv = context.watch<OnBoardingProvider>();
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 8),
              Text("Vérification de l'authentification..."),
            ],
          ),
        ),
      );
    }
    //
    if (!pb.pb.authStore.isValid) {
      return const Login();
    }
    //
    if (obProv.isFirstTime) {
      obProv.setFirstTimeComplete();
    }
    //
    return const Home();
  }
}