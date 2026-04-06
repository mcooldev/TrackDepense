import 'dart:developer';
import 'dart:io' show File;
import 'dart:js_interop';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as px;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:track_depenses/helpers/pocketBaseHelper/pocketbase_db.dart';
import 'package:track_depenses/models/transaction_model.dart';
import 'package:web/web.dart' as web;

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
        shape: const StadiumBorder(),
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
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final XFile xfile;
        if (kIsWeb) {
          xfile = XFile.fromData(
            image,
            mimeType: 'image/png',
            name: 'screenshot_$timestamp.png',
          );
        } else {
          final directory = await getTemporaryDirectory();
          final path = "${directory.path}/screenshot_$timestamp.png";
          await File(path).writeAsBytes(image);
          xfile = XFile(path);
        }
        //
        await SharePlus.instance.share(
          ShareParams(files: [xfile], text: "Reçu de transaction"),
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
  final formattedDate = DateFormat("dd/MM/yyyy");

  Future<Uint8List> loadAsset(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> fetchImageBytes(String uri) async {
    try {
      final response = await http.get(
        Uri.parse(uri),
        headers: {
          "Authorization": "Bearer ${PocketBaseDb.instance.pb.authStore.token}",
        },
      );
      if (response.statusCode == 200) {
        log(
          "✅ Image récupérée avec succès: ${response.bodyBytes.length} bytes",
        );
        return response.bodyBytes;
      } else {
        log("❌ Erreur récupération image: ${response.statusCode}");
        return Uint8List(0);
      }
    } catch (e) {
      log("❌ Exception lors de la récupération de l'image: $e");
      return Uint8List(0);
    }
  }

  Uint8List? _cachedPdf;

  Future<Uint8List> getCachedPdf(
    BuildContext context,
    Mission mission,
    List<dynamic> transactions,
  ) async {
    if (_cachedPdf != null) return _cachedPdf!;
    //
    _cachedPdf = await generatePdf(context, mission, transactions);
    return _cachedPdf!;
  }

  Future<Uint8List> compressImageBytes(Uint8List imageBytes) async {
    final result = await FlutterImageCompress.compressWithList(
      imageBytes,
      minHeight: 800,
      minWidth: 800,
      quality: 65,
      format: CompressFormat.jpeg,
    );
    return Uint8List.fromList(result);
  }

  Future<Uint8List> generatePdf(
    BuildContext context,
    Mission mission,
    List<dynamic> transactions,
  ) async {
    _pdfStep = 1;
    notifyListeners();
    //
    final pdf = pw.Document(title: "Rapport de la mission : ${mission.nom}");
    final pb = PocketBaseDb.instance.pb;

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

    final trxWithImages = transactions
        .where((trx) => trx.justificatif != null && trx.justificatif.isNotEmpty)
        .toList();
    //
    List<pw.Widget> imagesWidget = List.empty(growable: true);

    _pdfStep = 2;
    notifyListeners();
    //
    if (trxWithImages.isNotEmpty) {
      for (var trx in trxWithImages) {
        //
        final baseUrl = pb.baseURL;
        final collectionName = trx is Entree ? "entrees" : "depenses";
        final recordId = trx.id;
        final fileName = trx.justificatif;
        //
        final imageUrl =
            "$baseUrl/api/files/$collectionName/$recordId/$fileName?thumb=100x0";
        log("Tentative de récupération d'image: $imageUrl");
        //
        final trxImageBytes = await fetchImageBytes(imageUrl);
        //
        if (trxImageBytes.isNotEmpty) {
          //
          final compressedBytes = await compressImageBytes(trxImageBytes);
          //
          imagesWidget.add(
            pw.Column(
              children: [
                // Image container
                pw.ClipRRect(
                  horizontalRadius: 6,
                  verticalRadius: 6,
                  child: pw.Container(
                    width: 220,
                    height: 200,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(width: 1, color: PdfColors.grey200),
                    ),
                    child: pw.Image(
                      pw.MemoryImage(compressedBytes),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),

                pw.SizedBox(height: 5),
                // trx description && trx montant
                pw.Text(
                  "${trx.description} (${currencyFormater.format(trx.montant)})",
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.SizedBox(height: 16),
              ],
            ),
          );
        }
      }
    }

    _pdfStep = 3;
    notifyListeners();

    ///
    pdf.addPage(
      pw.MultiPage(
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
          //
          final userName = mission.user;
          //

          ///
          return [
            /// logo image and mission title
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

                /// Mission name
                pw.Text(
                  mission.nom,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            /// user name and mission date
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      userName,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Mission du ${formattedDate.format(mission.dateDebut)} • au ${formattedDate.format(mission.dateFin)}",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            /// Total Entrées • Dépenses / Budget initial et restant / Montant objectif
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                children: [
                  // Budget initial
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text("Budget initial")),
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
                  // Budget restant
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text("Budget restant")),
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

            /// Trx detail headline
            pw.SizedBox(height: 24),
            pw.Text(
              "Détail des transactions",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            /// table helper here
            pw.TableHelper.fromTextArray(
              border: null,
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(2),
              ),
              headers: ["Intitulé", "Type", "Date", "Montant"],
              data: transactions
                  .map(
                    (trx) => [
                      trx.description,
                      trx is Entree ? "Entrée" : "Dépense",
                      formattedDate.format(trx.createdAt),
                      currencyFormater.format(trx.montant),
                    ],
                  )
                  .toList(),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 24),

            /// Trx images headline
            pw.Text(
              "Pièces justificatives des transactions",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            /// Images justificatif
            if (imagesWidget.isNotEmpty)
              pw.Wrap(spacing: 20, runSpacing: 30, children: imagesWidget),
            pw.SizedBox(height: 24),
          ];
        },
      ),
    );
    _pdfStep = 4;
    notifyListeners();
    //
    return pdf.save();
  }

  int _pdfStep = 0;

  int get pdfStep => _pdfStep;

  final List<String> _pdfSteps = [
    "Récupération des données...",
    "Génération du rapport...",
    "Traitement des images...",
    "Finalisation du PDF...",
    "Téléchargement en cours...",
  ];

  String get pdfStepLabel => _pdfSteps[_pdfStep.clamp(0, _pdfSteps.length - 1)];

  bool _isCreatingPdfWeb = false;

  bool get isCreatingPdfWeb => _isCreatingPdfWeb;

  Future<void> downloadPdfWeb(
    BuildContext context,
    Mission mission,
    List<dynamic> transactions,
  ) async {
    _isCreatingPdfWeb = true;
    notifyListeners();
    try {
      _pdfStep = 1;
      notifyListeners();
      final pdfBytes = await getCachedPdf(context, mission, transactions);

      _pdfStep = 4;
      notifyListeners();
      //
      final blob = web.Blob(
        [pdfBytes.buffer.toJS].toJS,
        web.BlobPropertyBag(type: 'application/pdf'),
      );
      final url = web.URL.createObjectURL(blob);

      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..setAttribute('download', 'Rapport_${mission.nom}.pdf');
      //
      web.document.body!.append(anchor);
      anchor.click();
      web.document.body!.removeChild(anchor);
      //
      web.URL.revokeObjectURL(url);
      log("✅ Téléchargement lancé côté Admin");
    } catch (e) {
      log("❌ Erreur téléchargement : $e");
    } finally {
      _isCreatingPdfWeb = false;
      _pdfStep = 0;
      notifyListeners();
    }
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
      final pdfBytes = await getCachedPdf(context, mission, transactions);
      //
      final formattedNow = DateFormat(
        "dd_MM_yyyy_HH_mm",
      ).format(DateTime.now());
      final sanitizedMissionName = mission.nom
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'[^\s+]'), '_')
          .replaceAll(RegExp(r"[^_+]"), '_');
      final fileName = 'Rapport_${sanitizedMissionName}_$formattedNow.pdf';
      //
      final XFile xfile;
      if (kIsWeb) {
        xfile = XFile.fromData(
          pdfBytes,
          mimeType: 'application/pdf',
          name: fileName,
        );
      } else {
        final directory = await getTemporaryDirectory();
        final path = "${directory.path}/$fileName";
        await File(path).writeAsBytes(pdfBytes);
        xfile = XFile(path);
      }
      //
      await SharePlus.instance.share(
        ShareParams(
          files: [xfile],
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

  bool _isLoadingPreview = false;

  bool get isLoadingPreview => _isLoadingPreview;

  Future<void> previewPdf(
    BuildContext context,
    Mission mission,
    List<dynamic> transactions,
  ) async {
    _isLoadingPreview = true;
    notifyListeners();
    try {
      final pdfBytes = await getCachedPdf(context, mission, transactions);
      final pdfPinchController = px.PdfControllerPinch(
        document: px.PdfDocument.openData(pdfBytes),
      );

      if (!context.mounted) return;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        useSafeArea: true,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height,
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
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
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
    } catch (e) {
      log("Error while previewing pdf: $e");
    } finally {
      _isLoadingPreview = false;
      notifyListeners();
    }
  }

  /// Disposer
  @override
  void dispose() {
    super.dispose();
  }
}
