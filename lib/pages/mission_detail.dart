import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/pages/home.dart';
import 'package:track_depenses/widgets/expense_detail.dart';
import 'package:track_depenses/widgets/new_entree.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
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
      context: context,
      builder: (context) {
        return child;
      },
    );
  }

  // Delete mission dialog
  Future<void> _deleteMissionDialog(
    BuildContext context,
    Mission mission,
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
              "Êtes-vous sûr de vouloir supprimer cette mission ?",
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
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
      prov.removeMission(mission);
    }
  }

  // Get all transactions from mission
  List<dynamic> getAllTransaction(Mission mission, FilterType filterType) {
    final allTransactions = <dynamic>[];
    if (filterType == FilterType.entrees) {
      allTransactions.addAll(mission.entrees);
    } else if (filterType == FilterType.depenses) {
      allTransactions.addAll(mission.depenses);
    } else {
      allTransactions.addAll(mission.depenses);
      allTransactions.addAll(mission.entrees);
    }
    allTransactions.sort((a, b) => b.date.compareTo(a.date));
    return allTransactions;
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, prov, child) {
        ///
        final currentMission = prov.findMissionById(
          missionId: widget.mission.id,
        );
        if (currentMission == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final userProv = Provider.of<UserProvider>(context, listen: false);
            userProv.navigateWithFade(context, const Home());
          });
          return const SizedBox.shrink();
        }
        //
        final operations = getAllTransaction(
          currentMission,
          prov.currentFilter,
        );
        prov.filterTxnByName(operations, prov.searchController.text);
        final filteredTxn = prov.filteredOp;
        //
        final opEntrees = operations.whereType<Entree>().toList();
        final opDepenses = operations.whereType<Depense>().toList();

        ///
        return Scaffold(
          ///
          appBar: AppBar(
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white,
                ),
                child: TextButton(
                  onPressed: () async {
                    await _deleteMissionDialog(context, currentMission);
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
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
                    // Mission state
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: currentMission.isClosed == true
                            ? Theme.of(context).colorScheme.error
                            : Colors.green,
                        borderRadius: BorderRadius.circular(80),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.tray_full,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentMission.isClosed == true
                                ? "Clôturée"
                                : "En cours",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mission summary
                Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Solde actuel",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatter.format(currentMission.capitale),
                        style: Theme.of(context).textTheme.headlineLarge!
                            .copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      // Last operation
                      if (operations.isNotEmpty)
                        Text(
                          operations.first is Entree
                              ? "+ ${formatter.format(opEntrees.first.montant)}"
                              : "- ${formatter.format(opDepenses.first.montant)}",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
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
                                      // todo: add new entry
                                      _showBottomSheet(
                                        context,
                                        NewEntree(mission: currentMission),
                                        true,
                                      );
                                    },
                                    icon: CupertinoIcons.arrow_up,
                                    iconContainerColor: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.15),
                                    iconColor: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    textEntry: "Entrée",
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AddEntryWidget(
                                    onTap: () {
                                      // todo: add new expense
                                      _showBottomSheet(
                                        context,
                                        NewExpense(mission: currentMission),
                                        true,
                                      );
                                    },
                                    icon: CupertinoIcons.arrow_down,
                                    iconContainerColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.15),
                                    iconColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    textEntry: "Dépense",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                /// Mark mission as closed
                if (currentMission.isClosed == false)
                  Column(
                    children: [
                      MaterialButton(
                        onPressed: () {
                          // todo: mark mission as closed
                          prov.closeMission(currentMission);
                        },
                        splashColor: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.15),
                        color: Theme.of(context).colorScheme.onError,
                        elevation: 0,
                        height: 50,
                        minWidth: double.infinity,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(90),
                        ),
                        child: Text(
                          "Clôturer la mission",
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                fontSize: 17,
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
                else
                  Column(
                    children: [
                      MaterialButton(
                        onPressed: () {
                          // todo: share mission receipt
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
                              "Partager le rapport",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontSize: 17, color: Colors.white),
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
                    TextButton(
                      onPressed: () {
                        // todo: sort history by type or date or search
                        prov.toggleFilter();
                      },
                      child: Row(
                        children: [
                          Text(
                            prov.currentFilter == FilterType.mixed
                                ? "Toutes"
                                : prov.currentFilter == FilterType.entrees
                                ? "Entrées"
                                : "Dépenses",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            CupertinoIcons.arrow_up_arrow_down,
                            size: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Search bar for history
                SearchBar(
                  controller: prov.searchController,
                  onChanged: (query) {
                    prov.filterTxnByName(
                      operations,
                      prov.searchController.text,
                    );
                  },
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
                  backgroundColor: const WidgetStatePropertyAll(Colors.white),
                  hintText: "Chercher une entrée ou dépense",
                  hintStyle: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

                const SizedBox(height: 16),
                // History list
                operations.isEmpty
                    ? Container(
                        width: MediaQuery.sizeOf(context).width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white,
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
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(color: Colors.grey, fontSize: 18),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        clipBehavior: Clip.antiAlias,
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 0,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTxn.length,
                          itemBuilder: (context, index) {
                            //
                            final op = filteredTxn[index];
                            //
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
                                          NewEntree(
                                            mission: currentMission,
                                            entreeToEdit: op,
                                          ),
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
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                        : Theme.of(context).colorScheme.primary,
                                    foregroundColor: op is Entree
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSecondary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                    icon: CupertinoIcons
                                        .pencil_ellipsis_rectangle,
                                    label: 'Modifier',
                                  ),
                                  SlidableAction(
                                    onPressed: (context) {
                                      // todo: delete operation
                                      if (op is Entree) {
                                        prov.removeEntree(currentMission, op);
                                        //
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "🗑️ • Entrée supprimée avec succès",
                                            ),
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      } else if (op is Depense) {
                                        prov.removeDepense(currentMission, op);
                                        //
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "🗑️ • Dépense supprimée avec succès",
                                            ),
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
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
                                          depense: op,
                                          mission: currentMission,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                //
                                leading: op is Entree
                                    ? Icon(
                                        CupertinoIcons.arrow_up_circle_fill,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        size: 32,
                                      )
                                    : Icon(
                                        CupertinoIcons.arrow_down_circle_fill,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: 32,
                                      ),
                                title: Text(
                                  op.description,
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                subtitle: Text(
                                  formattedDate.format(op.date),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: op is Entree
                                    ? Text(
                                        formatter.format(
                                          double.parse(op.montant.toString()),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      )
                                    : Text(
                                        "-${formatter.format(double.parse(op.montant.toString()))}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
