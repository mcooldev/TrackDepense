import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/reset_pwd_provider.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordProvider>(
      builder: (_, prov, _) {
        return Scaffold(
          ///
          appBar: AppBar(
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage("assets/td_launcher_icon.png"),
                ),
                const SizedBox(width: 12),
                Text(
                  "Track Dépenses",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

          ///
          body: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 150,
                    child: Image.asset(
                      'assets/email-image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    "Réinitialisation du mot de passe envoyée ?",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge!.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 12),

                  //
                  Text(
                    "Vérifier votre email sous peu. Un lien de réinitialisation de mot de passe vous a été envoyé.",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
