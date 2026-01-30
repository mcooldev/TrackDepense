import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as px;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:track_depenses/models/transaction_model.dart';

class ShareFilesProvider with ChangeNotifier {
  /// Take screenshot of the current screen and share it as an image file.

  ScreenshotController screenshotController = ScreenshotController();
  bool _isCapturing = false;

  bool get isCapturing => _isCapturing;

  void _scaffoldMessenger(BuildContext context, String message, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error == true
            ? Colors.red
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
      ),
    );
  }

  Future<void> shareAsImage(BuildContext context) async {
    _isCapturing = true;
    notifyListeners();
    //
    try {
      //
      final image = await screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 4.0,
      );
      //
      if (image != null) {
        //
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = "${directory.path}/screenshot_$timestamp.png";
        //
        await File(path).writeAsBytes(image);
        //
        await SharePlus.instance.share(
          ShareParams(files: [XFile(path)], text: "Reçu de transaction"),
        );
        //
        if (!context.mounted) return;
        _scaffoldMessenger(context, "🎊✅🎉 Fichier partagé avec succès", false);
      }
    } catch (e) {
      if (!context.mounted) return;
      _scaffoldMessenger(context, "⚠️ Erreur lors du partage du reçu", true);
    } finally {
      _isCapturing = false;
      notifyListeners();
    }
  }

  /// Generate pdf file, create and share
  final currencyFormater = NumberFormat.currency(
    locale: "fr_FR",
    symbol: "FCFA",
    decimalDigits: 0,
  );

  Future<Uint8List> loadAsset(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> generatePdf(
    BuildContext context,
    Mission mission,
    List<dynamic> transactions,
  ) async {
    final pdf = pw.Document(title: "Rapport de la mission : ${mission.nom}");

    ///
    final logoBytes = await loadAsset("assets/td_launcher_icon.png");
    //
    final fontRegularByte = await loadAsset("assets/fonts/Manrope-Regular.ttf");
    final fontBoldByte = await loadAsset("assets/fonts/Manrope-Bold.ttf");
    //
    late pw.TtfFont fontRegular;
    late pw.TtfFont fontBold;

    if (fontRegularByte.isNotEmpty) {
      fontRegular = pw.TtfFont(fontRegularByte.buffer.asByteData());
    } else {
      log("Font regular not found");
    }

    if (fontBoldByte.isNotEmpty) {
      fontBold = pw.TtfFont(fontBoldByte.buffer.asByteData());
    } else {
      log("Font bold not found");
    }

    final pw.ThemeData theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    );

    ///
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (pw.Context context) {
          // Calculate totals
          final totalEntrees = transactions.whereType<Entree>().fold<double>(
            0,
            (sum, item) => sum + item.montant,
          );
          final totalDepenses = transactions.whereType<Depense>().fold<double>(
            0,
            (sum, item) => sum + item.montant,
          );

          ///
          return pw.Column(
            children: [
              // logo image and mission title
              pw.Row(
                children: [
                  pw.Container(
                    width: 50,
                    height: 50,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(100),
                    ),
                    child: pw.ClipOval(
                      child: pw.Image(
                        pw.MemoryImage(logoBytes),
                        fit: pw.BoxFit.scaleDown,
                        alignment: pw.Alignment.topLeft,
                        height: 50,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Text(
                    mission.nom,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              // Total Entrées / Dépenses / Capital initial et restant / Montant objectif
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    // Capital initial
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text("Capital initial")),
                        pw.Text(
                          currencyFormater.format(mission.capitaleInitial),
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    // Capital restant
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text("Capital restant")),
                        pw.Text(
                          currencyFormater.format(mission.capitale),
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    // Montant objectif (si oui mettre le montant si non -N/A-)
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text("Montant objectif")),
                        if (mission.isAmountGoal)
                          pw.Text(
                            currencyFormater.format(mission.amountGoal),
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          )
                        else
                          pw.Text("-N/A-"),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    // Total Entrées
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text("Total Entrées")),
                        pw.Text(
                          currencyFormater.format(totalEntrees),
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    // Total Dépenses
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text("Total Dépenses")),
                        pw.Text(
                          currencyFormater.format(totalDepenses),
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Divider
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 5),
              // table header row
              pw.Row(
                children: [
                  // Intitulé
                  pw.Expanded(child: pw.Text("Intitulé")),
                  // Type
                  pw.Expanded(child: pw.Text("Type")),
                  // Date
                  pw.Expanded(child: pw.Text("Date")),
                  // Montant
                  pw.Expanded(child: pw.Text("Montant")),
                  //
                ],
              ),
              // Divider
              pw.SizedBox(height: 5),
              pw.Divider(),
              pw.SizedBox(height: 10),
              // list of transactions
              pw.ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (pw.Context context, int index) {
                  ///
                  final transaction = transactions[index];
                  //
                  final formatDate = DateFormat("dd/MM/yyyy");
                  final dateFormated = formatDate.format(transaction.date);
                  //
                  final montant = currencyFormater.format(transaction.montant);

                  ///
                  return pw.Column(
                    children: [
                      // Transaction row
                      pw.Row(
                        children: [
                          // Nom de la transaction
                          pw.Expanded(child: pw.Text(transaction.description)),
                          // Type de la transaction
                          pw.Expanded(
                            child: pw.Text(
                              transaction is Entree ? "Entrée" : "Dépense",
                            ),
                          ),
                          // Date de la transaction
                          pw.Expanded(child: pw.Text(dateFormated)),
                          // Montant de la transaction
                          pw.Expanded(
                            child: pw.Text(
                              montant,
                              style: pw.TextStyle(
                                fontSize: 15,
                                fontWeight: pw.FontWeight.bold,
                                color: transaction is Entree
                                    ? PdfColors.green
                                    : PdfColors.red,
                              ),
                            ),
                          ),
                          //
                        ],
                      ),
                      // Divider
                      if (index != transactions.length - 1)
                        pw.Column(
                          children: [
                            pw.SizedBox(height: 5),
                            pw.Divider(color: PdfColors.grey300),
                            pw.SizedBox(height: 5),
                          ],
                        ),
                    ],
                  );
                },
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
            ],
          );
        },
      ),
    );
    //
    return pdf.save();
  }

  Future<void> createAndSharePdf(
    BuildContext context,
    Mission mission,
    List<dynamic> transactions,
  ) async {
    _isCapturing = true;
    notifyListeners();
    //
    try {
      //
      final pdfBytes = await generatePdf(context, mission, transactions);
      //
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = "${directory.path}/pdf_$timestamp.pdf";
      //
      await File(path).writeAsBytes(pdfBytes);
      //
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: "Rapport de mission : ${mission.nom}",
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      _scaffoldMessenger(context, "⚠️ Erreur lors du partage du PDF", true);
    } finally {
      _isCapturing = false;
      notifyListeners();
    }
  }

  /// Preview pdf file

  Future<void> previewPdf(
    BuildContext context,
    Mission mission,
    List<dynamic> transactions,
  ) async {
    final pdfBytes = await generatePdf(context, mission, transactions);
    //
    final pdfPinchController = px.PdfControllerPinch(
      document: px.PdfDocument.openData(pdfBytes),
    );
    //
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: ShapeDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xff11181C)
              : Colors.white,
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
        ),
        child: Column(
          children: [
            // Pdf header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: ShapeDecoration(
                color: Colors.red.shade700,
                shape: const ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Prévisualisation PDF',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.multiply,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Pdf viewer
            Expanded(
              child: px.PdfViewPinch(
                controller: pdfPinchController,
                scrollDirection: Axis.vertical,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Disposer
  @override
  void dispose() {
    super.dispose();
  }
}
