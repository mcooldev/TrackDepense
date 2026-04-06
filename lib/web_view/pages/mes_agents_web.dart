import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/widgets/mission_container_widget.dart';

import '../../helpers/pocketBaseHelper/pocketbase_db.dart';
import '../web_providers/home_web_provider.dart';
import '../web_widgets/agent_card_widget_web.dart';

class MesAgentsWeb extends StatefulWidget {
  const MesAgentsWeb({super.key});

  @override
  State<MesAgentsWeb> createState() => _MesAgentsWebState();
}

class _MesAgentsWebState extends State<MesAgentsWeb> {
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
                      const SizedBox(height: 20),
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Agents actifs • ${prov.activeAgents.toString().padLeft(2, "0")}",
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                      // Agents list
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //
                          Expanded(
                            child: GridView.builder(
                              itemCount: prov.agentList.length,
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.25,
                                  ),
                              itemBuilder: (context, index) {
                                //
                                final agent = prov.agentList[index];

                                //
                                return AgentCardWidgetWeb(
                                  agent: agent,
                                  isSelected: prov.selectedAgent == agent,
                                );
                              },
                            ),
                          ),

                          /// side content
                          Container(
                            width: 350,
                            margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: prov.selectedAgent == null
                                ? const Center(
                                    child: Text("Aucun agent sélectionné"),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // Name symbol
                                          CircleAvatar(
                                            radius: 32,
                                            backgroundColor: theme.colorScheme.primary,
                                            child: Text(
                                              prov.selectedAgent?.name
                                                      ?.split(" ")[0]
                                                      .substring(0, 1)
                                                      .toUpperCase() ??
                                                  "I",
                                              style: theme.textTheme.bodyLarge!
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 20,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // agent name
                                                Text(
                                                  prov.selectedAgent?.name
                                                          ?.toUpperCase() ??
                                                      "Inconnu",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                      ),
                                                ),
                                                const SizedBox(height: 6),
                                                // agent email
                                                Text(
                                                  prov.selectedAgent?.email ??
                                                      "inconnu@inconnu.com",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Divider(
                                        thickness: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 12),
                                      // headline mission
                                      Text(
                                        "Missions de l'agent • ${prov.missions.where((m) => m.user == prov.selectedAgent?.name).length.toString().padLeft(2, "0")}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                            ),
                                      ),
                                      const SizedBox(height: 20),
                                      // mission list
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: prov.missions
                                            .where(
                                              (m) =>
                                                  m.user ==
                                                  prov.selectedAgent?.name,
                                            )
                                            .length,
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(height: 12);
                                        },

                                        itemBuilder: (context, index) {
                                          //
                                          final mission = prov.missions
                                              .where(
                                                (m) =>
                                                    m.user ==
                                                    prov.selectedAgent?.name,
                                              )
                                              .toList()[index];

                                          //
                                          return MissionContainerWidget(
                                            onTap: () {
                                              Future.microtask(() {
                                                prov.selectedMission = mission;
                                                prov.selectedIndex = -1;
                                              });
                                            },
                                            missionName: mission.nom,
                                            dateDebut: mission.dateDebut
                                                .toString(),
                                            dateFin: mission.dateFin.toString(),
                                            capitale: mission.capitale,
                                            capitalInitial:
                                                mission.capitaleInitial,
                                            missionIcon: mission.nom.substring(
                                              0,
                                              1,
                                            ),
                                            montantObjectif: mission.amountGoal,
                                            isClosed: mission.isClosed,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                          ),
                        ],
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
