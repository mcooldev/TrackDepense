import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class ExpenseReceipt extends StatelessWidget {
  const ExpenseReceipt({
    super.key,
    required this.mission,
    required this.expense,
  });

  final Mission mission;
  final Depense expense;

  @override
  Widget build(BuildContext context) {
    ///
    final mediaQuery = MediaQuery.sizeOf(context);
    final currencyFormatter = NumberFormat.currency(
      locale: "fr_FR",
      symbol: "F",
      decimalDigits: 0,
    );

    ///
    return Container(
      width: mediaQuery.width,
      height: mediaQuery.height,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          // Titre du justificatif
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  backgroundImage: const AssetImage(
                    "assets/td_launcher_icon.png",
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  mission.nom,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "REÇU DE LA DÉPENSE",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          // Description, date, montant, categorie
          Container(
            padding: const EdgeInsets.all(4),
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_down_circle,
                          size: 32,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Titre de la dépense",
                              softWrap: true,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              expense.description,
                              softWrap: true,
                              style: Theme.of(context).textTheme.headlineLarge!
                                  .copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Details
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      // Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Date :",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            "Le ${DateFormat("dd/MM/yyyy").format(expense.date)}",
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Montant
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Montant :",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            "- ${currencyFormatter.format(expense.montant)}",
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Categorie
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Catégorie :",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            expense.categorie,
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
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
          const SizedBox(height: 24),

          /// Image justificative

          // Titre du justificatif
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Pièce justificative",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Image justificative
          Container(
              height: MediaQuery.sizeOf(context).height * 0.4,
              width: MediaQuery.sizeOf(context).width,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1.5,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white,
                ),
              ),
              child: expense.justificatif == null || expense.justificatif == ""
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.photo,
                          size: 70,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Pas de justificatif ajouté",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(expense.justificatif.toString()),
                        fit: BoxFit.contain,
                      ),
                    ),
            ),

          const SizedBox(height: 24),

          ///* End of receipt *///
        ],
      ),
    );
  }
}
