import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/pocketBaseHelper/pocketbase_db.dart';
import '../widgets/text_form_field_widget.dart';

class ResetPasswordProvider with ChangeNotifier {
  final emailResetController = TextEditingController();
  final formResetKey = GlobalKey<FormState>();
  final newPwdController = TextEditingController();
  final confirmNewPwdController = TextEditingController();
  bool isLoading = false;
  final pb = PocketBaseDb.instance.pb;

  Future<void> resetPassword(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      //
      await pb
          .collection('users')
          .confirmPasswordReset(
            pb.authStore.token,
            newPwdController.text.trim(),
            confirmNewPwdController.text.trim(),
          );
      //
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎊✅🎉 • Mot de passe réinitialisé avec succès !",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
      //
      if (!context.mounted) return;
      Navigator.pop(context);
      //
      newPwdController.clear();
      confirmNewPwdController.clear();
      notifyListeners();
    } catch (e) {
      log(e.toString());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌⚠️❌ • Échec du reset du mot de passe !",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //
  Future<void> resetPasswordDialog(
    BuildContext context,
    ResetPasswordProvider prov,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        title: const Text("Réinitialiser le mot de passe"),
        content: Form(
          key: formResetKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Entrez votre adresse email pour réinitialiser votre mot de passe",
              ),
              const SizedBox(height: 20),
              TextFormFieldWidget(
                controller: emailResetController,
                hintText: "exemple@exemple.com",
                iconData: CupertinoIcons.at,
                isPassword: false,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains("@")) {
                    return "Veuillez entrer un email valide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              MaterialButton(
                onPressed: () async {
                  if (prov.isLoading) return;
                  if (!formResetKey.currentState!.validate()) return;
                  await PocketBaseDb.instance
                      .resetPassword(context, emailResetController.text.trim())
                      .then((_) {
                        emailResetController.clear();
                        //
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        Navigator.pushNamed(context, "/resetPassword");
                      });
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
                        "Continuer",
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontSize: 17, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///
  @override
  void dispose() {
    newPwdController.dispose();
    confirmNewPwdController.dispose();
    super.dispose();
  }
}
