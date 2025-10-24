import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_depenses/widgets/text_form_field_widget.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class NewEntree extends StatefulWidget {
  const NewEntree({super.key, required this.mission, this.entreeToEdit});

  final Mission mission;
  final Entree? entreeToEdit;

  @override
  State<NewEntree> createState() => _NewEntreeState();
}

class _NewEntreeState extends State<NewEntree> {
  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<TransactionProvider>(context, listen: false);
      if (widget.entreeToEdit != null) {
        prov.montanEntreetController.text = widget.entreeToEdit!.montant
            .toStringAsFixed(0);
        prov.descriptionEntreeController.text =
            widget.entreeToEdit!.description;
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
              // Titre
              Text(
                "Ajout de nouvel entrée",
                style: Theme.of(context).textTheme.titleLarge,
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
              // Bouton
              MaterialButton(
                onPressed: () {
                  //
                  final newEntree = Entree(
                    id: widget.entreeToEdit?.id,
                    montant: double.parse(
                      prov.montanEntreetController.text.trim(),
                    ),
                    description: prov.descriptionEntreeController.text.trim(),
                    date: DateTime.now(),
                  );
                  if (widget.entreeToEdit != null) {
                    prov.updateEntree(widget.mission, newEntree);
                  } else {
                    prov.add(newEntree);
                    //
                    prov.addEntreeToMission(widget.mission, newEntree);
                  }
                  //
                  prov.clearControllers();
                  //
                  Navigator.of(context).pop();
                  //
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.entreeToEdit != null
                            ? "🎉✅🎊 • Entrée modifiée avec succès"
                            : "🎉✅🎊 • Entrée ajouté avec succès",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
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
                  "Ajouter l'entrée",
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
