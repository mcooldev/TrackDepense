import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/widgets/text_form_field_widget.dart';

import '../helpers/pocketBaseHelper/trx_db.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'add_entry_widget.dart';
import 'mission_category_widget.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.mission, this.depenseToEdit});

  final Mission mission;
  final Depense? depenseToEdit;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<TransactionProvider>(context, listen: false);
      if (widget.depenseToEdit != null) {
        prov.montantDepenseController.text = widget.depenseToEdit!.montant
            .toStringAsFixed(0);
        prov.descriptionDepenseController.text =
            widget.depenseToEdit!.description;
        prov.setSelectedIndex(
          missionTypeName.values.toList().indexOf(
            widget.depenseToEdit!.categorie,
          ),
        );
        prov.imageJustificatif = null;
      } else {
        prov.clearControllers();
      }
    });
  }

  final trxDb = TrxDb.instance;

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TransactionProvider>(
        builder: (_, prov, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
            child: Column(
              children: [
                /// Titre
                Text(
                  "Ajout de nouvelle dépense",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                // catégorie de la depense
                SizedBox(
                  height: 180,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 8,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (ctx, index) {
                      bool isSelected = index == prov.selectedIndex;
                      return MissionCategoryWidget(
                        missionTypeIcon: missionTypeIcon.values.elementAt(
                          index,
                        ),
                        missionTypeName: missionTypeName.values.elementAt(
                          index,
                        ),
                        isSelected: isSelected,
                        onTapMissionType: () {
                          prov.setSelectedIndex(index);
                        },
                        isEntree: false,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Montant de la depense
                TextFormFieldWidget(
                  controller: prov.montantDepenseController,
                  hintText: "Montant de la dépense",
                  iconData: CupertinoIcons.money_dollar,
                  isLabel: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                  label: "Montant",
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veuillez entrer un montant";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Description de la depense
                TextFormFieldWidget(
                  controller: prov.descriptionDepenseController,
                  hintText: "Décrivez la dépense",
                  iconData: CupertinoIcons.text_insert,
                  isLabel: true,
                  keyboardType: TextInputType.text,
                  label: "Description",
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Décrivez la dépense";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Justificatif de la dépense
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Image justificatif de la dépense",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Image container
                    Container(
                      height: 100,
                      width: MediaQuery.sizeOf(context).width,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            (widget.depenseToEdit?.justificatif == null ||
                                widget.depenseToEdit!.justificatif!.isEmpty)
                            ? Border.all(
                                width: 1,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.shade200,
                              )
                            : null,
                      ),
                      child:
                          (prov.imageJustificatif == null &&
                              (widget.depenseToEdit?.justificatif == null ||
                                  widget.depenseToEdit!.justificatif!.isEmpty))
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.photo_fill_on_rectangle_fill,
                                  size: 40,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Aucune image ajoutée",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            )
                          : prov.imageJustificatif != null
                          ? Image.file(
                              prov.imageJustificatif!,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              "${trxDb.pb.baseURL}/api/files/depenses/${widget.depenseToEdit?.id ?? ''}/${widget.depenseToEdit?.justificatif ?? ''}",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Bouton
                    MaterialButton(
                      onPressed: () async {
                        prov.showBottomSheetJustificatif(
                          context,
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 50.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Choisissez la source',
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  children: [
                                    // Pick image from gallery
                                    Expanded(
                                      child: AddEntryWidget(
                                        onTap: () async {
                                          await prov
                                              .pickImageJustificatifFromGallery()
                                              .then((_) {
                                                if (!context.mounted) return;
                                                Navigator.of(context).pop();
                                              });
                                        },
                                        icon: CupertinoIcons.photo_on_rectangle,
                                        iconColor: Colors.black,
                                        textColor: Colors.black,
                                        containerBg:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.white,
                                        borderColor: Colors.grey.shade200,
                                        textEntry: 'Gallery',
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Pick image from camera
                                    Expanded(
                                      child: AddEntryWidget(
                                        onTap: () async {
                                          await prov
                                              .pickImageJustificatifFromCamera()
                                              .then((_) {
                                                if (!context.mounted) return;
                                                Navigator.of(context).pop();
                                              });
                                        },
                                        icon:
                                            CupertinoIcons.camera_on_rectangle,
                                        iconColor: Colors.black,
                                        textColor: Colors.black,
                                        containerBg:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.white,
                                        borderColor: Colors.grey.shade200,
                                        textEntry: 'Caméra',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          false,
                        );
                      },
                      splashColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      elevation: 0,
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90),
                        side: BorderSide(width: 1, color: Colors.grey.shade200),
                      ),
                      child: Text(
                        widget.depenseToEdit != null
                            ? "Modifier l'image"
                            : "Ajouter une image",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /// Ajouter la dépense Bouton
                MaterialButton(
                  onPressed: () async {
                    if (prov.isLoading) return;
                    //
                    if (prov.selectedIndex == -1) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "⚠️️ • Veuillez sélectionner une catégorie",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: const StadiumBorder(),
                        ),
                      );
                      return;
                    }
                    //
                    final amountBudget = double.parse(
                      widget.mission.capitale.toStringAsFixed(0),
                    );
                    final amountExpense = double.parse(
                      prov.montantDepenseController.text.trim(),
                    );
                    if (amountExpense > amountBudget) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "😔️• Budget insuffisant",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: const StadiumBorder(),
                        ),
                      );
                      return;
                    }  
                    //
                    final newDepense = Depense(
                      montant: double.parse(
                        prov.montantDepenseController.text.trim(),
                      ),
                      categorie: missionTypeName.values.elementAt(
                        prov.selectedIndex,
                      ),
                      description: prov.descriptionDepenseController.text
                          .trim(),
                      missionId: widget.mission.id ?? '',
                    );
                    //
                    if (widget.depenseToEdit != null) {
                      await prov.updateDepenseOnPb(
                        missionId: widget.mission.id!,
                        depenseId: widget.depenseToEdit!.id!,
                        data: newDepense.toMap(),
                      );
                    } else {
                      //
                      if (widget.mission.id == null) return;
                      prov.addDepenseToPb(
                        depense: newDepense,
                        missionId: widget.mission.id!,
                      );
                    }
                    prov.clearControllers();
                    //
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    //
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.depenseToEdit != null
                              ? "🎉✅🎊 • Dépense modifiée avec succès"
                              : "🎉✅🎊 • Dépense ajoutée avec succès",
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: const StadiumBorder(),
                      ),
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
                  child: prov.isLoading
                      ? const CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white,
                        )
                      : Text(
                          widget.depenseToEdit == null
                              ? "Ajouter la dépense"
                              : "Modifier la dépense",
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(fontSize: 17, color: Colors.white),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
