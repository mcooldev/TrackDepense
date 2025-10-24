import 'package:flutter/material.dart';

class LoginSignup extends StatelessWidget {
  const LoginSignup({super.key});

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                // Signup Button
                Expanded(
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/signup");
                    },
                    color: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Text(
                      "Créer un compte",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Login Button
                Expanded(
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    color: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Text(
                      "Se connecter",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
