import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/widgets/mission_container_widget.dart';

import '../../helpers/error_helper.dart';
import '../../helpers/pocketBaseHelper/pocketbase_db.dart';
import '../../models/transaction_model.dart';
import '../web_providers/home_web_provider.dart';

class ClosedMissionWeb extends StatefulWidget {
  const ClosedMissionWeb({super.key});

  @override
  State<ClosedMissionWeb> createState() => _ClosedMissionWebState();
}

class _ClosedMissionWebState extends State<ClosedMissionWeb> {
  ///
  final pb = PocketBaseDb.instance.pb;
  Future? orgFuture;

  @override
  void initState() {
    super.initState();
    final currentUser = pb.authStore.record;
    final orgId = currentUser?.getStringValue("organizationId");
    if (orgId != null) {
      orgFuture = pb.collection("organizations").getOne(orgId);
    }
  }

  final TextEditingController searchMissionController = TextEditingController();
  Timer? _searchDebounce;

  final formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'F',
    decimalDigits: 0,
  );

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce!.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      context
          .read<HomeWebProvider>()
          .fetchMissionsWeb(isClosed: true, searchQuery: value)
          .catchError((e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("❌ • ${parsePbError(e)}"),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: const StadiumBorder(),
                ),
              );
            }
            return <Mission>[];
          });
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final theme = Theme.of(context);

    ///
    return Consumer<HomeWebProvider>(
      builder: (_, prov, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 20, 40, 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Nav bar
                      _topNavBar(prov, theme),
                      const SizedBox(height: 40),

                      /* MISSION LIST VIEW */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mes missions clôturées",
                            style: theme.textTheme.titleLarge,
                          ),
                          SizedBox(
                            width: 500,
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
                                EdgeInsets.only(left: 20, right: 8),
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      prov.isLoading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : GridView.builder(
                              itemCount: prov.closedMissions.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.25,
                                  ),
                              itemBuilder: (context, index) {
                                //
                                final mission = prov.closedMissions[index];

                                //
                                return MissionContainerWidget(
                                  onTap: () {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          prov.selectedMission = mission;
                                          prov.selectedIndex = -1;
                                        });
                                  },
                                  missionName: mission.nom,
                                  dateDebut: mission.dateDebut.toString(),
                                  dateFin: mission.dateFin.toString(),
                                  capitale: mission.capitale,
                                  capitalInitial: mission.capitaleInitial,
                                  missionIcon: mission.nom.substring(0, 1),
                                  montantObjectif: mission.amountGoal,
                                  isClosed: mission.isClosed,
                                  missionUser: mission.user,
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  ///* END OF BUILD METHOD • EXTRACTED METHODS */

  Row _topNavBar(HomeWebProvider prov, ThemeData theme) {
    final pb = PocketBaseDb.instance.pb;
    final currentUser = pb.authStore.record;
    if (currentUser == null) return const Row();
    final currentUserName = currentUser.getStringValue("name");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greetings
            Text(prov.greetings, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              currentUserName.split(" ")[0],
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 26,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        // Avatar
        FutureBuilder(
          future: orgFuture,
          builder: (context, snapshot) {
            //
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            final record = snapshot.data;
            if (record == null) {
              return _buildDefaultAvatar();
            }

            final logoUrl = pb.files.getUrl(
              record,
              record.getStringValue("logo"),
            );
            final orgName = record.getStringValue("name");

            final subsUntil = DateTime.parse(
              record.getStringValue("subscription_until"),
            );

            final beforeTwoWeeks = DateTime.now().add(const Duration(days: 14));

            final alertDate = subsUntil.isBefore(beforeTwoWeeks);

            //
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Alert end subscription
                if (alertDate)
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: Colors.red,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedTimeQuarterPass,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Abonnement bientôt expiré",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                // Avatar & Organization name
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: CachedNetworkImage(
                          imageUrl: logoUrl.toString(),
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                          errorWidget: (context, url, error) => const HugeIcon(
                            icon: HugeIcons.strokeRoundedUnavailable,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      orgName,
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(120),
      ),
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedUser03,
        size: 24,
        color: Colors.grey.shade400,
      ),
    );
  }
}
