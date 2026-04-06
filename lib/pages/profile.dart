import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/pages/closed_missions.dart';

import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<UserProvider>(context, listen: false);
      prov.setSelectedIndex(2);
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final pb = PocketBaseDb.instance.pb;
    final currentUser = pb.authStore.record;
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    final theme = Theme.of(context);

    ///
    return Consumer<UserProvider>(
      builder: (_, prov, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Mon profil"),
            centerTitle: false,
            automaticallyImplyLeading: false,
            actions: [
              GestureDetector(
                onTap: () => prov.signOutDialog(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  height: 44,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedLogout02,
                        size: 22,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Déconnexion",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              /// Pages
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24, 16.0, 120),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        ///
                        final currentUser = pb.authStore.record;
                        if (currentUser == null) return const SizedBox();
                        final orgId = currentUser.getStringValue(
                          "organizationId",
                        );
                        final records = pb
                            .collection("organizations")
                            .getOne(orgId);

                        ///
                        return FutureBuilder(
                          future: records,
                          builder: (context, asyncSnapshot) {
                            ///
                            final record = asyncSnapshot.data;
                            if (record == null) return const SizedBox();
                            final logoUrl = pb.files.getUrl(
                              record,
                              record.getStringValue("logo"),
                            );

                            ///
                            return Container(
                              width: 75,
                              height: 75,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(120),
                                border: Border.all(
                                  width: 1,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(120),
                                child: CachedNetworkImage(
                                  imageUrl: logoUrl.toString(),
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const HugeIcon(
                                        icon:
                                            HugeIcons.strokeRoundedUnavailable,
                                        size: 75,
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                            );
                          },
                        );
                      },
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
                    const SizedBox(height: 16),
                    // user badge
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90),
                        color: Colors.green,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            currentUser?.getStringValue('role').toUpperCase() ??
                                "Inconnu",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
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
                              await PocketBaseDb.instance
                                  .resetPassword(
                                    context,
                                    currentUser?.getStringValue("email"),
                                  )
                                  .then((_) {
                                    if (!context.mounted) return;
                                    Navigator.pushNamed(
                                      context,
                                      "/resetPassword",
                                    );
                                  });
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
                              Navigator.pushNamed(context, "/support");
                            },
                            leading: Icon(
                              CupertinoIcons.envelope,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            title: Text(
                              "Contacter le support",
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
                              "Thème 🌝️ • 🌚",
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
                    const Spacer(),
                    Text(
                      "© Track Depenses. Tous droits réservés",
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 14,
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
                              prov.navigateWithFade(
                                context,
                                const ClosedMissions(),
                              );
                              break;
                            case 2:
                              break;
                          }
                        },
                        child: Container(
                          margin: i == 2
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
