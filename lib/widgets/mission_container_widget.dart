import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

class MissionContainerWidget extends StatelessWidget {
  const MissionContainerWidget({
    super.key,
    required this.missionName,
    required this.dateDebut,
    required this.dateFin,
    required this.capitale,
    required this.capitalInitial,
    required this.missionIcon,
    required this.onTap,
    required this.montantObjectif,
    required this.isClosed,
    this.missionUser,
  });

  final String missionName;
  final String? missionUser;
  final String dateDebut;
  final String dateFin;
  final double capitale;
  final double? montantObjectif;
  final double capitalInitial;
  final String missionIcon;
  final bool isClosed;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    ///
    final formattedDate = DateFormat("dd/MM/yyyy");
    final formattedCurrency = NumberFormat.currency(
      locale: "fr_FR",
      symbol: "F",
      decimalDigits: 0,
    );
    //
    final prov = context.read<TransactionProvider>();

    //
    final calculatedPercent = montantObjectif == null
        ? 0.0
        : prov.calculatePercent(capitale, montantObjectif!);
    final textPercent = "${(calculatedPercent * 100).toStringAsFixed(0)}%";

    ///
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Mission name, date and mission amount goal
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            missionName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),

                          /// Date de début et de fin
                          Text(
                            "Du ${formattedDate.format(DateTime.parse(dateDebut))} • Au ${formattedDate.format(DateTime.parse(dateFin))}",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.copyWith(fontSize: 15),
                          ),
                          //
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    // Circular percent indicator
                    if (montantObjectif != null)
                      CircularPercentIndicator(
                        radius: 40,
                        lineWidth: 7,
                        percent: calculatedPercent,
                        center: Text(
                          montantObjectif! > 0 ? textPercent : '-N/A-',
                          style: const TextStyle(fontSize: 18),
                        ),
                        backgroundColor: Colors.white,
                        progressColor: Theme.of(context).colorScheme.primary,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                  ],
                ),
              ),

              /// Mission state and amount goal
              Row(
                children: [
                  const SizedBox(width: 12),
                  // Mission state
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                    decoration: BoxDecoration(
                      color: isClosed
                          ? CupertinoColors.systemRed
                          : Colors.green,
                      borderRadius: BorderRadius.circular(80),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isClosed
                              ? CupertinoIcons.archivebox
                              : CupertinoIcons.arrow_right,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isClosed ? "Clôturée" : "En cours",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mission amount goal
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                    decoration: BoxDecoration(
                      color: montantObjectif == 0
                          ? Colors.grey
                          : Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(80),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.rocket,
                          size: 20,
                          color: montantObjectif == 0
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedCurrency.format(montantObjectif ?? 0.0),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: montantObjectif == 0
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// Capitale initial et solde actuel
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    /// Capitale actuelle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Budget Initial : ",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          formattedCurrency.format(capitalInitial),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                fontSize: 18,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// Solde actuel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Solde actuel : ",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Row(
                          children: [
                            Icon(
                              capitale > 0
                                  ? CupertinoIcons.arrow_right
                                  : CupertinoIcons.arrow_down,
                              color: capitale > 0 ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formattedCurrency.format(capitale),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: capitale > 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    /// Agent de mission
                    if (kIsWeb && missionUser != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedUser03,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Agent :",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            missionUser ?? "Agent inconnu",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
