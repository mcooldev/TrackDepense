import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
          ShareParams(
            files: [XFile(path)],
            text: "Reçu de transaction",
          ),
        );
        //
        if (!context.mounted) return;
        _scaffoldMessenger(
          context,
          "🎊✅🎉 Fichier partagé avec succès",
          false,
        );
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

  Future<Uint8List> generatePdf(
    BuildContext context,
    Mission mission,
    List<dynamic> transactions,
  ) async {
    final pdf = pw.Document();
    //
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // logo image and title
              pw.Row(),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 5),
              // table header row
              pw.Row(),
              pw.SizedBox(height: 5),
              pw.Divider(),
              pw.SizedBox(height: 10),
              // list of transactions
              pw.ListView.builder(
                itemCount: 1,
                itemBuilder: (pw.Context context, int index) => pw.Container(),
              ),
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

  /// Disposer
  @override
  void dispose() {
    super.dispose();
  }
}
