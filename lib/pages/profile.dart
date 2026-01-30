import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';

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
    final pb = PocketBaseDb.instance.pb;
    final currentUser = pb.authStore.record;
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
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey.shade200,
                  ),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white,
                ),
                child: TextButton(
                  onPressed: () async {
                    prov.resetIndex();
                    //
                    PocketBaseDb.instance.pb.authStore.clear();
                    //
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
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        "assets/td_launcher_icon.png",
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User name
                    Text(
                      currentUser?.getStringValue("name") ?? "Inconnu",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    // User email
                    Text(
                      currentUser?.getStringValue('email') ??
                          "inconnu@exemple.com",
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
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Reset password
                          ListTile(
                            onTap: () async {
                              await PocketBaseDb.instance.resetPassword(context).then((_){
                                if (!context.mounted) return;
                                Navigator.pushNamed(context, "/resetPassword");
                              });
                              //
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
                              //
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey.shade400,
                              //
                              trackOutlineColor: const WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                              //
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
