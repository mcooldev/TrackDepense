import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/widgets/add_entry_widget.dart';
import 'package:track_depenses/widgets/text_form_field_widget.dart';

import '../helpers/pocketBaseHelper/trx_db.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'mission_category_widget.dart';

class NewEntree extends StatefulWidget {
  const NewEntree({super.key, required this.mission, this.entreeToEdit});

  final Mission mission;
  final Entree? entreeToEdit;

  @override
  State<NewEntree> createState() => _NewEntreeState();
}

class _NewEntreeState extends State<NewEntree> {
  ///
  final trxDb = TrxDb.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<TransactionProvider>(context, listen: false);
      //
      if (widget.entreeToEdit != null) {
        prov.setSelectedIndex(
          missionTypeName.values.toList().indexOf(
            widget.entreeToEdit!.categorie,
          ),
        );
        prov.montanEntreetController.text = widget.entreeToEdit!.montant
            .toStringAsFixed(0);
        prov.descriptionEntreeController.text =
            widget.entreeToEdit!.description;
        prov.imageJustificatif = null;
      } else {
        prov.clearControllers();
      }
    });
  }

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
                // Titre
                Text(
                  "Ajout de nouvel entrée",
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Montant de l'entrée
                TextFormFieldWidget(
                  controller: prov.montanEntreetController,
                  hintText: "Montant de l'entrée",
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
                // Description de l'entrée
                TextFormFieldWidget(
                  controller: prov.descriptionEntreeController,
                  hintText: "Décrivez l'entrée",
                  iconData: CupertinoIcons.text_insert,
                  isLabel: true,
                  keyboardType: TextInputType.text,
                  label: "Description",
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Décrivez l'entrée";
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
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            (prov.imageJustificatif == null ||
                                prov.imageJustificatif!.path.isEmpty)
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
                              (widget.entreeToEdit?.justificatif == null ||
                                  widget.entreeToEdit!.justificatif!.isEmpty))
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
                              "${trxDb.pb.baseURL}/api/files/entrees/${widget.entreeToEdit?.id ?? ''}/${widget.entreeToEdit?.justificatif ?? ''}",
                              headers: const {
                                "ngrok-skip-browser-warning": "1",
                              },
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) => loadingProgress == null
                                  ? child
                                  : const CircularProgressIndicator.adaptive(),
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
                        widget.entreeToEdit != null
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
                // Bouton
                MaterialButton(
                  onPressed: () async {
                    if (prov.isLoading) return;
                    //
                    final newEntree = Entree(
                      id: widget.entreeToEdit?.id,
                      categorie: missionTypeName.values.elementAt(
                        prov.selectedIndex,
                      ),
                      montant: double.parse(
                        prov.montanEntreetController.text.trim(),
                      ),
                      description: prov.descriptionEntreeController.text.trim(),
                      missionId: widget.mission.id ?? '',
                    );
                    if (widget.entreeToEdit != null) {
                      await prov.updateEntreeOnPb(
                        missionId: widget.mission.id!,
                        entreeId: widget.entreeToEdit!.id!,
                        data: newEntree.toMap(),
                      );
                    } else {
                      //
                      if (widget.mission.id == null) return;
                      prov.addEntreeToPb(
                        entree: newEntree,
                        missionId: widget.mission.id!,
                      );
                    }
                    //
                    prov.clearControllers();
                    //
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    //
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.entreeToEdit != null
                              ? "🎉✅🎊 • Entrée modifiée avec succès"
                              : "🎉✅🎊 • Entrée ajouté avec succès",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
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
                          widget.entreeToEdit != null
                              ? "Modifier l'entrée"
                              : "Ajouter l'entrée",
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
