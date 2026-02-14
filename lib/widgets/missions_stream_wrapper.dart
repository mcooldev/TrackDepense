import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../pages/mission_detail.dart';
import 'mission_container_widget.dart';

class MissionsStreamWrapper extends StatefulWidget {
  const MissionsStreamWrapper({
    super.key,
    required this.missionsStream,
    required this.emptyState,
    required this.title,
  });

  final Stream<List<Mission>> missionsStream;
  final Widget emptyState;
  final String title;

  @override
  State<MissionsStreamWrapper> createState() => _MissionsStreamWrapperState();
}

class _MissionsStreamWrapperState extends State<MissionsStreamWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    //
    super.build(context);
    //
    return StreamBuilder<List<Mission>>(
      stream: widget.missionsStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Une erreur s'est produite lors du chargement des données.",
            ),
          );
        }
        final missions = snapshot.data ?? [];
        //
        if (missions.isEmpty) return widget.emptyState;

        //
        return CustomScrollView(
          slivers: [
            const SliverPadding(padding: EdgeInsets.only(top: 16)),

            /// Missions headline
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${missions.length.toString().padLeft(2, '0')} mission${missions.length == 1 ? '' : 's'}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            /// Mission container
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: missions.length,
                  (context, i) {
                    //
                    final mission = missions[i];

                    //
                    return MissionContainerWidget(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                MissionDetail(mission: mission),
                          ),
                        );
                      },
                      missionIcon: mission.nom.substring(0, 1),
                      montantObjectif: mission.amountGoal,
                      missionName: mission.nom,
                      dateDebut: mission.dateDebut.toString(),
                      dateFin: mission.dateFin.toString(),
                      capitale: mission.capitale,
                      capitalInitial: mission.capitaleInitial,
                      isClosed: mission.isClosed,
                    );
                  },
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      },
    );
  }
}
