import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/widgets/text_form_field_widget.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
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
        prov.imageJustificatif = File(widget.depenseToEdit!.justificatif!);
      }
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (_, prov, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
          child: Column(
            children: [

              /// Titre

              Text(
                "Ajout de nouvelle dépense",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              // catégorie de la depense
              SizedBox(
                height: 180,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (ctx, index) {
                    bool isSelected = index == prov.selectedIndex;
                    return MissionCategoryWidget(
                      missionTypeIcon: missionTypeIcon.values.elementAt(index),
                      missionTypeName: missionTypeName.values.elementAt(index),
                      isSelected: isSelected,
                      onTapMissionType: () {
                        prov.setSelectedIndex(index);
                      },
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
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          prov.imageJustificatif == null ||
                              prov.imageJustificatif!.path.isEmpty ||
                              prov.imageJustificatif!.path == ""
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
                        prov.imageJustificatif == null ||
                            prov.imageJustificatif!.path.isEmpty ||
                            prov.imageJustificatif!.path == ""
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
                        : Image.file(
                            prov.imageJustificatif!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Bouton
                  MaterialButton(
                    onPressed: () {
                      prov.pickImageJustificatif();
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
                      "Ajouter une image",
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
              // Bouton
              MaterialButton(
                onPressed: () {
                  //

                  //
                  final newDepense = Depense(
                    id: widget.depenseToEdit?.id,
                    montant: double.parse(
                      prov.montantDepenseController.text.trim(),
                    ),
                    categorie: missionTypeName.values.elementAt(
                      prov.selectedIndex,
                    ),
                    description: prov.descriptionDepenseController.text.trim(),
                    date: DateTime.now(),
                    justificatif: prov.imageJustificatif?.path ?? "",
                  );
                  //
                  if (widget.depenseToEdit != null) {
                    prov.updateDepense(widget.mission, newDepense);
                  } else {
                    prov.add(newDepense);
                    //
                    prov.addDepenseToMission(widget.mission, newDepense);
                  }
                  prov.clearControllers();
                  //
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90),
                      ),
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
                child: Text(
                  widget.depenseToEdit == null
                      ? "Ajouter la dépense"
                      : "Modifier la dépense",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 17,
                    color: Colors.white,
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
