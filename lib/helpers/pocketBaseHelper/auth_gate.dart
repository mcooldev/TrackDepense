import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
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
  final pb = PocketBaseDb.instance;
  bool _isCheckingAuth = true;
  StreamSubscription? _linkSubscription;
  final _appLinks = AppLinks();

  //
  StreamSubscription<List<ConnectivityResult>>? connectivityResult;
  bool isFirstTimeConnectivityCheck = true;

  //

  @override
  void initState() {
    super.initState();
    //
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
    //
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().checkSubscription();
    });
    //
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
    connectivityResult?.cancel();
    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    final obProv = context.watch<OnBoardingProvider>();
    final userProv = Provider.of<UserProvider>(context);
    final user = pb.pb.authStore.record;
    //
    if (_isCheckingAuth || userProv.isLoading) {
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
    if (user == null) {
      if (kIsWeb) return const LoginWeb();
      return const Login();
    }
    //
    if (!userProv.isOrgStillActive) {
      return const SupportPage();
    }
    //
    if (!pb.pb.authStore.isValid) {
      if (kIsWeb) {
        return const LoginWeb();
      }
      return const Login();
    }
    //
    if (obProv.isFirstTime) {
      obProv.setFirstTimeComplete();
    }
    // web view
    if (kIsWeb) {
      final userRole = user.getStringValue('role');
      if (userRole.contains("admin")) return const HomeWeb();
      return buildScaffoldErrorPage(context);
    }

    // mobile view
    final userRole = user.getStringValue('role');
    if (userRole.contains("agent")) return const Home();
    return buildScaffoldErrorPage(context);
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
