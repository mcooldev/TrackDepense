import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/pages/home.dart';
import 'package:track_depenses/pages/profile.dart';
import 'package:track_depenses/providers/user_provider.dart';

import '../helpers/pocketBaseHelper/pocketbase_db.dart';
import '../providers/transaction_provider.dart';
import '../widgets/missions_list_view.dart';

class ClosedMissions extends StatefulWidget {
  const ClosedMissions({super.key});

  @override
  State<ClosedMissions> createState() => _ClosedMissionsState();
}

class _ClosedMissionsState extends State<ClosedMissions> {
  ///
  final TextEditingController searchMissionController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<UserProvider>(context, listen: false);
      prov.setSelectedIndex(1);
      //
      final trxProv = Provider.of<TransactionProvider>(context, listen: false);
      trxProv.fetchMissions(
        isClosed: true,
        searchQuery: searchMissionController.text.trim(),
      );
      //
    });
  }

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce!.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (value.isEmpty) {
        context.read<TransactionProvider>().fetchMissions(
          isClosed: true,
          searchQuery: '',
        );
      } else {
        context.read<TransactionProvider>().fetchMissions(
          isClosed: true,
          searchQuery: value,
        );
      }
    });
  }

  @override
  void dispose() {
    searchMissionController.dispose();
    _searchDebounce?.cancel();
    // TrxDb.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///
    final currentUser = PocketBaseDb.instance.pb.authStore.record;

    ///
    return Consumer2<UserProvider, TransactionProvider>(
      builder: (_, prov, trxProv, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    prov.navigateWithFade(context, const Profile());
                    prov.selectedIndex = 1;
                  },
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage("assets/td_launcher_icon.png"),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prov.greeting,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      currentUser?.getStringValue("name").split(' ').first ??
                          "Inconnu",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            centerTitle: false,
            automaticallyImplyLeading: false,
          ),

          ///
          body: Stack(
            children: [
              Column(
                children: [
                  // Search bar for history
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchBar(
                      controller: searchMissionController,
                      onChanged: _onSearchChanged,
                      elevation: const WidgetStatePropertyAll(0),
                      onTapOutside: (pointer) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      leading: Icon(
                        CupertinoIcons.search,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.only(left: 20),
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withValues(alpha: 0.5)
                            : Colors.grey.shade100,
                      ),
                      trailing: [
                        IconButton(
                          onPressed: () {
                            searchMissionController.clear();
                            _onSearchChanged('');
                          },
                          icon: Icon(
                            CupertinoIcons.multiply,
                            color: Colors.grey.shade300,
                          ),
                          splashColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      ],
                      hintText: "Chercher une mission clôturée",
                      hintStyle: WidgetStatePropertyAll(
                        Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Tab content
                  Expanded(
                    child: trxProv.isLoading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : MissionsListView(
                            emptyState: emptyClosedMissionContainer(context),
                            title: "Mes missions clôturées",
                            missions: trxProv.missions,
                          ),
                  ),
                ],
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
                            case 2:
                              prov.navigateWithFade(context, const Profile());
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

  ///

  /* EXTRACTED METHODS */

  ///
  Container emptyClosedMissionContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 70),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.3,
              height: 100,
              child: SvgPicture.asset("assets/empty.svg"),
            ),
            const SizedBox(height: 16),
            Text(
              "Pas de mission\nclôturée pour le moment !",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              "Veuillez voir vos missions en cours",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
