import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  });

  final String missionName;
  final String dateDebut;
  final String dateFin;
  final String capitale;
  final String capitalInitial;
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

    ///
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// Icon & Mission name
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        width: 0.5,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xffdcdfe3),
                      ),
                    ),
                    child: Text(
                      missionIcon,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(width: 10),
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
                        const SizedBox(height: 2),

                        /// Date de début et de fin
                        Text(
                          "Du ${formattedDate.format(DateTime.parse(dateDebut))} • Au ${formattedDate.format(DateTime.parse(dateFin))}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),
            /// Capitale actuel et initial
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
                  /// Montant de la capitale actuelle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Capitale de départ: ",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        formattedCurrency.format(int.parse(capitalInitial)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// Montant du capital actuel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Solde actuel: ",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        formattedCurrency.format(int.parse(capitale)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          // fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
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
