import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/providers/transaction_provider.dart';

import '../models/transaction_model.dart';
import '../pages/mission_detail.dart';
import 'mission_container_widget.dart';

class MissionsListView extends StatefulWidget {
  const MissionsListView({
    super.key,
    required this.missions,
    required this.emptyState,
    required this.title,
  });

  final List<Mission> missions;
  final Widget emptyState;
  final String title;

  @override
  State<MissionsListView> createState() => _MissionsListViewState();
}

class _MissionsListViewState extends State<MissionsListView> {
  @override
  Widget build(BuildContext context) {
    //
    return Consumer<TransactionProvider>(
      builder: (_, prov, _) {
        ///
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
                      "${widget.missions.length.toString().padLeft(2, '0')} mission${widget.missions.length == 1 ? '' : 's'}",
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
            if (widget.missions.isEmpty)
              SliverToBoxAdapter(child: widget.emptyState)
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: widget.missions.length,
                    (context, i) {
                      //
                      final mission = widget.missions[i];

                      //
                      return MissionContainerWidget(
                        onTap: () {
                          Navigator.of(context)
                              .push(
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
