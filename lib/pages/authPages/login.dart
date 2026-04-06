import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/providers/onboarding_provider.dart';

import '../../helpers/pocketBaseHelper/pocketbase_db.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reset_pwd_provider.dart';
import '../../widgets/text_form_field_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ///
  final pb = PocketBaseDb.instance;

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final resetProv = Provider.of<ResetPasswordProvider>(context);

    ///
    return ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: Scaffold(

        ///
        body: Consumer2<LoginProvider, OnBoardingProvider>(
          builder: (_, prov, obProv, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 150, 16.0, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    backgroundImage: const AssetImage(
                      "assets/td_launcher_icon.png",
                    ),
                  ),
                  const SizedBox(height: 12),
                  //
                  Text(
                    "Content de vous revoir !",
                    softWrap: true,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge!.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 4),

                  //
                  Text(
                    "Veuillez vous connecter pour continuer.",
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),

                  //
                  Form(
                    key: prov.loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Email
                        Text(
                          "Adresse mail",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormFieldWidget(
                          controller: prov.emailController,
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

                        /// Password
                        Text(
                          "Mot de passe",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormFieldWidget(
                          controller: prov.passwordController,
                          hintText: "••••••••",
                          iconData: CupertinoIcons.lock,
                          isPassword: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 8) {
                              return "8 caractères minimum";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        /// Forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                //
                                await resetProv.resetPasswordDialog(
                                  context,
                                  resetProv,
                                );
                              },
                              child: Text(
                                "Mot de passe oublié ?",
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onSurface
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        /// Login button
                        MaterialButton(
                          onPressed: () async {
                            await prov.login(context).then((_) {
                              obProv.setFirstTimeComplete();
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
                                  "Se connecter maintenant",
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
                  const SizedBox(height: 100),

                  // /// Contact support
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   mainAxisSize: MainAxisSize.max,
                  //   children: [
                  //     Text(
                  //       "Pour toutes irrégularités,",
                  //       textAlign: TextAlign.center,
                  //       style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  //         color: Theme.of(
                  //           context,
                  //         ).colorScheme.onSurface.withValues(alpha: 0.7),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.pushReplacementNamed(
                  //           context,
                  //           "",
                  //         ); // todo: add support contact page
                  //       },
                  //       child: Text(
                  //         "contacter le support.",
                  //         textAlign: TextAlign.center,
                  //         style: Theme.of(context).textTheme.titleSmall!
                  //             .copyWith(
                  //               color:
                  //                   Theme.of(context).brightness ==
                  //                       Brightness.dark
                  //                   ? Theme.of(context).colorScheme.onSurface
                  //                   : Theme.of(context).colorScheme.primary,
                  //             ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
