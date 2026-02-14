import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:track_depenses/providers/share_files_providers.dart';
import 'package:track_depenses/widgets/expense_receipt.dart';
import 'package:track_depenses/widgets/new_entree.dart';

import '../helpers/pocketBaseHelper/trx_db.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'new_expense.dart';

class ExpenseDetail extends StatefulWidget {
  const ExpenseDetail({
    super.key,
    required this.trxMission,
    required this.mission,
    required this.isEntree,
  });

  final dynamic trxMission;
  final Mission mission;
  final bool isEntree;

  @override
  State<ExpenseDetail> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends State<ExpenseDetail> {
  ///
  final trxDb = TrxDb.instance;
  UnsubscribeFunc? subscribe;

  @override
  void initState() {
    super.initState();
    //
    _subscribeToTrxChange();
  }

  void _subscribeToTrxChange() async {
    subscribe = await trxDb.pb
        .collection(widget.isEntree ? "entrees" : "depenses")
        .subscribe(widget.trxMission.id, (e) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  @override
  void dispose() {
    subscribe?.call();
    super.dispose();
  }

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

    final shareProv = Provider.of<ShareFilesProvider>(context, listen: false);
    final prov = Provider.of<TransactionProvider>(context, listen: false);

    ///

    return StreamBuilder<List<dynamic>>(
      stream: trxDb.fetchEntreesAndDepensesOnPb(widget.mission.id ?? '', ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        //

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Une erreur s'est produite lors du chargement des données.",
              ),
            ),
          );
        }

        ///

        final transactions = snapshot.data ?? [];

        dynamic currentTrx;

        if (widget.isEntree) {
          currentTrx = transactions.whereType<Entree>().firstWhere(
            (e) => e.id == widget.trxMission.id,
            orElse: () => widget.trxMission,
          );
        } else {
          currentTrx = transactions.whereType<Depense>().firstWhere(
            (d) => d.id == widget.trxMission.id,
            orElse: () => widget.trxMission,
          );
        }

        final expense = currentTrx is Depense ? currentTrx : null;
        final entree = currentTrx is Entree ? currentTrx : null;
        final currentMission = widget.mission;

        ///
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isEntree ? "Détails de l'entrée" : "Détails de la dépense",
            ),
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
                                        : widget.isEntree
                                        ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withValues(alpha: 0.15)
                                        : Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(80),
                                  ),
                                  child: Icon(
                                    widget.isEntree
                                        ? CupertinoIcons.arrow_up_circle
                                        : CupertinoIcons.arrow_down_circle,
                                    size: 32,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : widget.isEntree
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
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
                                        widget.isEntree
                                            ? "Titre de l'entrée"
                                            : "Titre de la dépense",
                                        softWrap: true,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        currentTrx.description,
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
                                      "Le ${DateFormat("dd/MM/yyyy").format(currentTrx.createdAt ?? DateTime.now())}",
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
                                      widget.isEntree
                                          ? "+ ${currencyFormatter.format(entree?.montant ?? 0.0)}"
                                          : "- ${currencyFormatter.format(expense?.montant ?? 0.0)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : widget.isEntree
                                                ? CupertinoColors.systemGreen
                                                : Colors.red,
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
                                      currentTrx.categorie,
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
                              (currentTrx.justificatif == null ||
                                  currentTrx.justificatif!.isEmpty)
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
                                  child: Builder(
                                    builder: (context) {
                                      //
                                      ///* http://127.0.0.1:8090/api/files/COLLECTION_ID_OR_NAME/RECORD_ID/FILENAME */
                                      //
                                      final baseUrl = trxDb.pb.baseURL;
                                      final collectionName = widget.isEntree
                                          ? "entrees"
                                          : "depenses";
                                      final recordId = currentTrx.id;
                                      final fileName = currentTrx.justificatif;
                                      //
                                      final imageUrl =
                                          "$baseUrl/api/files/$collectionName/$recordId/$fileName";
                                      log("Path justificatif: $imageUrl");
                                      //
                                      return Image.network(
                                        imageUrl,
                                        headers: const {
                                          "ngrok-skip-browser-warning": "1",
                                        },
                                        loadingBuilder:
                                            (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) => loadingProgress == null
                                            ? child
                                            : const CircularProgressIndicator.adaptive(),
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                        fit: BoxFit.cover,
                                      );
                                    },
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
                                // todo: delete transaction
                                await prov.deleteTrxDialog(
                                  context,
                                  currentTrx,
                                  widget.isEntree,
                                );
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
                              child: const Text(
                                "Supprimer",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MaterialButton(
                              onPressed: () {
                                if (widget.isEntree) {
                                  showBottomSheet(
                                    context,
                                    NewEntree(
                                      mission: currentMission,
                                      entreeToEdit: entree,
                                    ),
                                    true,
                                  );
                                }
                                //
                                if (!widget.isEntree) {
                                  showBottomSheet(
                                    context,
                                    NewExpense(
                                      mission: currentMission,
                                      depenseToEdit: expense,
                                    ),
                                    true,
                                  );
                                }
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
                    trx: currentTrx,
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
