import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/web_view/web_providers/login_web_provider.dart';

import '../../providers/reset_pwd_provider.dart';
import '../../widgets/text_form_field_widget.dart';

class LoginWeb extends StatefulWidget {
  const LoginWeb({super.key});

  @override
  State<LoginWeb> createState() => _LoginWebState();
}

class _LoginWebState extends State<LoginWeb> {
  ///
  GlobalKey<FormState> loginWebFormKey = GlobalKey<FormState>();

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final theme = Theme.of(context);
    final resetProv = Provider.of<ResetPasswordProvider>(context);

    ///
    return Scaffold(
      body: Consumer<LoginWebProvider>(
        builder: (_, prov, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final double targetWidth = constraints.maxWidth < 1190
                  ? 1190
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: targetWidth,
                  child: Row(
                    children: [
                      // Left Side containing image
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/login-signup-bg.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // texts
                              Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 70,
                                      child: Image.asset(
                                        'assets/logo-td-ob.png',
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        text:
                                            "Un moyen simple de \ngérer votre",
                                        children: [
                                          TextSpan(
                                            text: " budget",
                                            style: theme
                                                .textTheme
                                                .headlineLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: theme
                                                      .colorScheme
                                                      .secondary,
                                                  fontSize: 40,
                                                ),
                                          ),
                                        ],
                                      ),
                                      style: theme.textTheme.headlineLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            fontSize: 40,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Suivez les dépenses de vos agents en\ntemps réel, centralisez les justificatifs\net transformez vos données en\nrapports stratégiques\ninstantanés.",
                                      style: theme.textTheme.bodyMedium!
                                          .copyWith(
                                            color: Colors.white,
                                            fontSize: 18,
                                            height: 1.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // image
                              // image
                              Positioned(
                                right: 50,
                                bottom: 0.0,
                                child: SizedBox(
                                  height: 400,
                                  child: Image.asset(
                                    'assets/woman-agent-image.png',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Right Side
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 200),
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // TD logo
                              const CircleAvatar(
                                radius: 32,
                                backgroundImage: AssetImage(
                                  "assets/td_launcher_icon.png",
                                ),
                              ),
                              const SizedBox(height: 16),
                              // text
                              Text(
                                "Content de vous revoir !",
                                textAlign: TextAlign.center,
                                softWrap: false,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .copyWith(fontSize: 28),
                              ),
                              const SizedBox(height: 8),
                              //
                              Text(
                                "Veuillez vous connecter pour continuer.",
                                textAlign: TextAlign.center,
                                softWrap: false,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 32),
                              //
                              Form(
                                key: loginWebFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Email
                                    Text(
                                      "Adresse mail",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormFieldWidget(
                                      controller: prov.emailWebController,
                                      hintText: "exemple@exemple.com",
                                      iconData: CupertinoIcons.at,
                                      isPassword: false,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "L'adresse mail est requise";
                                        }
                                        final emailRegex = RegExp(
                                          r"^[\w.+\-]+@([\w\-]+\.)+[\w\-]{2,}$",
                                        );
                                        if (!emailRegex.hasMatch(value)) {
                                          return "Veuillez entrer une adresse mail valide";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    /// Password
                                    Text(
                                      "Mot de passe",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormFieldWidget(
                                      controller: prov.passwordWebController,
                                      hintText: "••••••••",
                                      iconData: CupertinoIcons.number,
                                      isPassword: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Le mot de passe est requis";
                                        }
                                        if (value.length < 8) {
                                          return "Le mot de passe doit contenir au moins 8 caractères";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),

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
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
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
                                    const SizedBox(height: 24),

                                    /// Login button
                                    MaterialButton(
                                      onPressed: () async {
                                        await prov.loginWeb(
                                          context,
                                          loginWebFormKey,
                                        );
                                      },
                                      splashColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.15),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      elevation: 0,
                                      height: 52,
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
