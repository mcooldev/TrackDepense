import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/trx_db.dart';
import 'package:track_depenses/pages/closed_missions.dart';
import 'package:track_depenses/pages/profile.dart';
import 'package:track_depenses/widgets/missions_stream_wrapper.dart';
import 'package:track_depenses/widgets/new_mission.dart';

import '../models/transaction_model.dart';

import '../providers/user_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ///
  late Stream<List<Mission>> _missionsEnCoursStream;

  final TextEditingController searchMissionController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<UserProvider>(context, listen: false);
      prov.setSelectedIndex(0);
    });
    _initStreams();
  }

  void _initStreams() {
    _missionsEnCoursStream = TrxDb.instance.fetchMissionsOnPb(
      searchMissionController.text,
      false,
    );
  }

  @override
  void dispose() {
    searchMissionController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _newMission(BuildContext context) {
    showModalBottomSheet(
      //
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      //
      context: context,
      builder: (context) {
        //
        return const NewMission();
      },
    );
  }

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final currentUser = PocketBaseDb.instance.pb.authStore.record;

    ///
    return Consumer<UserProvider>(
      builder: (_, prov, _) {
        ///

        ///
        return Scaffold(
          ///
          appBar: AppBar(
            automaticallyImplyLeading: false,
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
            actions: [
              GestureDetector(
                onTap: () {
                  _newMission(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 44,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Mission",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// Body content here
          body: Stack(
            children: [
              Column(
                children: [
                  // Search bar for history
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchBar(
                      controller: searchMissionController,
                      onChanged: (val) {
                        if (_searchDebounce?.isActive ?? false) {
                          _searchDebounce?.cancel();
                        }
                        _searchDebounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            setState(() {
                              _initStreams();
                            });
                          },
                        );
                      },
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
                            setState(() {
                              searchMissionController.clear();
                            });
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
                      hintText: "Chercher une mission en cours",
                      hintStyle: WidgetStatePropertyAll(
                        Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Tab content
                  Expanded(
                    child:
                        /// Missions en cours
                        MissionsStreamWrapper(
                          missionsStream: _missionsEnCoursStream,
                          emptyState: _buildEmptyState(context),
                          title: "Mes missions en cours",
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
                              break;
                            case 1:
                              prov.navigateWithFade(
                                context,
                                const ClosedMissions(),
                              );
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

  ///* EXTRACTED METHODS */

  ///

  Container _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              height: 250,
              child: SvgPicture.asset("assets/empty-mission.svg"),
            ),
            Text(
              "Pas de mission\nen cours pour le moment !",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              "Créer une mission et suivez vos\nentrées et sorties",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            MaterialButton(
              onPressed: () {
                //
                _newMission(context);
                //
              },
              splashColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
              color: Colors.transparent,
              elevation: 0,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(90),
                side: BorderSide(
                  width: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                "Ajouter une mission",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
