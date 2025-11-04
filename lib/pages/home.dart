import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/pages/mission_detail.dart';
import 'package:track_depenses/pages/profile.dart';
import 'package:track_depenses/widgets/new_mission.dart';

import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/mission_container_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ///

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
    final trans = Provider.of<TransactionProvider>(context);

    ///
    return Consumer<UserProvider>(
      builder: (_, prov, _) {
        ///
        final filteredOnGoingMissions = trans.filteredOnGoingMission;

        ///
        return DefaultTabController(
          length: 2,
          child: Scaffold(
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
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white,
                      backgroundImage: prov.image != null
                          ? FileImage(prov.image!)
                          : null,
                      child: prov.image != null
                          ? null
                          : Text(
                              prov.userName.isNotEmpty
                                  ? prov.userName.characters.first
                                  : "?",
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 20,
                              ),
                            ),
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
                        prov.userName.isNotEmpty
                            ? prov.userName.split(" ")[0]
                            : "Inconnu",
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
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
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
                        controller: trans.searchMissionController,
                        onChanged: (query) {
                          trans.filterOnGoingMissionByName(
                            trans.searchMissionController.text,
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
                              : Colors.white,
                        ),
                        hintText: "Chercher une mission en cours",
                        hintStyle: WidgetStatePropertyAll(
                          Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),

                    /// Tabs
                    TabBar(
                      dividerColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.grey.shade300,
                      splashBorderRadius: BorderRadius.circular(90),
                      indicatorColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      labelColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      unselectedLabelColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.4)
                          : Theme.of(context).colorScheme.onSurface,
                      tabs: const [
                        Tab(text: "Missions en cours"),
                        Tab(text: "Missions clôturées"),
                      ],
                    ),

                    /// Tab content
                    Expanded(
                      child: TabBarView(
                        children: [
                          /// Missions en cours
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              24,
                              16.0,
                              50,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                /// Missions headline
                                Text(
                                  trans.isSearching == true
                                      ? "Recherche en cours..."
                                      : "Mes missions en cours",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),

                                /// Missions container
                                trans.missions.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width:
                                                  MediaQuery.sizeOf(
                                                    context,
                                                  ).width *
                                                  0.3,
                                              height: 250,
                                              child: SvgPicture.asset(
                                                "assets/empty-mission.svg",
                                              ),
                                            ),
                                            Text(
                                              "Pas de mission\nen cours pour le moment !",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(fontSize: 18),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Créer une mission et suivez vos\nentrées et sorties",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                            const SizedBox(height: 24),
                                            MaterialButton(
                                              onPressed: () {
                                                //
                                                _newMission(context);
                                                //
                                              },
                                              splashColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.15),
                                              color: Colors.transparent,
                                              elevation: 0,
                                              height: 50,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(90),
                                                side: BorderSide(
                                                  width: 1,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.2,
                                                        )
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Text(
                                                "Ajouter une mission",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      fontSize: 17,
                                                      color:
                                                          Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount:
                                            filteredOnGoingMissions.length,
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (ctx, index) {
                                          //
                                          final mission =
                                              filteredOnGoingMissions[index];

                                          //
                                          return MissionContainerWidget(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      MissionDetail(
                                                        mission: mission,
                                                      ),
                                                ),
                                              );
                                            },
                                            missionIcon: mission.nom.substring(
                                              0,
                                              1,
                                            ),
                                            montantObjectif: mission.amountGoal,
                                            missionName: mission.nom,
                                            dateDebut: mission.dateDebut
                                                .toString(),
                                            dateFin: mission.dateFin.toString(),
                                            capitale: mission.capitale,
                                            capitalInitial:
                                                mission.capitaleInitial,
                                          );
                                        },
                                      ),
                              ],
                            ),
                          ),

                          /// Missions clôturées
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              24,
                              16.0,
                              50,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                /// Missions headline
                                Text(
                                  "Mes missions clôturées",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),

                                /// Missions container
                                trans.closedMissions.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 70,
                                        ),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width:
                                                  MediaQuery.sizeOf(
                                                    context,
                                                  ).width *
                                                  0.3,
                                              height: 100,
                                              child: SvgPicture.asset(
                                                "assets/empty.svg",
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Pas de mission\nclôturée pour le moment !",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(fontSize: 18),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Veuillez voir vos missions en cours",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: trans.closedMissions.length,
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (ctx, index) {
                                          //
                                          final mission =
                                              trans.closedMissions[index];

                                          //
                                          return MissionContainerWidget(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      MissionDetail(
                                                        mission: mission,
                                                      ),
                                                ),
                                              );
                                            },
                                            missionIcon: mission.nom.substring(
                                              0,
                                              1,
                                            ),
                                            montantObjectif: mission.amountGoal,
                                            missionName: mission.nom,
                                            dateDebut: mission.dateDebut
                                                .toString(),
                                            dateFin: mission.dateFin.toString(),
                                            capitale: mission.capitale,
                                            capitalInitial:
                                                mission.capitaleInitial,
                                          );
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
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
                                prov.navigateWithFade(context, const Profile());
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
          ),
        );
      },
    );
  }
}
