import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/models/transaction_model.dart';
import 'package:track_depenses/web_view/web_providers/home_web_provider.dart';

import '../../helpers/pocketBaseHelper/trx_db.dart';
import '../../providers/share_files_providers.dart';
import '../../providers/transaction_provider.dart';

class MissionDetailWeb extends StatefulWidget {
  const MissionDetailWeb({super.key, required this.mission});

  final Mission mission;

  @override
  State<MissionDetailWeb> createState() => _MissionDetailWebState();
}

class _MissionDetailWebState extends State<MissionDetailWeb> {
  ///
  final searchController = TextEditingController();
  final formattedDate = DateFormat("dd/MM/yyyy");
  final trxDb = TrxDb.instance;
  UnsubscribeFunc? subscribe;
  Timer? _searchDebounce;
  final formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'F',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTrx(
        missionId: widget.mission.id!,
        queryString: searchController.text.trim(),
      );
    });
  }

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce!.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      context.read<TransactionProvider>().fetchTrx(
        missionId: widget.mission.id!,
        queryString: value,
      );
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeWebProvider, TransactionProvider>(
      builder: (_, prov, trxProv, _) {
        ///
        final currentMission = widget.mission;
        //
        final filteredTxnList = trxProv.allTrx;
        //
        final opEntrees = filteredTxnList.whereType<Entree>().toList();
        final opDepenses = filteredTxnList.whereType<Depense>().toList();
        //
        double dynamicCapital =
            opEntrees.fold(0.0, (sum, e) => sum + e.montant) -
            opDepenses.fold(0.0, (sum, d) => sum + d.montant);
        if (dynamicCapital < 0) dynamicCapital = 0;
        //
        if (dynamicCapital < 0) {
          dynamicCapital = 0;
        }
        //
        final calculatedPercent = currentMission.amountGoal == null
            ? 0.0
            : trxProv.calculatePercent(
                dynamicCapital,
                currentMission.amountGoal!,
              );
        final textPercent = "${(calculatedPercent * 100).toStringAsFixed(0)}%";

        final filesProv = Provider.of<ShareFilesProvider>(context);

        ///
        return Scaffold(
          appBar: AppBar(
            title: const Text("Détails de la mission"),
            centerTitle: false,
            leading: Padding(
              padding: const EdgeInsets.all(6.0),
              child: InkWell(
                onTap: () {
                  Future.microtask(() {
                    prov.selectedMission = null;
                    prov.selectedTrx = null;
                    prov.selectedIndex = prov.previousIndex;
                  });
                },
                borderRadius: BorderRadius.circular(100),
                child: const SizedBox(
                  width: 12,
                  height: 12,
                  child: Icon(CupertinoIcons.arrow_left),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200, width: 0.5),
                ),
              ),
            ),
          ),

          ///*BODY CONTENT HERE*/
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Column content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        currentMission.nom,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      _dateStatusGoal(currentMission, context),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Agent name
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
                                currentMission.user.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),

                          /// download pdf button
                          const SizedBox(width: 8),
                          if (currentMission.isClosed)
                            MaterialButton(
                              onPressed: () async {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!context.mounted) return;
                                  filesProv.downloadPdfWeb(
                                    context,
                                    currentMission,
                                    filteredTxnList,
                                  );
                                });
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              splashColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.15),
                              color: filesProv.isCreatingPdfWeb
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.6)
                                  : Theme.of(context).colorScheme.primary,
                              elevation: 0,
                              height: 50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(90),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: filesProv.isCreatingPdfWeb
                                    ? Row(
                                        key: const ValueKey("loading"),
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            filesProv.pdfStepLabel,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(color: Colors.white),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        key: const ValueKey("button"),
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedDownload02,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Télécharger le rapport • PDF",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      missionSummaryContainerWeb(
                        context,
                        currentMission,
                        filteredTxnList,
                        opEntrees,
                        opDepenses,
                        calculatedPercent,
                        textPercent,
                        currentMission.capitale,
                      ),
                      const SizedBox(height: 40),

                      /// Transactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // trx headline
                          Text(
                            "Opérations • ${filteredTxnList.length.toString().padLeft(2, '0')}",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          // Search bar for history
                          SizedBox(
                            width: 400,
                            child: SearchBar(
                              controller: searchController,
                              onChanged: _onSearchChanged,
                              onTap: () {},
                              elevation: const WidgetStatePropertyAll(0),
                              onTapOutside: (pointer) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              leading: Icon(
                                CupertinoIcons.search,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              trailing: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 7.0),
                                  child: IconButton(
                                    onPressed: () {
                                      searchController.clear();
                                      _onSearchChanged('');
                                    },
                                    icon: Icon(
                                      CupertinoIcons.multiply,
                                      color: Colors.grey.shade300,
                                    ),
                                    splashColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.15),
                                  ),
                                ),
                              ],
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
              ),

              /// Side trx content
              Container(
                height: double.infinity,
                width: 400,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: prov.selectedTrx == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: Text("Aucune opération sélectionnée")),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prov.selectedTrx is Entree
                                ? "Détails de l'entrée"
                                : "Détails de la dépense",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          // Description, date, montant, categorie
                          Container(
                            padding: const EdgeInsets.all(4),
                            width: MediaQuery.sizeOf(context).width,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
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
                                          color: prov.selectedTrx is Entree
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.15)
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            80,
                                          ),
                                        ),
                                        child: Icon(
                                          prov.selectedTrx is Entree
                                              ? CupertinoIcons.arrow_up_circle
                                              : CupertinoIcons
                                                    .arrow_down_circle,
                                          size: 32,
                                          color: prov.selectedTrx is Entree
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.secondary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              prov.selectedTrx is Entree
                                                  ? "Titre de l'entrée"
                                                  : "Titre de la dépense",
                                              softWrap: true,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge,
                                            ),
                                            Text(
                                              prov.selectedTrx.description,
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
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
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
                                            "Le ${DateFormat("dd/MM/yyyy").format(prov.selectedTrx.createdAt ?? DateTime.now())}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
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
                                            prov.selectedTrx is Entree
                                                ? "+ ${formatter.format(prov.selectedTrx?.montant ?? 0.0)}"
                                                : "- ${formatter.format(prov.selectedTrx?.montant ?? 0.0)}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      prov.selectedTrx is Entree
                                                      ? CupertinoColors
                                                            .systemGreen
                                                      : Colors.red,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
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
                                            prov.selectedTrx.categorie,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
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
                          const SizedBox(height: 16),

                          /// Image justificative
                          // Titre du justificatif
                          Text(
                            "Pièce justificative",
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          // Image justificative
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
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
                                  (prov.selectedTrx.justificatif == null ||
                                      prov.selectedTrx.justificatif!.isEmpty)
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          final fileName =
                                              prov.selectedTrx.justificatif;

                                          final imageUrl = trxDb.pb.files
                                              .getUrl(
                                                prov.selectedTrx.record,
                                                fileName!,
                                              )
                                              .toString();

                                          log("Path justificatif: $imageUrl");

                                          return InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  insetPadding:
                                                      const EdgeInsets.all(20),
                                                  child: Stack(
                                                    alignment:
                                                        Alignment.topRight,
                                                    children: [
                                                      // Image en grand
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        child: Image.network(
                                                          imageUrl,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      // Bouton fermer
                                                      Positioned(
                                                        right: 10,
                                                        top: 10,
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.black54,
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Image.network(
                                              imageUrl,
                                              loadingBuilder:
                                                  (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) => loadingProgress == null
                                                  ? child
                                                  : const Padding(
                                                      padding: EdgeInsets.all(
                                                        50.0,
                                                      ),
                                                      child:
                                                          CircularProgressIndicator.adaptive(),
                                                    ),
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.broken_image,
                                                  ),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///

  ///*EXTRACTED METHODS HERE*/

  ///

  Container missionSummaryContainerWeb(
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
      width: double.infinity,
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
                      fontSize: 26,
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  " • ",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge!.copyWith(color: Colors.grey),
                ),
              ),

              /// Last operation amount
              if (operations.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Text(
                    operations.first is Entree
                        ? "+ ${formatter.format(opEntrees.first.montant)}"
                        : "- ${formatter.format(opDepenses.first.montant)}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: operations.first is Entree
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Text(
                    "- 0F ajouté ni dépensé -",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

              /// Linear percent indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  " • ",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge!.copyWith(color: Colors.grey),
                ),
              ),
              // Linear percent indicator
              Expanded(
                child: LinearProgressIndicator(
                  value: calculatedPercent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    (currentMission.isClosed && calculatedPercent >= 1.0)
                        ? Colors.green
                        : (currentMission.isClosed && calculatedPercent < 1.0)
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(90),
                  minHeight: 32,
                ),
              ),
              const SizedBox(width: 10),
              Text(currentMission.isAmountGoal ? textPercent : "-N/A-"),
            ],
          ),
        ],
      ),
    );
  }

  Container trxListContainer(
    BuildContext context,
    List<dynamic> filteredTxnList,
    Mission currentMission,
  ) {
    //
    final prov = Provider.of<HomeWebProvider>(context, listen: false);
    //
    return Container(
      isAntiAlias: true,
      clipBehavior: Clip.antiAlias,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Colors.transparent,
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
          height: 0,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
        itemBuilder: (context, i) {
          //
          final op = filteredTxnList[i];
          //
          return ListTile(
            onTap: () {
              Future.microtask(() {
                prov.selectedTrx = op;
              });
            },
            selected: prov.selectedTrx == op,
            tileColor: Colors.transparent,
            selectedTileColor: op is Entree
                ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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

  Row _dateStatusGoal(Mission currentMission, BuildContext context) {
    return Row(
      children: [
        Text(
          "Du ${formattedDate.format(currentMission.dateDebut)} • Au ${formattedDate.format(currentMission.dateFin)}",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(" | ", style: Theme.of(context).textTheme.bodyLarge),
        ),
        // Mission state
        Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
          decoration: BoxDecoration(
            color: currentMission.isClosed == true ? Colors.red : Colors.green,
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
                currentMission.isClosed == true ? "Clôturée" : "En cours",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(" | ", style: Theme.of(context).textTheme.bodyLarge),
        ),
        // Mission amount goal
        if (currentMission.amountGoal != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
              decoration: BoxDecoration(
                color: !currentMission.isAmountGoal
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
                    color: !currentMission.isAmountGoal
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatter.format(currentMission.amountGoal ?? 0.0),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: !currentMission.isAmountGoal
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
