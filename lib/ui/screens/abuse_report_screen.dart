import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/report_export_service.dart';
import '../../core/theme/app_tokens.dart';
import '../widgets/section_header.dart';

class AbuseReportScreen extends StatefulWidget {
  const AbuseReportScreen({super.key});

  @override
  State<AbuseReportScreen> createState() => _AbuseReportScreenState();
}

class _AbuseReportScreenState extends State<AbuseReportScreen> {
  final _addressCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  bool _hasPhotos = false;
  bool _hasWitness = false;
  bool _isEmergency = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _call(String number) async {
    await launchUrl(Uri.parse('tel:$number'));
  }

  Future<void> _shareSummary() async {
    final text = 'Resumo de denúncia de maus-tratos (Lei 14.064/2020)\n'
        'Data/Hora: ${DateTime.now()}\n'
        'Local: ${_addressCtrl.text.trim().isEmpty ? "Não informado" : _addressCtrl.text.trim()}\n'
        'Risco imediato: ${_isEmergency ? "Sim" : "Não"}\n'
        'Possui fotos/vídeos: ${_hasPhotos ? "Sim" : "Não"}\n'
        'Possui testemunhas: ${_hasWitness ? "Sim" : "Não"}\n'
        'Relato: ${_detailsCtrl.text.trim().isEmpty ? "Sem relato adicional" : _detailsCtrl.text.trim()}';
    await ReportExportService.shareText(
      text,
      subject: 'Denúncia de maus-tratos — RedePatas',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Denúncia de Maus-Tratos')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.gavel_outlined,
                        color: theme.colorScheme.primary,
                        size: 26,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Maus-tratos a animais é crime (Lei Federal 14.064/2020). O RedePatas orienta o registro, mas não substitui as autoridades policiais.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Acionar autoridades'),
              FilledButton.icon(
                onPressed: () => _call('190'),
                icon: const Icon(Icons.local_police_outlined),
                label: const Text('Ligar para Polícia Militar (190)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _call('193'),
                icon: const Icon(Icons.local_fire_department_outlined),
                label: const Text('Ligar para Bombeiros (193)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _call('181'),
                icon: const Icon(Icons.shield_outlined),
                label: const Text('Disque-Denúncia SC (181)'),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Checklist de evidências'),
              Card(
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _hasPhotos,
                      onChanged: (v) => setState(() => _hasPhotos = v ?? false),
                      title: const Text('Tenho fotos ou vídeos da situação'),
                    ),
                    const Divider(),
                    CheckboxListTile(
                      value: _hasWitness,
                      onChanged: (v) =>
                          setState(() => _hasWitness = v ?? false),
                      title: const Text('Há testemunhas no local'),
                    ),
                    const Divider(),
                    CheckboxListTile(
                      value: _isEmergency,
                      onChanged: (v) =>
                          setState(() => _isEmergency = v ?? false),
                      title: const Text('Animal em risco imediato de vida'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Endereço ou ponto de referência',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _detailsCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descreva o ocorrido',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _shareSummary,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Gerar e compartilhar resumo'),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
