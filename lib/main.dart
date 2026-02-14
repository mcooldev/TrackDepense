import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';

import 'package:track_depenses/pages/authPages/login.dart';
import 'package:track_depenses/pages/authPages/login_signup.dart';
import 'package:track_depenses/pages/authPages/signup.dart';
import 'package:track_depenses/pages/closed_missions.dart';
import 'package:track_depenses/pages/home.dart';
import 'package:track_depenses/pages/profile.dart';
import 'package:track_depenses/pages/splashOnboarding/splash.dart';
import 'package:track_depenses/pages/support_page.dart';
import 'package:track_depenses/providers/auth_provider.dart';
import 'package:track_depenses/providers/onboarding_provider.dart';
import 'package:track_depenses/providers/reset_pwd_provider.dart';
import 'package:track_depenses/providers/share_files_providers.dart';
import 'package:track_depenses/providers/theme_provider.dart';
import 'package:track_depenses/providers/transaction_provider.dart';
import 'package:track_depenses/providers/user_provider.dart';

import 'helpers/pocketBaseHelper/auth_gate.dart';
import 'helpers/pocketBaseHelper/reset_password.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? authData = prefs.getString('pb_authData');
  final store = AsyncAuthStore(
    initial: authData,
    save: (data) async {
      await prefs.setString('pb_authData', data);
    },
    clear: () async {
      await prefs.remove('pb_authData');
    },
  );
  PocketBaseDb.instance.initPb(store);
  //
  runApp(const TrackDepenses());
}

class TrackDepenses extends StatelessWidget {
  const TrackDepenses({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnBoardingProvider()),
        //
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ResetPasswordProvider()),
        //
        ChangeNotifierProvider(create: (_) => UserProvider()),
        //
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        //
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        //
        ChangeNotifierProvider(create: (_) => ShareFilesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, prov, _) {
          return MaterialApp(
            title: 'Track Dépenses',
            debugShowCheckedModeBanner: false,
            theme: prov.theme,
            initialRoute: "/",
            routes: {
              "/": (context) => const Splash(),
              //
              "/loginSignup": (context) => const LoginSignup(),
              "/login": (context) => const Login(),
              "/signup": (context) => const Signup(),
              "/resetPassword": (context) => const ResetPassword(),
              "/authGate": (context) => const AuthGate(),
              //
              "/home": (context) => const Home(),
              "/profile": (context) => const Profile(),
              "/closedMissions": (context) => const ClosedMissions(),
              "/support": (context) => const SupportPage(),
            },
          );
        },
      ),
    );
  }
}
