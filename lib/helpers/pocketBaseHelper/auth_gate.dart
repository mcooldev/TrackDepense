import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/pages/support_page.dart';
import 'package:track_depenses/providers/onboarding_provider.dart';
import 'package:track_depenses/web_view/pages/home_web.dart';
import 'package:track_depenses/web_view/pages/login_web.dart';

import '../../pages/authPages/login.dart';
import '../../pages/home.dart';
import '../../providers/user_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  ///
  final pb = PocketBaseDb.instance.pb;

  //
  StreamSubscription<List<ConnectivityResult>>? connectivityResult;
  bool isFirstTimeConnectivityCheck = true;

  Future<void>? authFuture;

  //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authFuture = context.read<UserProvider>().checkAuth();
    });

    ///
    connectivityResult = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      //
      if (isFirstTimeConnectivityCheck) {
        isFirstTimeConnectivityCheck = false;
        return;
      }
      //
      final isNotOnline =
          !result.contains(ConnectivityResult.mobile) &&
          !result.contains(ConnectivityResult.wifi);
      //
      if (!isNotOnline) return;
      //
      if (isNotOnline) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "⚠️ • Vous êtes hors ligne",
              textAlign: TextAlign.center,
            ),
            width: 200,
            backgroundColor: Colors.grey,
            shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vous êtes en ligne", textAlign: TextAlign.center),
            width: 160,
            backgroundColor: Colors.green,
            shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    connectivityResult?.cancel();
    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    //
    return FutureBuilder(
      future: authFuture,
      builder: (context, snapshot) {
        //
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        ///

        final obProv = context.read<OnBoardingProvider>();
        final userProv = context.watch<UserProvider>();
        final user = pb.authStore.record;
        //
        if (user == null || !pb.authStore.isValid) {
          if (kIsWeb) return const LoginWeb();
          return const Login();
        }
        //
        if (userProv.isLoading) {
          return const Scaffold(
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 8),
                  Text("Vérification de l'abonnement..."),
                ],
              ),
            ),
          );
        }
        //
        if (!userProv.isOrgStillActive) {
          return const SupportPage();
        }
        //
        if (obProv.isFirstTime) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            obProv.setFirstTimeComplete();
          });
        }

        ///
        final userRole = user.getStringValue('role');
        // web view
        if (kIsWeb) {
          if (userRole.contains("admin")) return const HomeWeb();
          return buildScaffoldErrorPage(context);
        }

        // mobile view
        if (userRole.contains("agent")) return const Home();
        return buildScaffoldErrorPage(context);
      },
    );
  }

  ///* EXTRACTED METHOD */

  Scaffold buildScaffoldErrorPage(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedAccess,
              size: 70,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              kIsWeb
                  ? "Vous n'avez pas accès à cette page. Veuillez utiliser l'application mobile"
                  : "Vous n'avez pas accès à cette page. Veuillez utiliser un ordinateur",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                PocketBaseDb.instance.pb.realtime.unsubscribe();
                PocketBaseDb.instance.pb.authStore.clear();
                //
                Navigator.pushReplacementNamed(
                  context,
                  kIsWeb ? "/loginWeb" : "/login",
                );
              },
              child: Text(
                "Se déconnecter",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
