import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/reset_pwd_provider.dart';
import '../../widgets/text_form_field_widget.dart';

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
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mot de passe oublié ?",
                  softWrap: true,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge!.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 12),

                //
                Text(
                  "Entrer votre nouveau mot de passe et confirmer.",
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),

                /// Nouveau mot de passe
                Text(
                  "Nouveau mot de passe",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormFieldWidget(
                  controller: prov.newPwdController,
                  hintText: "••••••••",
                  iconData: CupertinoIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un mot de passe";
                    }
                    if (value.length < 8) {
                      return "Veuillez entrer minimum 8 caractères";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                /// Confirmer nouveau mot de passe
                Text(
                  "Confirmer nouveau mot de passe",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormFieldWidget(
                  controller: prov.confirmNewPwdController,
                  hintText: "••••••••",
                  iconData: CupertinoIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez confirmer le mot de passe";
                    }
                    if (value != prov.newPwdController.text) {
                      return "Les mots de passe ne correspondent pas";
                    }
                    if (value.length < 8) {
                      return "Veuillez entrer minimum 8 caractères";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                /// Reset password button
                MaterialButton(
                  onPressed: () async {
                    if (prov.isLoading) return;
                    await prov.resetPassword(context);
                  },
                  splashColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  height: 50,
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: prov.isLoading
                      ? const CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white,
                        )
                      : Text(
                          "Confirmer le changement",
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(fontSize: 17, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
