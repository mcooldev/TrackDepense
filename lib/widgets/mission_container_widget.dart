import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  });

  final String missionName;
  final String dateDebut;
  final String dateFin;
  final double capitale;
  final double? montantObjectif;
  final double capitalInitial;
  final String missionIcon;
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
    final prov = Provider.of<TransactionProvider>(context, listen: false);

    //
    final calculatedPercent = montantObjectif == null
        ? 0.0
        : prov.calculatePercent(capitale, montantObjectif!);
    final textPercent = "${(calculatedPercent * 100).toStringAsFixed(0)}%";

    ///
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          // border: Border.all(
          //   color: Theme.of(context).brightness == Brightness.dark
          //       ? Colors.white.withValues(alpha: 0.1)
          //       : Colors.grey.shade200,
          //   width: 1,
          // ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// Mission name, date and mission amount goal
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const SizedBox(height: 8),

                        /// Mission amount goal
                        Container(
                          padding: const EdgeInsets.fromLTRB(
                            8, 6, 12, 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(80),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.rocket,
                                size: 20,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formattedCurrency.format(
                                  montantObjectif ?? 0.0,
                                ),
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Circular percent indicator
                  CircularPercentIndicator(
                    radius: 40,
                    lineWidth: 7,
                    percent: calculatedPercent,
                    center: Text(
                      textPercent,
                      style: const TextStyle(fontSize: 18),
                    ),
                    backgroundColor: Colors.white,
                    progressColor: Theme.of(context).colorScheme.primary,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            /// Capitale initial et solde actuel
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                        "Capitale de départ : ",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        formattedCurrency.format(capitalInitial),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 18,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

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
                            capitale >= capitalInitial
                                ? CupertinoIcons.arrow_up
                                : CupertinoIcons.arrow_down,
                            color: capitale >= capitalInitial
                                ? Colors.green
                                : Colors.red,
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
                                  color: capitale >= capitalInitial
                                      ? Colors.green
                                      : Colors.red,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
