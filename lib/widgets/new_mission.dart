import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/widgets/text_form_field_widget.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class NewMission extends StatefulWidget {
  const NewMission({super.key});

  @override
  State<NewMission> createState() => _NewMissionState();
}

class _NewMissionState extends State<NewMission> {
  ///
  String dateFormat(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  final db = '';
  final userId = '';

  // todo: set database and user id

  ///
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (_, prov, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Titre
              Text(
                "Ajout de nouvelle mission",
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
                hintText: "Ex: 100.000",
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
                                color: Theme.of(context).colorScheme.onSecondary,
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
                            keyboardType: const TextInputType.numberWithOptions(
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
                        if (val == null || val.isEmpty) {
                          return "Sélectionner une date de début";
                        } else {
                          return null;
                        }
                      },
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
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
                        if (val == null || val.isEmpty) {
                          return "Sélectionner une date de fin";
                        } else {
                          return null;
                        }
                      },
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
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
                  //
                  if (prov.nomController.text.isEmpty) {
                    Navigator.of(context).pop();
                    //
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "Veuillez entrer un nom de mission",
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  } else if (prov.capitaleController.text.isEmpty) {
                    Navigator.of(context).pop();
                    //
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Mettre 0 si le montant est nul"),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  } else if (prov.dateDebutController.text.isEmpty ||
                      prov.dateFinController.text.isEmpty) {
                    Navigator.of(context).pop();
                    //
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Veuillez sélectionner les dates"),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  } else if (prov.isAmountGoalSet &&
                      prov.amountGoalController.text.isEmpty) {
                    Navigator.of(context).pop();
                    //
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "Veuillez mettre un montant objectif",
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  } else if (prov.dateFin.isBefore(prov.dateDebut)) {
                    Navigator.of(context).pop();
                    //
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "La date de début doit être avant la date de fin",
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  //
                  final newMission = Mission(
                    nom: prov.nomController.text.trim(),
                    capitaleInitial: double.parse(
                      prov.capitaleController.text.trim(),
                    ),
                    createdAt: DateTime.now(),
                    capitale: double.parse(prov.capitaleController.text.trim()),
                    entrees: [],
                    depenses: [],
                    isAmountGoal: prov.isAmountGoalSet,
                    amountGoal: prov.isAmountGoalSet
                        ? double.parse(prov.amountGoalController.text.trim())
                        : 0.0,
                    dateDebut: prov.dateDebut,
                    dateFin: prov.dateFin,
                  );
                  //
                  prov.add(newMission);
                  // todo: add mission to database method
                  //
                  prov.clearControllers();
                  //
                  if(!context.mounted) return;
                  Navigator.of(context).pop();
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
                  "Ajouter la mission",
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
