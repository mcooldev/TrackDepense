import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:track_depenses/providers/user_provider.dart';

import 'package:track_depenses/web_view/web_providers/home_web_provider.dart';

import 'menu_item_web.dart';

class WebNavigationBar extends StatelessWidget {
  const WebNavigationBar({
    super.key,
    required this.theme,
    required this.prov,
    required this.userProv,
  });

  final ThemeData theme;
  final HomeWebProvider prov;
  final UserProvider userProv;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 250,
      height: MediaQuery.of(context).size.height,
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // row for logo
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundImage: AssetImage("assets/td_launcher_icon.png"),
              ),
              const SizedBox(width: 8),
              Text("Track Depenses", style: theme.textTheme.titleMedium),
            ],
          ),
          // menu
          const SizedBox(height: 20),
          Text("Menu", style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Column(
            children: List.generate(prov.navItems.length, (i) {
              ///
              final item = prov.navItems[i];

              ///
              return MenuItemWeb(
                onTap: () {
                  if (i == prov.selectedIndex) return;
                  //
                  prov.selectedMission = null;
                  prov.selectedTrx = null;
                  prov.selectedAgent = null;
                  prov.selectedIndex = i;
                },
                isSelected: i == prov.selectedIndex,
                labelItem: item["label"],
                iconData: item["icon"],
              );
            }),
          ),
          // logout button & copyright
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  userProv.signOutDialog(context);
                },
                child: Container(
                  height: 36,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedLogout02,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Se déconnecter",
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "© 2026, Track Depenses. Tous droits réservés.",
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
