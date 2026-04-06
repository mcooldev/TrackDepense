// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
//
// import '../../providers/auth_provider.dart';
// import '../../widgets/text_form_field_widget.dart';
//
// class Signup extends StatefulWidget {
//   const Signup({super.key});
//
//   @override
//   State<Signup> createState() => _SignupState();
// }
//
// class _SignupState extends State<Signup> {
//   ///
//   final pb = PocketBaseDb.instance;
//
//   ///
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => SignupProvider(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Row(
//             children: [
//               CircleAvatar(
//                 radius: 14,
//                 backgroundColor: Theme.of(context).colorScheme.surface,
//                 backgroundImage: const AssetImage(
//                   "assets/td_launcher_icon.png",
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 "Track Dépenses",
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ],
//           ),
//         ),
//         body: Consumer<SignupProvider>(
//           builder: (_, prov, _) {
//             return SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(16.0, 24, 16.0, 50),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   //
//                   Text(
//                     "Créons votre compte !",
//                     softWrap: true,
//                     style: Theme.of(
//                       context,
//                     ).textTheme.headlineLarge!.copyWith(fontSize: 28),
//                   ),
//                   const SizedBox(height: 12),
//
//                   //
//                   Text(
//                     "Choisissez votre methode d'inscription.",
//                     softWrap: true,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                   const SizedBox(height: 32),
//
//                   //
//                   Form(
//                     key: prov.signupFormKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         /// Full name
//                         Text(
//                           "Nom complet",
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormFieldWidget(
//                           controller: prov.nameController,
//                           hintText: "Ex: Mouhamadou Coulibaly",
//                           iconData: CupertinoIcons.person,
//                           isPassword: false,
//                           validator: (value) {
//                             if (value == null ||
//                                 value.isEmpty ||
//                                 value.length < 3) {
//                               return "Veuillez entrer votre nom complet";
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//
//                         /// Email
//                         Text(
//                           "Adresse mail",
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormFieldWidget(
//                           controller: prov.emailController,
//                           hintText: "exemple@exemple.com",
//                           iconData: CupertinoIcons.at,
//                           isPassword: false,
//                           validator: (value) {
//                             if (value == null ||
//                                 value.isEmpty ||
//                                 !value.contains("@")) {
//                               return "Veuillez entrer votre adresse mail";
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//
//                         /// Password
//                         Text(
//                           "Mot de passe",
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormFieldWidget(
//                           controller: prov.passwordController,
//                           hintText: "••••••••",
//                           iconData: CupertinoIcons.number,
//                           isPassword: true,
//                           validator: (value) {
//                             if (value == null ||
//                                 value.isEmpty ||
//                                 value.length < 8) {
//                               return "8 caractères minimum";
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//
//                         /// Confirm password
//                         Text(
//                           "Confirmer mot de passe",
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormFieldWidget(
//                           controller: prov.confirmPasswordController,
//                           hintText: "••••••••",
//                           iconData: CupertinoIcons.number,
//                           isPassword: true,
//                           validator: (value) {
//                             if (value == null ||
//                                 value.isEmpty ||
//                                 value.length < 8) {
//                               return "8 caractères minimum";
//                             } else if (value != prov.passwordController.text) {
//                               return "Les mots de passe ne correspondent pas";
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),
//
//                         /// Sign up button
//                         MaterialButton(
//                           onPressed: () async {
//                             await prov.signup(context);
//                           },
//                           splashColor: Theme.of(
//                             context,
//                           ).colorScheme.primary.withValues(alpha: 0.15),
//                           color: Theme.of(context).colorScheme.primary,
//                           elevation: 0,
//                           height: 50,
//                           minWidth: double.infinity,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(90),
//                           ),
//                           child: prov.isLoading
//                               ? const CircularProgressIndicator.adaptive(
//                                   backgroundColor: Colors.white,
//                                 )
//                               : Text(
//                                   "S'inscrire maintenant",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium!
//                                       .copyWith(
//                                         fontSize: 17,
//                                         color: Colors.white,
//                                       ),
//                                 ),
//                         ),
//                         const SizedBox(height: 32),
//
//                         /// Already have an account
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Déjà inscrit ?",
//                               style: Theme.of(context).textTheme.titleMedium!
//                                   .copyWith(
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .onSurface
//                                         .withValues(alpha: 0.7),
//                                   ),
//                             ),
//                             const SizedBox(width: 8),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.pushReplacementNamed(
//                                   context,
//                                   "/login",
//                                 );
//                               },
//                               child: Text(
//                                 "Se connecter maintenant.",
//                                 style: Theme.of(context).textTheme.titleMedium!
//                                     .copyWith(
//                                       color:
//                                           Theme.of(context).brightness ==
//                                               Brightness.dark
//                                           ? Theme.of(
//                                               context,
//                                             ).colorScheme.onSurface
//                                           : Theme.of(
//                                               context,
//                                             ).colorScheme.primary,
//                                     ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
