import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/widgets/text_form_field_widget.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class NewMission extends StatefulWidget {
  const NewMission({super.key, this.missionToEdit});

  final Mission? missionToEdit;

  @override
  State<NewMission> createState() => _NewMissionState();
}

class _NewMissionState extends State<NewMission> {
  ///

  @override
  void initState() {
    super.initState();
    //
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<TransactionProvider>(context, listen: false);
      if (widget.missionToEdit != null) {
        //
        prov.nomController.text = widget.missionToEdit!.nom;
        prov.capitaleController.text = widget.missionToEdit!.capitale
            .toStringAsFixed(0);
        prov.isAmountGoalSet = widget.missionToEdit!.isAmountGoal;
        prov.amountGoalController.text = widget.missionToEdit!.amountGoal
            .toString();
        prov.setHintValueDebut(dateFormat(widget.missionToEdit!.dateDebut));
        prov.setHintValueFin(dateFormat(widget.missionToEdit!.dateFin));
        prov.dateDebutController.text = dateFormat(
          widget.missionToEdit!.dateDebut,
        );
        prov.dateFinController.text = dateFormat(widget.missionToEdit!.dateFin);
      } else {
        prov.clearControllers();
      }
    });
  }

  String dateFormat(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  final pb = PocketBaseDb.instance.pb;

  ///
  @override
  Widget build(BuildContext context) {
    ///
    final userId = pb.authStore.record?.id;

    ///
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<TransactionProvider>(
        builder: (_, prov, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Titre
                Text(
                  widget.missionToEdit != null
                      ? "Modification de la mission"
                      : "Ajout de nouvelle mission",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                // Nom de la mission
                TextFormFieldWidget(
                  controller: prov.nomController,
                  hintText: "Nom de la mission",
                  iconData: CupertinoIcons.tray,
                  isPassword: false,
                  keyboardType: TextInputType.text,
                  isLabel: true,
                  label: "Nom de la mission",
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veuillez entrer un nom de mission";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Capitale de départ
                TextFormFieldWidget(
                  controller: prov.capitaleController,
                  hintText: "Ex: 100000",
                  isLabel: true,
                  label: "Capitale de départ",
                  iconData: CupertinoIcons.money_dollar,
                  isPassword: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Mettre 0 si le montant est nul";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Montant objectif
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: prov.isAmountGoalSet == false
                        ? Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: prov.isAmountGoalSet == false
                        ? Border.all(color: Colors.transparent)
                        : Border.all(
                            width: 0.5,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Définir un montant objectif",
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Switch(
                            value: prov.isAmountGoalSet,
                            inactiveThumbColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            inactiveTrackColor: Colors.white,
                            //
                            trackOutlineColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            //
                            activeThumbColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            activeTrackColor: Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                            onChanged: prov.setAmountGoalSet,
                          ),
                        ],
                      ),
                      if (prov.isAmountGoalSet)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            TextFormFieldWidget(
                              controller: prov.amountGoalController,
                              hintText: "Montant objectif",
                              iconData: CupertinoIcons.money_dollar,
                              isPassword: false,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Veuillez mettre un montant objectif";
                                } else {
                                  return null;
                                }
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: false,
                                    signed: false,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Date de début
                    Flexible(
                      child: TextFormFieldWidget(
                        controller: prov.dateDebutController,
                        hintText: prov.hintValueDebut,
                        iconData: CupertinoIcons.calendar_badge_plus,
                        isPassword: false,
                        validator: (val) {
                          if (prov.dateDebutController.text.isEmpty) {
                            return "Sélectionner une date de début";
                          } else {
                            return null;
                          }
                        },
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: prov.dateDebut ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ).then((val) {
                            if (val != null) {
                              final formattedDate = dateFormat(val);
                              prov.dateDebutController.text = formattedDate;
                              prov.setHintValueDebut(formattedDate);
                              prov.dateDebut = val;
                            }
                            FocusManager.instance.primaryFocus?.unfocus();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Date de fin
                    Flexible(
                      child: TextFormFieldWidget(
                        controller: prov.dateFinController,
                        hintText: prov.hintValueFin,
                        iconData: CupertinoIcons.calendar_badge_minus,
                        isPassword: false,
                        validator: (val) {
                          if (prov.dateFinController.text.isEmpty) {
                            return "Sélectionner une date de fin";
                          } else {
                            return null;
                          }
                        },
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: prov.dateFin ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ).then((val) {
                            if (val != null) {
                              final formattedDate = dateFormat(val);
                              prov.dateFinController.text = formattedDate;
                              prov.setHintValueFin(formattedDate);
                              prov.dateFin = val;
                            }
                            FocusManager.instance.primaryFocus?.unfocus();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /// Add mission button
                MaterialButton(
                  onPressed: () async {
                    if (prov.isLoading) return;
                    //
                    if (prov.nomController.text.isEmpty) {
                      //
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "⚠️ • Veuillez donner un nom à la mission",
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: const StadiumBorder(),
                        ),
                      );
                      return;
                    } else if (prov.capitaleController.text.isEmpty) {
                      //
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Mettre 0 si le montant est nul"),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: const StadiumBorder(),
                        ),
                      );
                      return;
                    } else if (prov.dateDebutController.text.isEmpty ||
                        prov.dateFinController.text.isEmpty) {
                      //
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Veuillez sélectionner les dates",
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: const StadiumBorder(),
                        ),
                      );
                      return;
                    } else if (prov.isAmountGoalSet &&
                        prov.amountGoalController.text.isEmpty) {
                      //
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Veuillez mettre un montant objectif",
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: const StadiumBorder(),
                        ),
                      );
                      return;
                    } else if (prov.dateFin != null &&
                        prov.dateFin!.isBefore(prov.dateDebut!)) {
                      //
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "La date de début doit être avant la date de fin",
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: const StadiumBorder(),
                        ),
                      );
                      return;
                    }
                    //
                    if (userId == null) return;
                    final newMission = Mission(
                      id: widget.missionToEdit?.id,
                      nom: prov.nomController.text.trim(),
                      user: userId,
                      capitaleInitial: double.parse(
                        prov.capitaleController.text.trim(),
                      ),
                      capitale: double.parse(
                        prov.capitaleController.text.trim(),
                      ),
                      isAmountGoal: prov.isAmountGoalSet,
                      amountGoal: prov.isAmountGoalSet
                          ? double.parse(prov.amountGoalController.text.trim())
                          : null,
                      dateDebut: prov.dateDebut!,
                      dateFin: prov.dateFin!,
                    );
                    //
                    if (widget.missionToEdit != null) {
                      await prov.updateMissionToPb(mission: newMission);
                    } else {
                      await prov.addMissionToPb(newMission);
                    }
                    //
                    prov.clearControllers();
                    //
                    if (!context.mounted) return;
                    Navigator.of(context).pop(newMission);
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
                          widget.missionToEdit != null
                              ? "Enregistrer les modifications"
                              : "Ajouter la mission",
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
