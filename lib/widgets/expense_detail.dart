import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:track_depenses/providers/share_files_providers.dart';
import 'package:track_depenses/widgets/expense_receipt.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'new_expense.dart';

class ExpenseDetail extends StatefulWidget {
  const ExpenseDetail({
    super.key,
    required this.depense,
    required this.mission,
  });

  final Depense depense;
  final Mission mission;

  @override
  State<ExpenseDetail> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends State<ExpenseDetail> {
  ///
  final db = '';
  final userId = '';

  // todo: set database and user id

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final currencyFormatter = NumberFormat.currency(
      locale: "fr_FR",
      symbol: "F",
      decimalDigits: 0,
    );

    // Show bottom sheet
    void showBottomSheet(BuildContext context, Widget child, bool isScroll) {
      showModalBottomSheet(
        isScrollControlled: isScroll,
        useSafeArea: true,
        showDragHandle: true,
        context: context,
        builder: (context) {
          return child;
        },
      );
    }

    // Delete depense dialog
    Future<void> deleteDepenseDialog(
      BuildContext context,
      Depense depense,
    ) async {
      //
      final confirm = await showDialog<bool>(
        useSafeArea: true,
        context: context,
        builder: (context) => AlertDialog(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 30,
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xff11181C)
              : Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🗑️", style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 16),
              Text(
                "Êtes-vous sûr de vouloir supprimer cette dépense ?",
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.pop(context, false),
              minWidth: MediaQuery.sizeOf(context).width * 0.3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
              ),
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              child: Text(
                "Annuler",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            MaterialButton(
              onPressed: () => Navigator.pop(context, true),
              minWidth: MediaQuery.sizeOf(context).width * 0.3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
              ),
              elevation: 0,
              color: Theme.of(context).colorScheme.primary,
              child: Text(
                "Supprimer",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      );
      //
      if (confirm == true) {
        if (!context.mounted) return;
        final prov = Provider.of<TransactionProvider>(context, listen: false);
        Navigator.of(context).pop();
        //
        prov.removeDepense(widget.mission, depense);
        //
        prov.clearControllers();
        //
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("🗑️ • Dépense supprimée avec succès"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
            ),
          ),
        );
      }
    }

    final shareProv = Provider.of<ShareFilesProvider>(context, listen: false);

    ///

    return Consumer<TransactionProvider>(
      builder: (_, prov, _) {
        ///
        final currentMission = widget.mission;
        final expense = widget.depense;

        ///
        return Scaffold(
          appBar: AppBar(
            title: const Text("Détails de la dépense"),
            centerTitle: false,
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: [
              IconButton(
                onPressed: () async {
                  // todo: share expense receipt as image
                  await shareProv.shareAsImage(context);
                },
                icon: shareProv.isCapturing
                    ? const CircularProgressIndicator.adaptive()
                    : Icon(
                        CupertinoIcons.share,
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
            ],
          ),

          ///
          body: Stack(
            children: [
              /// Normal content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(80),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.arrow_down_circle,
                                    size: 32,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Titre de la dépense",
                                        softWrap: true,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        expense.description,
                                        softWrap: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge!
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
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Date :",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      "Le ${DateFormat("dd/MM/yyyy").format(expense.date)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Montant :",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      "- ${currencyFormatter.format(expense.montant)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Categorie
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Catégorie :",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      expense.categorie,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre du justificatif
                        Text(
                          "Pièce justificative",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        // Image justificative
                        Container(
                          height: MediaQuery.sizeOf(context).height * 0.4,
                          width: MediaQuery.sizeOf(context).width,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1.5,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.white,
                            ),
                          ),
                          child:
                              (expense.justificatif == null ||
                                  expense.justificatif!.isEmpty)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.photo_fill,
                                      size: 70,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.2),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Pas de justificatif ajouté",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(expense.justificatif!.toString()),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Buttons
                    if (currentMission.isClosed == false)
                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              onPressed: () async {
                                // todo: delete expense
                                await deleteDepenseDialog(context, expense);
                                //
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              elevation: 0,
                              height: 44,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white,
                              child: Text(
                                "Supprimer",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MaterialButton(
                              onPressed: () {
                                // todo: edit expense
                                showBottomSheet(
                                  context,
                                  NewExpense(
                                    mission: currentMission,
                                    depenseToEdit: expense,
                                  ),
                                  true,
                                );
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80),
                              ),
                              elevation: 0,
                              height: 44,
                              color: Theme.of(context).colorScheme.primary,
                              child: Text(
                                "Modifier",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),

              /// Expense receipt
              Positioned(
                left: MediaQuery.of(context).size.width + 1000,
                child: Screenshot(
                  controller: shareProv.screenshotController,
                  child: ExpenseReceipt(
                    mission: currentMission,
                    expense: expense,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
