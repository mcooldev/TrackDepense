import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/onboarding_provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  ///
  @override
  void initState() {
    super.initState();
    _checkIsFirstTime(context);
  }

  //
  Future<void> _checkIsFirstTime(BuildContext context) async {
    final onBoardingProvider = Provider.of<OnBoardingProvider>(
      context,
      listen: false,
    );
    //
    try {
      await onBoardingProvider.checkIsFirstTime();
      //
      await Future.delayed(const Duration(seconds: 3));
      //
      if (!context.mounted) return;
      if (onBoardingProvider.isFirstTime) {
        Navigator.pushReplacementNamed(context, "/loginSignup");
        return;
      }
      //
      Navigator.pushReplacementNamed(context, "/authGate");
      //
    } catch (e) {
      log(e.toString());
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.3,
                child: const Image(
                  image: AssetImage("assets/td_splash_icon_transparent.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
