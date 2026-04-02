import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateAndShareReceipt({
  required String referenceNumber,
  required String clientName,
  required String serviceTitle,
  required String date,
  String? paymentMethod,
  String? status,
}) async {
  final doc = pw.Document();

  const gold = PdfColor.fromInt(0xFFD4AF37);
  const obsidian = PdfColor.fromInt(0xFF080C18);
  const surface = PdfColor.fromInt(0xFF0F1525);
  const muted = PdfColor.fromInt(0xFF8A97B0);
  const white = PdfColors.white;

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (_) => pw.Container(
        color: obsidian,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Header band ────────────────────────────────────────
            pw.Container(
              color: surface,
              padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 36),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'STÉPHANE MBIA',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: white,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.Text(
                        'CONSULTING',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: gold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'REÇU DE CONSULTATION',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: muted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        referenceNumber,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: gold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Gold accent line ────────────────────────────────────
            pw.Container(height: 2, color: gold),

            // ── Body ───────────────────────────────────────────────
            pw.Padding(
              padding: const pw.EdgeInsets.all(48),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 8),

                  // Status badge
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: gold,
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      status ?? 'En attente',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: obsidian,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 40),

                  // ── Details table ────────────────────────────────
                  _buildRow('Référence', referenceNumber, gold, muted, white),
                  _buildDivider(muted),
                  _buildRow('Client', clientName, gold, muted, white),
                  _buildDivider(muted),
                  _buildRow('Service', serviceTitle, gold, muted, white),
                  _buildDivider(muted),
                  _buildRow("Date d'émission", date, gold, muted, white),
                  if (paymentMethod != null && paymentMethod.isNotEmpty) ...[
                    _buildDivider(muted),
                    _buildRow('Mode de règlement', paymentMethod, gold, muted, white),
                  ],

                  pw.SizedBox(height: 56),

                  // ── Footer note ──────────────────────────────────
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: surface,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(
                        color: const PdfColor.fromInt(0xFF1E2A42),
                      ),
                    ),
                    child: pw.Text(
                      'Ce document est généré automatiquement et constitue un justificatif officiel '
                      'de votre demande de consultation auprès de Stéphane Mbia Consulting. '
                      'Conservez ce reçu pour vos dossiers.',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: muted,
                        lineSpacing: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.Spacer(),

            // ── Footer ─────────────────────────────────────────────
            pw.Container(
              color: surface,
              padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'www.stephanembia.com',
                    style: pw.TextStyle(fontSize: 9, color: muted),
                  ),
                  pw.Text(
                    'contact@stephanembia.com',
                    style: pw.TextStyle(fontSize: 9, color: muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  final filename = 'recu-$referenceNumber.pdf';
  await Printing.sharePdf(bytes: await doc.save(), filename: filename);
}

pw.Widget _buildRow(
  String label,
  String value,
  PdfColor gold,
  PdfColor muted,
  PdfColor white,
) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 14),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, color: muted),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: white,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildDivider(PdfColor muted) {
  return pw.Container(
    height: 0.5,
    color: const PdfColor.fromInt(0xFF1E2A42),
  );
}
