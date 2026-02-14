import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    ///
    final theme = Theme.of(context);

    // todo: create form key
    // todo: Set the controllers for the form

    ///
    return Consumer<UserProvider>(
      builder: (_, prov, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Besoin d'aide ?"),
            centerTitle: false,
            //
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey.shade200),
                  ),
                ),
              ),
            ),
          ),

          /// Body
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Headline
                Text(
                  "N’hésitez pas à nous joindre!",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // body text
                Text(
                  "Utilisez le formulaire ci-dessous pour nous envoyer vos questions ou signaler un problème. Nous sommes là pour vous aider !",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // support form
                Form(
                  key: prov.supportFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      /// object text field
                      TextFormField(
                        //
                        onTapOutside: (pointer) {
                          FocusManager.instance.primaryFocus!.unfocus();
                        },
                        //
                        controller: prov.objectController,
                        //
                        focusNode: FocusNode(),
                        //
                        textCapitalization: TextCapitalization.sentences,
                        //
                        validator: (val) {
                          if (val.toString().isEmpty) {
                            return "Veuillez décrire votre l'objet de votre demande";
                          }
                          return null;
                        },
                        //
                        keyboardType: TextInputType.text,
                        //
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(90),
                          ),
                          //
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(90),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                          ),
                          //
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          //
                          hintText: 'Objet de votre message',
                          hintStyle: theme.textTheme.bodyMedium!.copyWith(
                            color: Colors.grey.shade500,
                          ),

                          //
                          prefixIcon: Icon(
                            CupertinoIcons.pencil_ellipsis_rectangle,
                            size: 22,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// message content text field
                      SizedBox(
                        height: 200,
                        child: TextFormField(
                          //
                          onTapOutside: (pointer) {
                            FocusManager.instance.primaryFocus!.unfocus();
                          },
                          //
                          controller: prov.messageController,
                          //
                          focusNode: FocusNode(),
                          //
                          keyboardType: TextInputType.multiline,
                          //
                          validator: (val) {
                            if (val.toString().isEmpty) {
                              return "Veuillez décrire votre message";
                            }
                            return null;
                          },
                          //
                          expands: true,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          textAlign: TextAlign.start,
                          textCapitalization: TextCapitalization.sentences,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            //
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.grey.shade200,
                              ),
                            ),
                            //
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            //
                            hintText: 'Décrivez votre demande ici ...',
                            hintStyle: theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.grey.shade500,
                            ),
                            //
                            alignLabelWithHint: true,
                            prefixIcon: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 18),
                                  child: Icon(
                                    CupertinoIcons.doc_plaintext,
                                    size: 22,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      /// submit btn
                      MaterialButton(
                        onPressed: () async {
                          //
                          if (prov.objectController.text.isEmpty || prov.messageController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "🥱 •  Veuillez remplir tous les champs",
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                                shape: const StadiumBorder(),
                              ),
                            );
                          }
                          //
                          FocusManager.instance.primaryFocus!.unfocus();
                          //
                          final result = await prov.onSubmitForm();
                          if (result == true) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🥳 ✅ Votre application mail a été ouverte',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: theme.colorScheme.primary,
                                shape: const StadiumBorder(),
                              ),
                            );
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "❌ •  Impossible d'ouvrir l'application mail !",
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                                shape: const StadiumBorder(),
                              ),
                            );
                          }
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
                          "Soumettre ma demande",
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ],
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
