import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/providers/onboarding_provider.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnBoardingProvider>(
      builder: (_, prov, _) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  width: double.infinity,
                  child: Image.asset(
                    "assets/onboarding-img.png",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Un moyen simple de surveiller vos dépenses",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Protégez votre avenir en gérant vos dépenses dès maintenant.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                MaterialButton(
                  onPressed: () async {
                    await prov.setFirstTimeComplete();
                    //
                    if(!context.mounted) return;
                    Navigator.pushReplacementNamed(context, "/loginSignup");
                  },
                  color: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: const Text("Commencer", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
