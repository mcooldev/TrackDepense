import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/firebaseHelper/firebase_service.dart';

import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    ///
    final currentUser = FirebaseAuth.instance.currentUser;
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);

    ///
    return Consumer<UserProvider>(
      builder: (_, prov, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Mon profil"),
            centerTitle: false,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white,
                ),
                child: TextButton(
                  onPressed: () async {
                    prov.resetNameAndIndex();
                    //
                    await Authentication.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, "/authGate");
                  },
                  child: Text(
                    "Se déconnecter",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              /// Pages
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24, 16.0, 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        // Profile picture
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: prov.image != null
                              ? FileImage(prov.image!)
                              : null,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          child: prov.image == null
                              ? Icon(
                                  CupertinoIcons.person,
                                  size: 32,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              prov.pickImage();
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(90),
                                border: Border.all(
                                  width: 2,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Icon(
                                CupertinoIcons.camera,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // User name
                    Text(
                      prov.userName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    // User email
                    Text(
                      currentUser?.email ?? "Inconnu",
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                    ),
                    //
                    const SizedBox(height: 24),
                    // Settings
                    Container(
                      padding: const EdgeInsets.all(8),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Reset password
                          ListTile(
                            onTap: () {
                              // todo: reset password
                            },
                            leading: Icon(
                              CupertinoIcons.lock,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            title: Text(
                              "Modifier mot de passe",
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            trailing: const Icon(
                              CupertinoIcons.chevron_forward,
                            ),
                          ),
                          Divider(
                            thickness: 0.5,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                          // Contact support
                          ListTile(
                            onTap: () {
                              // todo: contact support
                            },
                            leading: Icon(
                              CupertinoIcons.phone,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            title: Text(
                              "Demander de l'aide",
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            trailing: const Icon(
                              CupertinoIcons.chevron_forward,
                            ),
                          ),
                          Divider(
                            thickness: 0.5,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                          // Theme preferences
                          ListTile(
                            leading: Icon(
                              CupertinoIcons.paintbrush,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            title: Text(
                              "Claire 🌝️ • Sombre 🌚",
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            trailing: Switch(
                              value: themeProv.isSwitched,
                              onChanged: (newValue) {
                                // todo: theme preferences switch
                                themeProv.toggleTheme();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// Bottom navigation bar
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(90),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(prov.icons.length, (i) {
                      final icon = prov.icons[i];
                      bool isSelected = i == prov.selectedIndex;
                      return GestureDetector(
                        onTap: () {
                          if (i == prov.selectedIndex) return;
                          prov.selectedIndex = i;
                          switch (i) {
                            case 0:
                              prov.navigateWithFade(context, const Home());
                              break;
                            case 1:
                              break;
                          }
                        },
                        child: Container(
                          margin: i == 1
                              ? null
                              : const EdgeInsets.only(right: 8),
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(90),
                            color: isSelected
                                ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.primary,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
