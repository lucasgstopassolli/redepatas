import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../controllers/ong_controller.dart';
import '../../core/services/report_export_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import 'adoption_screen.dart';
import 'campaigns_screen.dart';
import 'events_ongs_screen.dart';
import 'request_detail_screen.dart';

class OrgDashboardScreen extends StatefulWidget {
  const OrgDashboardScreen({super.key});

  @override
  State<OrgDashboardScreen> createState() => _OrgDashboardScreenState();
}

class _OrgDashboardScreenState extends State<OrgDashboardScreen> {
  int? _periodDays = 30; // 7, 30, null (Tudo)
  bool _exporting = false;

  String get _periodLabel => switch (_periodDays) {
        7 => 'Últimos 7 dias',
        30 => 'Últimos 30 dias',
        _ => 'Todo o período',
      };

  Future<void> _exportPdf(
    String orgName,
    OngDashboardMetrics metrics,
    List<HelpRequestModel> requests,
  ) async {
    setState(() => _exporting = true);
    try {
      final bytes = await ReportExportService.buildOngReportPdf(
        orgName: orgName,
        periodLabel: _periodLabel,
        metrics: metrics,
        requests: requests,
      );
      await ReportExportService.shareFileBytes(
        bytes: bytes,
        filename: 'relatorio_redepatas.pdf',
        mimeType: 'application/pdf',
        text: 'Relatório RedePatas — $orgName ($_periodLabel)',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível compartilhar o PDF neste ambiente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportCsv(List<HelpRequestModel> requests) async {
    setState(() => _exporting = true);
    try {
      final csvText = ReportExportService.buildRequestsCsv(requests);
      await ReportExportService.shareFileBytes(
        bytes: Uint8List.fromList(utf8.encode(csvText)),
        filename: 'pedidos_redepatas.csv',
        mimeType: 'text/csv',
        text: 'Planilha de casos RedePatas ($_periodLabel)',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível exportar o CSV neste ambiente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;
    final auth = context.watch<AuthController>();
    final helpController = context.watch<HelpRequestController>();
    final ongController = context.watch<OngController>();

    final org = ongController.getOrganizationById(auth.currentUser?.organizationId);
    final orgName = org?.name ?? 'Gestão Comunitária';
    final requests = helpController.allRequests;
    final metrics = ongController.computeMetrics(
      requests,
      periodDays: _periodDays,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Painel da ONG')),
      body: requests.isEmpty
          ? const EmptyState(
              icon: Icons.analytics_outlined,
              title: 'Sem dados suficientes ainda',
              description:
                  'Assim que pedidos forem registrados na rede, as métricas e gráficos aparecerão aqui.',
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Cabeçalho da ONG
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainer,
                                borderRadius: AppRadius.controlRadius,
                              ),
                              child: Icon(
                                Icons.apartment_rounded,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          orgName,
                                          style: theme.textTheme.titleMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (org?.verified == true) ...[
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 18,
                                          color: theme.colorScheme.tertiary,
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    '${org?.city ?? "Rio do Sul"} • Gestão e transparência',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Filtro de período
                    SegmentedButton<int?>(
                      segments: const [
                        ButtonSegment(value: 7, label: Text('7 dias')),
                        ButtonSegment(value: 30, label: Text('30 dias')),
                        ButtonSegment(value: null, label: Text('Tudo')),
                      ],
                      selected: {_periodDays},
                      onSelectionChanged: (sel) {
                        setState(() => _periodDays = sel.first);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Grade de métricas principais
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.45,
                      children: [
                        _MetricTile(
                          label: 'Abertos',
                          value: '${metrics.openCount}',
                          color: semantic.statusOpenFg,
                          icon: Icons.error_outline_rounded,
                        ),
                        _MetricTile(
                          label: 'Em atendimento',
                          value: '${metrics.inProgressCount}',
                          color: semantic.statusInProgressFg,
                          icon: Icons.volunteer_activism_outlined,
                        ),
                        _MetricTile(
                          label: 'Concluídos',
                          value: '${metrics.completedCount}',
                          color: semantic.statusCompletedFg,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                        _MetricTile(
                          label: 'Tempo médio',
                          value: metrics.avgResolutionHours == null
                              ? '—'
                              : '${metrics.avgResolutionHours!.toStringAsFixed(1)}h',
                          color: theme.colorScheme.primary,
                          icon: Icons.timer_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Alerta de críticos > 2h sem voluntário
                    if (metrics.overdueCritical.isNotEmpty) ...[
                      const SectionHeader(
                        title: 'Críticos sem voluntário há mais de 2h',
                      ),
                      for (final req in metrics.overdueCritical)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.priority_high_rounded,
                                color: semantic.urgencyCriticalFg,
                              ),
                              title: Text(req.title),
                              subtitle: Text(
                                '${req.neighborhood} • ${req.needsSummary}',
                              ),
                              trailing: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => RequestDetailScreen(
                                        requestId: req.id,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Abrir'),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Gráfico de barras por necessidade
                    const SectionHeader(title: 'Distribuição por necessidade'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          height: 190,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    interval: 1,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      final idx = value.toInt();
                                      if (idx < 0 ||
                                          idx >= NeedType.values.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final need = NeedType.values[idx];
                                      final short = need == NeedType.medical
                                          ? 'Socorro'
                                          : need.label;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          short,
                                          style: theme.textTheme.labelMedium,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(
                                NeedType.values.length,
                                (i) {
                                  final need = NeedType.values[i];
                                  final count =
                                      (metrics.byNeed[need] ?? 0).toDouble();
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: count,
                                        width: 24,
                                        color: i == 3
                                            ? semantic.urgencyCriticalFg
                                            : theme.colorScheme.primary,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(6),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Distribuição por espécie (PieChart) e bairros
                    const SectionHeader(title: 'Espécies e bairros'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (metrics.bySpecies.isNotEmpty)
                              SizedBox(
                                height: 150,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 30,
                                    sections: [
                                      for (final entry
                                          in metrics.bySpecies.entries)
                                        PieChartSectionData(
                                          value: entry.value.toDouble(),
                                          title:
                                              '${entry.key.label} (${entry.value})',
                                          radius: 46,
                                          color: switch (entry.key) {
                                            AnimalSpecies.dog =>
                                              theme.colorScheme.primary,
                                            AnimalSpecies.cat =>
                                              theme.colorScheme.secondary,
                                            AnimalSpecies.other =>
                                              theme.colorScheme.tertiary,
                                          },
                                          titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            if (metrics.byNeighborhood.isNotEmpty) ...[
                              const Divider(),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  for (final entry in (metrics
                                          .byNeighborhood.entries
                                          .toList()
                                        ..sort((a, b) =>
                                            b.value.compareTo(a.value)))
                                      .take(6))
                                    Chip(
                                      label: Text(
                                        '${entry.key}: ${entry.value}',
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Atalhos rápidos dos módulos da ONG
                    const SectionHeader(title: 'Módulos da ONG'),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _QuickModuleChip(
                          icon: Icons.pets_outlined,
                          label:
                              'Adoção (${ongController.shelterAnimals.length})',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AdoptionScreen(),
                            ),
                          ),
                        ),
                        _QuickModuleChip(
                          icon: Icons.event_outlined,
                          label: 'Eventos (${ongController.events.length})',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const EventsOngsScreen(),
                            ),
                          ),
                        ),
                        _QuickModuleChip(
                          icon: Icons.volunteer_activism_outlined,
                          label:
                              'Campanhas (${ongController.campaigns.length})',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CampaignsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Exportação de relatórios
                    const SectionHeader(title: 'Prestação de contas'),
                    FilledButton.icon(
                      onPressed: _exporting
                          ? null
                          : () => _exportPdf(orgName, metrics, requests),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(
                        _exporting
                            ? 'Gerando relatório...'
                            : 'Gerar relatório em PDF',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: _exporting ? null : () => _exportCsv(requests),
                      icon: const Icon(Icons.table_chart_outlined),
                      label: const Text('Exportar planilha CSV'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickModuleChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickModuleChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
