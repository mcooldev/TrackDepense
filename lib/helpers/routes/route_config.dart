import 'package:flutter/cupertino.dart';

import '../../pages/authPages/login.dart';
import '../../pages/authPages/login_signup.dart';
import '../../pages/closed_missions.dart';
import '../../pages/home.dart';
import '../../pages/profile.dart';
import '../../pages/splashOnboarding/splash.dart';
import '../../pages/support_page.dart';
import '../../web_view/pages/home_web.dart';
import '../../web_view/pages/login_web.dart';
import '../pocketBaseHelper/auth_gate.dart';
import '../pocketBaseHelper/reset_password.dart';

class RouteConfig {
  RouteConfig._();

  static final RouteConfig instance = RouteConfig._();

  factory RouteConfig() => instance;

  // ======================================================
  // ROUTES
  // ======================================================

  static Map<String, Widget Function(BuildContext)> routes = {
    "/": (context) => const Splash(),
    //
    "/loginSignup": (context) => const LoginSignup(),
    "/login": (context) => const Login(),
    // "/signup": (context) => const Signup(),
    "/resetPassword": (context) => const ResetPassword(),
    "/authGate": (context) => const AuthGate(),
    //
    "/home": (context) => const Home(),
    "/profile": (context) => const Profile(),
    "/closedMissions": (context) => const ClosedMissions(),
    "/support": (context) => const SupportPage(),

    /// Web screens
    "/loginWeb": (context) => const LoginWeb(),
    "/homeWeb": (context) => const HomeWeb(),
  };
}
