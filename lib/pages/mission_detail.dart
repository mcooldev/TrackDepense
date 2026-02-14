import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/trx_db.dart';
import 'package:track_depenses/providers/share_files_providers.dart';
import 'package:track_depenses/widgets/expense_detail.dart';
import 'package:track_depenses/widgets/new_entree.dart';
import 'package:track_depenses/widgets/new_mission.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_entry_widget.dart';
import '../widgets/new_expense.dart';

class MissionDetail extends StatefulWidget {
  const MissionDetail({super.key, required this.mission});

  final Mission mission;

  @override
  State<MissionDetail> createState() => _MissionDetailState();
}

class _MissionDetailState extends State<MissionDetail> {
  ///

  final searchController = TextEditingController();

  Timer? _searchDebounce;

  final formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'F',
    decimalDigits: 0,
  );
  final formattedDate = DateFormat("dd/MM/yyyy");

  // Show bottom sheet
  void _showBottomSheet(BuildContext context, Widget child, bool isScroll) {
    showModalBottomSheet(
      isScrollControlled: isScroll,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return child;
      },
    ).then((val) {
      if (!mounted) return;
      if (val != null && val is Mission) {
        setState(() {
          widget.mission.nom = val.nom;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.mission.id == null) {
      Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final shareProv = Provider.of<ShareFilesProvider>(context, listen: false);
    final trxDb = TrxDb.instance;

    ///
    return Consumer<TransactionProvider>(
      builder: (context, prov, child) {
        return StreamBuilder(
          stream: trxDb.fetchEntreesAndDepensesOnPb(
            widget.mission.id ?? '',
            searchController.text.trim(),
          ),
          builder: (context, snapshot) {
            ///
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator.adaptive()),
              );
            }
            //
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Une erreur s'est produite lors du chargement des données.",
                ),
              );
            }

            ///
            final filteredTxnList = snapshot.data ?? [];
            final currentMission = widget.mission;
            //
            final opEntrees = filteredTxnList.whereType<Entree>().toList();
            final opDepenses = filteredTxnList.whereType<Depense>().toList();
            //
            final totalEntrees = opEntrees.fold<double>(
              0,
              (prev, current) => prev + current.montant,
            );
            final totalDepenses = opDepenses.fold<double>(
              0,
              (prev, current) => prev + current.montant,
            );
            //
            double dynamicCapital = totalEntrees - totalDepenses;
            //
            if (dynamicCapital < 0) {
              dynamicCapital = 0;
            }
            //
            final calculatedPercent = currentMission.amountGoal == null
                ? 0.0
                : prov.calculatePercent(
                    dynamicCapital,
                    currentMission.amountGoal!,
                  );
            final textPercent =
                "${(calculatedPercent * 100).toStringAsFixed(0)}%";
            //
            ///
            return Scaffold(
              ///
              appBar: AppBar(
                actions: [
                  if (!currentMission.isClosed)
                    // Update mission
                    GestureDetector(
                      onTap: () {
                        // todo: update mission
                        _showBottomSheet(
                          context,
                          NewMission(missionToEdit: currentMission),
                          true,
                        );
                        //
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(90),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white,
                          border: Border.all(
                            width: 1,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedEdit02,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24.0,
                        ),
                      ),
                    ),
                  // Delete mission
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white,
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        await prov.deleteMissionDialog(context, widget.mission);
                      },
                      child: Text(
                        "Supprimer",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              ///
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mission name, date and state
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mission name
                        Text(
                          currentMission.nom,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                        // Mission date
                        Text(
                          "Du ${formattedDate.format(currentMission.dateDebut)} • Au ${formattedDate.format(currentMission.dateFin)}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Mission state
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: currentMission.isClosed == true
                                    ? Colors.red
                                    : Colors.green,
                                borderRadius: BorderRadius.circular(80),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    currentMission.isClosed
                                        ? CupertinoIcons.archivebox
                                        : CupertinoIcons.arrow_right,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentMission.isClosed == true
                                        ? "Clôturée"
                                        : "En cours",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            // Mission amount goal
                            if (currentMission.amountGoal != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
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
                                        formatter.format(
                                          currentMission.amountGoal ?? 0.0,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
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
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Mission summary
                    missionSummaryContainer(
                      context,
                      currentMission,
                      filteredTxnList,
                      opEntrees,
                      opDepenses,
                      calculatedPercent,
                      textPercent,
                      dynamicCapital,
                    ),
                    const SizedBox(height: 16),

                    /// Mark mission as closed
                    if (currentMission.isClosed == false)
                      Column(
                        children: [
                          MaterialButton(
                            onPressed: () async {
                              await prov.closeMissionDialog(
                                context: context,
                                mission: currentMission,
                              );
                            },
                            splashColor: Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.15),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.white,
                            elevation: 0,
                            height: 50,
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90),
                              side: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "Clôturer la mission",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontSize: 17, color: Colors.red),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    else
                      Column(
                        children: [
                          // Share mission receipt as pdf
                          MaterialButton(
                            onPressed: () {
                              // todo: share mission receipt as pdf
                              shareProv.createAndSharePdf(
                                context,
                                currentMission,
                                filteredTxnList,
                              );
                            },
                            splashColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            color: Theme.of(context).colorScheme.primary,
                            elevation: 0,
                            height: 50,
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.share,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Partager le rapport • PDF",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Preview mission receipt as pdf
                          MaterialButton(
                            onPressed: () {
                              // todo: preview mission receipt as pdf
                              shareProv.previewPdf(
                                context,
                                currentMission,
                                filteredTxnList,
                              );
                            },
                            splashColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.white,
                            elevation: 0,
                            height: 50,
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90),
                              side: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.eye,
                                  size: 20,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Aperçu du rapport • PDF",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontSize: 17,
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
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // History headline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Historique",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          "${filteredTxnList.length.toString().padLeft(2, '0')} opération${filteredTxnList.length == 1 ? '' : 's'}",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Search bar for history
                    SearchBar(
                      controller: searchController,
                      onChanged: (query) {
                        //
                        if (_searchDebounce?.isActive ?? false) {
                          _searchDebounce!.cancel();
                        }
                        //
                        _searchDebounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            setState(() {
                              searchController.text = query.trim();
                            });
                          },
                        );
                        //
                      },
                      onTap: () {},
                      elevation: const WidgetStatePropertyAll(0),
                      onTapOutside: (pointer) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      leading: Icon(
                        CupertinoIcons.search,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.only(left: 20),
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withValues(alpha: 0.5)
                            : Colors.grey.shade100,
                      ),
                      hintText: "Chercher une entrée ou dépense",
                      hintStyle: WidgetStatePropertyAll(
                        Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),

                    const SizedBox(height: 16),
                    // History list
                    filteredTxnList.isEmpty
                        ? emptyTrxContainer(context)
                        : trxListContainer(
                            context,
                            filteredTxnList,
                            currentMission,
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  ///

  ///* EXTRACTED METHODS HERE */

  ///

  Container trxListContainer(
    BuildContext context,
    List<dynamic> filteredTxnList,
    Mission currentMission,
  ) {
    //
    final prov = Provider.of<TransactionProvider>(context, listen: false);
    //
    return Container(
      clipBehavior: Clip.antiAlias,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: ListView.separated(
        itemCount: filteredTxnList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        separatorBuilder: (context, i) => Divider(
          thickness: 1,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
        itemBuilder: (context, i) {
          //
          final op = filteredTxnList[i];
          // If mission is not closed yet
          if (!currentMission.isClosed) {
            return Slidable(
              key: ValueKey(op.id),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      // todo: update operation
                      if (op is Entree) {
                        _showBottomSheet(
                          context,
                          NewEntree(mission: currentMission, entreeToEdit: op),
                          true,
                        );
                      } else if (op is Depense) {
                        _showBottomSheet(
                          context,
                          NewExpense(
                            mission: currentMission,
                            depenseToEdit: op,
                          ),
                          true,
                        );
                      }
                    },
                    backgroundColor: op is Entree
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: op is Entree
                        ? Theme.of(context).colorScheme.onSecondary
                        : Theme.of(context).colorScheme.onPrimary,
                    icon: CupertinoIcons.pencil_ellipsis_rectangle,
                    label: 'Modifier',
                  ),
                  SlidableAction(
                    onPressed: (context) async {
                      if (op is Entree) {
                        if (op.id == null) return;
                        await prov.deleteTrxDialog(context, op, true);
                        //
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "🗑️ • Entrée supprimée avec succès",
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            shape: const StadiumBorder(),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else if (op is Depense) {
                        if (op.id == null) return;
                        await prov.deleteTrxDialog(context, op, false);
                        //
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "🗑️ • Dépense supprimée avec succès",
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            shape: const StadiumBorder(),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: CupertinoIcons.trash,
                    label: 'Supprimer',
                  ),
                ],
              ),
              child: ListTile(
                onTap: () {
                  if (op is Depense) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ExpenseDetail(
                          trxMission: op,
                          mission: currentMission,
                          isEntree: false,
                        ),
                      ),
                    );
                  }
                  //
                  if (op is Entree) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ExpenseDetail(
                          trxMission: op,
                          mission: currentMission,
                          isEntree: true,
                        ),
                      ),
                    );
                  }
                },
                //
                leading: op is Entree
                    ? Icon(
                        CupertinoIcons.arrow_up_circle_fill,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 32,
                      )
                    : Icon(
                        CupertinoIcons.arrow_down_circle_fill,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                title: Text(
                  op.description,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  formattedDate.format(op.createdAt),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: op is Entree
                    ? Text(
                        "+${formatter.format(double.parse(op.montant.toString()))}",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : CupertinoColors.systemGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        "-${formatter.format(double.parse(op.montant.toString()))}",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            );
          }
          // If mission is closed
          return ListTile(
            onTap: () {
              if (op is Depense) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExpenseDetail(
                      trxMission: op,
                      mission: currentMission,
                      isEntree: false,
                    ),
                  ),
                );
              }
              //
              if (op is Entree) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExpenseDetail(
                      trxMission: op,
                      mission: currentMission,
                      isEntree: true,
                    ),
                  ),
                );
              }
            },
            //
            leading: op is Entree
                ? Icon(
                    CupertinoIcons.arrow_up_circle_fill,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 32,
                  )
                : Icon(
                    CupertinoIcons.arrow_down_circle_fill,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
            title: Text(
              op.description,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              formattedDate.format(op.createdAt),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: op is Entree
                ? Text(
                    "+${formatter.format(double.parse(op.montant.toString()))}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : CupertinoColors.systemGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Text(
                    "-${formatter.format(double.parse(op.montant.toString()))}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Container emptyTrxContainer(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.tray,
            size: 44,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            "Aucune opération",
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Container missionSummaryContainer(
    BuildContext context,
    Mission currentMission,
    List<dynamic> operations,
    List<Entree> opEntrees,
    List<Depense> opDepenses,
    double calculatedPercent,
    String textPercent,
    double currentMissionCapital,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Solde actuel et dernière opération
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Solde actuel
                  Text(
                    "Solde actuel",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  // Current solde
                  Text(
                    formatter.format(currentMissionCapital),
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color:
                          (currentMissionCapital == 0 ||
                              currentMissionCapital < 0)
                          ? Colors.red
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Last operation
                  if (operations.isNotEmpty)
                    Text(
                      operations.first is Entree
                          ? "+ ${formatter.format(opEntrees.first.montant)}"
                          : "- ${formatter.format(opDepenses.first.montant)}",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: operations.first is Entree
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      "- 0F ajouté ni dépensé -",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              ),
              // Circular percent indicator
              if (currentMission.amountGoal != null)
                CircularPercentIndicator(
                  radius: 45,
                  lineWidth: 7,
                  percent: calculatedPercent,
                  center: Text(
                    textPercent,
                    style: const TextStyle(fontSize: 18),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  progressColor:
                      (currentMission.isClosed && calculatedPercent >= 1.0)
                      ? Colors.green
                      : (currentMission.isClosed && calculatedPercent < 1.0)
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
            ],
          ),

          /// Make new entry or new expense
          if (currentMission.isClosed == false)
            Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AddEntryWidget(
                        onTap: () {
                          // New entry
                          _showBottomSheet(
                            context,
                            NewEntree(mission: currentMission),
                            true,
                          );
                        },
                        containerBg: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                        textColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSecondary,
                        icon: CupertinoIcons.arrow_up,
                        iconColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSecondary,
                        textEntry: "Entrée",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AddEntryWidget(
                        onTap: () {
                          // New expense
                          if (currentMissionCapital == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "❌⚠️❌ • Votre budget est insuffisant",
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                shape: const StadiumBorder(),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          } else {
                            _showBottomSheet(
                              context,
                              NewExpense(mission: currentMission),
                              true,
                            );
                          }
                        },
                        containerBg: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        textColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        icon: CupertinoIcons.arrow_down,
                        iconColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        textEntry: "Dépense",
                      ),
                    ),
                  ],
                ),
              ],
            )
          else if (currentMission.isClosed == true &&
              calculatedPercent == 1.0 &&
              currentMission.isAmountGoal == true)
            Column(
              children: [
                const SizedBox(height: 10),
                Divider(
                  thickness: 0.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  "🎊🥳🎉\nVous avez atteint votre objectif",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            )
          else if (currentMission.isClosed == true &&
              calculatedPercent < 1.0 &&
              currentMission.isAmountGoal == true)
            Column(
              children: [
                const SizedBox(height: 10),
                Divider(
                  thickness: 0.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  "😔😩😖\nVous n'avez pas atteint votre objectif",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            )
          else if (currentMission.isClosed == true &&
              currentMission.isAmountGoal == false)
            Column(
              children: [
                const SizedBox(height: 10),
                Divider(
                  thickness: 0.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  "❌🚀❌\nVous n'aviez pas de montant objectif",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
