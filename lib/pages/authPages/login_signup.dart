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
    //
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    //
    return Consumer2<OnBoardingProvider, LoginProvider>(
      builder: (_, obProv, prov, _) {
        return Scaffold(
          body: Container(
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login-signup-bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              fit: StackFit.loose,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 100,
                      child: Image(
                        image: AssetImage("assets/logo-td-ob.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // title
                    Text.rich(
                      TextSpan(
                        text: "Un moyen simple\nde gérer votre",
                        children: [
                          TextSpan(
                            text: " budget",
                            style: theme.textTheme.headlineLarge!.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.secondary,
                              fontSize: 40,
                            ),
                          ),
                        ],
                      ),
                      style: theme.textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Suivez les dépenses terrain et générez\nvos rapports en un clic.",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sign up button
                        // Expanded(
                        //   child: MaterialButton(
                        //     onPressed: () async {
                        //       await obProv.setFirstTimeComplete();
                        //       if (!context.mounted) return;
                        //       Navigator.pushNamed(context, "/signup");
                        //     },
                        //     height: 46,
                        //     shape: const StadiumBorder(
                        //       side: BorderSide(width: 1, color: Colors.white24),
                        //     ),
                        //     child: Text(
                        //       "S'inscrire",
                        //       style: theme.textTheme.bodyMedium!.copyWith(
                        //         fontSize: 17,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 8),
                        // Login button
                        Expanded(
                          child: MaterialButton(
                            onPressed: () async {
                              await obProv.setFirstTimeComplete();
                              if (!context.mounted) return;
                              Navigator.pushNamed(context, "/login");
                            },
                            height: 46,
                            color: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            child: Text(
                              "Se connecter",
                              style: theme.textTheme.bodyMedium!.copyWith(
                                fontSize: 17,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // woman agent image
                const Positioned(
                  left: 20,
                  right: 20,
                  bottom: 0,
                  child: SizedBox(
                    height: 350,
                    child: Image(
                      image: AssetImage("assets/woman-agent-image.png"),
                      fit: BoxFit.cover,
                    ),
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
