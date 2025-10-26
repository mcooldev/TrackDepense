import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/firebaseHelper/auth_gate.dart';
import 'package:track_depenses/helpers/firebaseHelper/reset_password.dart';
import 'package:track_depenses/pages/authPages/login.dart';
import 'package:track_depenses/pages/authPages/login_signup.dart';
import 'package:track_depenses/pages/authPages/signup.dart';
import 'package:track_depenses/pages/home.dart';
import 'package:track_depenses/pages/profile.dart';
import 'package:track_depenses/pages/splashOnboarding/on_boarding.dart';
import 'package:track_depenses/pages/splashOnboarding/splash.dart';
import 'package:track_depenses/providers/onboarding_provider.dart';
import 'package:track_depenses/providers/reset_pwd_provider.dart';
import 'package:track_depenses/providers/share_files_providers.dart';
import 'package:track_depenses/providers/theme_provider.dart';
import 'package:track_depenses/providers/transaction_provider.dart';
import 'package:track_depenses/providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    throw Exception("Erreur lors de l'initialisation: $e");
  }
  runApp(const TrackDepenses());
}

class TrackDepenses extends StatelessWidget {
  const TrackDepenses({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnBoardingProvider()),
        ChangeNotifierProvider(create: (_) => ResetPasswordProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ShareFilesProvider())
      ],
      child: Consumer<ThemeProvider>(builder: (_, prov, _) {
        return MaterialApp(
          title: 'Track Dépenses',
          debugShowCheckedModeBanner: false,
          theme: prov.theme,
          initialRoute: "/",
          routes: {
            "/": (context) => const Splash(),
            "/onboarding": (context) => const OnBoarding(),
            //
            "/loginSignup": (context) => const LoginSignup(),
            "/login": (context) => const Login(),
            "/signup": (context) => const Signup(),
            "/resetPassword": (context) => const ResetPassword(),
            "/authGate": (context) => const AuthGate(),
            //
            "/home": (context) => const Home(),
            "/profile": (context) => const Profile(),
          },
        );
      }),
    );
  }
}
