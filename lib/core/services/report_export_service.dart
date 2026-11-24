import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../controllers/ong_controller.dart';
import '../../models/event_model.dart';
import '../../models/help_request_model.dart';
import '../../models/shelter_animal_model.dart';

class ReportExportService {
  static final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  static String buildRequestShareText(HelpRequestModel req) {
    final needs = req.needs.map((n) => n.label).join(', ');
    return '${req.title} (${req.species.label}) precisa de $needs\n'
        'Local: ${req.neighborhood}, ${req.city} — ${req.referencePoint}\n'
        'Urgência: ${req.urgency.label} | Status: ${req.status.label}\n'
        '${req.description}\n\n'
        'Ajude pelo app RedePatas!';
  }

  static String buildAdoptionShareText(ShelterAnimalModel animal) {
    final healthTags = [
      if (animal.vaccinated) 'Vacinado',
      if (animal.castrated) 'Castrado',
    ].join(' • ');
    return 'Adoção Responsável — ${animal.name} (${animal.species.label})\n'
        '${animal.sex} • ${animal.ageGroup} • Porte ${animal.size}\n'
        '${healthTags.isNotEmpty ? '$healthTags\n' : ''}'
        '${animal.description}\n\n'
        'Conheça no RedePatas!';
  }

  static Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
  }

  static String buildRequestsCsv(List<HelpRequestModel> requests) {
    final rows = <List<dynamic>>[
      [
        'ID',
        'Título',
        'Espécie',
        'Necessidades',
        'Urgência',
        'Status',
        'Cidade',
        'Bairro',
        'Referência',
        'Autor',
        'Voluntário',
        'Criado em',
      ],
      for (final r in requests)
        [
          r.id,
          r.title,
          r.species.label,
          r.needs.map((n) => n.label).join('; '),
          r.urgency.label,
          r.status.label,
          r.city,
          r.neighborhood,
          r.referencePoint,
          r.authorName,
          r.helperName ?? '',
          _dateFmt.format(r.createdAt),
        ],
    ];
    return const CsvEncoder().convert(rows);
  }

  static String buildEventSignupsCsv(
    CommunityEventModel event,
    List<EventSignupModel> signups,
  ) {
    final rows = <List<dynamic>>[
      ['Evento', 'Participante', 'Telefone', 'Presença', 'Inscrito em'],
      for (final s in signups)
        [
          event.title,
          s.userName,
          s.phone ?? '',
          s.attended ? 'Sim' : 'Não',
          _dateFmt.format(s.createdAt),
        ],
    ];
    return const CsvEncoder().convert(rows);
  }

  static String buildBackupJson(List<HelpRequestModel> requests) {
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'RedePatas',
      'exportedAt': DateTime.now().toIso8601String(),
      'requests': requests.map((r) => r.toMap()).toList(),
    });
  }

  static Future<Uint8List> buildOngReportPdf({
    required String orgName,
    required String periodLabel,
    required OngDashboardMetrics metrics,
    required List<HelpRequestModel> requests,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Relatório RedePatas — $orgName',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text('Período: $periodLabel'),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Gerado em ${_dateFmt.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _pdfStat('Abertos', '${metrics.openCount}'),
              _pdfStat('Em atendimento', '${metrics.inProgressCount}'),
              _pdfStat('Concluídos', '${metrics.completedCount}'),
              _pdfStat(
                'Tempo médio',
                metrics.avgResolutionHours == null
                    ? '—'
                    : '${metrics.avgResolutionHours!.toStringAsFixed(1)} h',
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Casos registrados (${requests.length})',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Animal', 'Bairro', 'Urgência', 'Status', 'Voluntário'],
            data: requests
                .take(40)
                .map(
                  (r) => [
                    r.title,
                    '${r.neighborhood} - ${r.city}',
                    r.urgency.label,
                    r.status.label,
                    r.helperName ?? '—',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _pdfStat(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static Future<void> shareFileBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    String? text,
  }) async {
    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, name: filename, mimeType: mimeType)],
          text: text,
        ),
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        text: text,
      ),
    );
  }
}
