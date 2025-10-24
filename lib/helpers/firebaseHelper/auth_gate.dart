import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pages/authPages/login.dart';
import '../../pages/home.dart';
import '../../providers/user_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshots.hasData) {
          return Consumer<UserProvider>(builder: (_, prov, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (prov.userName.isEmpty) {
                  await prov.getUserName();
                }
              });
            return const Home();
          },);
        } else {
          return const Login();
        }
      },
    );
  }
}
