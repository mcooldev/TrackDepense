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

    return Consumer<ResetPasswordProvider>(builder: (_, prov, _) {
      return Scaffold(
        ///
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Theme.of(context).colorScheme.surface,
                backgroundImage: const AssetImage("assets/google_logo.png"),
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
        body: Padding(
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
                "Entrer votre adresse mail ci-dessous et nous vous enverrons un lien pour réinitialiser votre mot de passe.",
                softWrap: true,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              /// Email
              Text(
                "Adresse mail",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormFieldWidget(
                controller: prov.resetEmailController,
                hintText: "exemple@exemple.com",
                iconData: CupertinoIcons.at,
                isPassword: false,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !value.contains("@")) {
                    return "Veuillez entrer votre adresse mail";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              /// Reset password button
              MaterialButton(
                onPressed: () async {
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
                  "Envoyer le lien",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
