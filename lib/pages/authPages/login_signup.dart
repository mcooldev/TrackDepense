import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/providers/auth_provider.dart';
import 'package:track_depenses/providers/onboarding_provider.dart';

class LoginSignup extends StatefulWidget {
  const LoginSignup({super.key});

  @override
  State<LoginSignup> createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {
  ///
  final pb = PocketBaseDb.instance;

  ///
  @override
  Widget build(BuildContext context) {
    return Consumer2<OnBoardingProvider, LoginProvider>(
      builder: (_, obProv, prov, _) {
        return Scaffold(
          body: Container(
            padding: const EdgeInsets.fromLTRB(16, 90, 16, 32),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login-signup-bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: Image.asset(
                    "assets/login-signup-image.png",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Un moyen simple\nde gérer votre budget",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge!.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Suivez les dépenses terrain et générez vos rapports en un clic.",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                /// Sign up && Login buttons
                Column(
                  children: [
                    // Signup Button
                    MaterialButton(
                      onPressed: () async {
                        await obProv.setFirstTimeComplete();
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, "/signup");
                      },
                      color: Theme.of(context).colorScheme.onPrimary,
                      elevation: 0,
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90),
                        side: BorderSide(
                          width: 0.5,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Text(
                        "Créer un compte",
                        softWrap: false,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MaterialButton(
                      onPressed: () async {
                        await obProv.setFirstTimeComplete();
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, "/login");
                      },
                      color: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Text(
                        "Se connecter",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
