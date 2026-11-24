import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/ong_controller.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/campaign_model.dart';
import '../widgets/empty_state.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  static final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final ong = context.watch<OngController>();
    final campaigns = ong.campaigns;

    return Scaffold(
      appBar: AppBar(title: const Text('Doações e Campanhas')),
      floatingActionButton: auth.isOrganization
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateCampaignModal(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nova campanha'),
            )
          : null,
      body: campaigns.isEmpty
          ? EmptyState(
              icon: Icons.volunteer_activism_outlined,
              title: 'Nenhuma campanha ativa',
              description:
                  'Campanhas de arrecadação de ração, medicamentos e castração via Pix aparecem aqui.',
              actionLabel: auth.isOrganization ? 'Criar campanha' : null,
              onAction: auth.isOrganization
                  ? () => _showCreateCampaignModal(context)
                  : null,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl * 3,
              ),
              itemCount: campaigns.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final camp = campaigns[index];
                final org = ong.getOrganizationById(camp.organizationId);
                final isMoney = camp.kind == CampaignKind.dinheiro;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isMoney
                                  ? Icons.pix_outlined
                                  : Icons.inventory_2_outlined,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                camp.title,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${org?.name ?? "ONG parceira"} • ${camp.kind.label}'
                          '${camp.deadline != null ? " • Até ${_dateFmt.format(camp.deadline!)}" : ""}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(camp.description, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: AppSpacing.md),

                        // Barra de progresso animada
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: camp.progress),
                          duration: AppMotion.duration(
                            context,
                            const Duration(milliseconds: 500),
                          ),
                          builder: (_, val, _) => ClipRRect(
                            borderRadius: AppRadius.pillRadius,
                            child: LinearProgressIndicator(
                              value: val,
                              minHeight: 12,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isMoney
                                  ? 'R\$ ${camp.currentAmount.toStringAsFixed(0)} de R\$ ${camp.goalAmount.toStringAsFixed(0)}'
                                  : '${camp.currentAmount.toStringAsFixed(0)} de ${camp.goalAmount.toStringAsFixed(0)} ${camp.unit}',
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              '${camp.progressPercent}%',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (isMoney && org?.pixKey != null) ...[
                          FilledButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: org!.pixKey!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Chave Pix copiada: ${org.pixKey}',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded),
                            label: const Text('Copiar Pix'),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        OutlinedButton.icon(
                          onPressed: () =>
                              _showDonateModal(context, camp, org?.whatsapp),
                          icon: const Icon(Icons.volunteer_activism_outlined),
                          label: Text(
                            auth.isOrganization
                                ? 'Registrar doação recebida'
                                : 'Vou doar',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDonateModal(
    BuildContext context,
    CampaignModel camp,
    String? orgWhatsapp,
  ) {
    final user = context.read<AuthController>().currentUser;
    final donorCtrl = TextEditingController(text: user?.name ?? '');
    final amountCtrl = TextEditingController(
      text: camp.kind == CampaignKind.dinheiro ? '50' : '5',
    );
    final noteCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text('Apoiar: ${camp.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: donorCtrl,
                decoration: const InputDecoration(labelText: 'Nome do apoiador'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantidade (${camp.unit})',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observação (opcional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final amount =
                  double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
              if (amount <= 0) return;
              await context.read<OngController>().registerDonation(
                    DonationModel(
                      id: 'don_${DateTime.now().millisecondsSinceEpoch}',
                      campaignId: camp.id,
                      donorName: donorCtrl.text.trim().isEmpty
                          ? 'Apoiador'
                          : donorCtrl.text.trim(),
                      amount: amount,
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim(),
                      createdAt: DateTime.now(),
                    ),
                  );
              if (dlgCtx.mounted) Navigator.of(dlgCtx).pop();
              if (camp.kind == CampaignKind.item &&
                  orgWhatsapp != null &&
                  orgWhatsapp.isNotEmpty) {
                final clean = orgWhatsapp.replaceAll(RegExp(r'\D'), '');
                final msg = Uri.encodeComponent(
                  'Olá! Quero doar ${amount.toStringAsFixed(0)} ${camp.unit} para a campanha "${camp.title}" no RedePatas.',
                );
                await launchUrl(
                  Uri.parse('https://wa.me/55$clean?text=$msg'),
                  mode: LaunchMode.externalApplication,
                );
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Doação registrada! Obrigado pelo apoio.'),
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showCreateCampaignModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final goalCtrl = TextEditingController(text: '100');
    final unitCtrl = TextEditingController(text: 'kg');
    CampaignKind kind = CampaignKind.item;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModal) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            MediaQuery.of(sheetCtx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nova campanha de doação',
                style: Theme.of(sheetCtx).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<CampaignKind>(
                segments: const [
                  ButtonSegment(
                    value: CampaignKind.item,
                    label: Text('Itens'),
                  ),
                  ButtonSegment(
                    value: CampaignKind.dinheiro,
                    label: Text('Financeira (Pix)'),
                  ),
                ],
                selected: {kind},
                onSelectionChanged: (sel) => setModal(() {
                  kind = sel.first;
                  unitCtrl.text =
                      kind == CampaignKind.dinheiro ? 'R\$' : 'kg';
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: goalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Meta'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(labelText: 'Unidade'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) return;
                  final orgId = context
                          .read<AuthController>()
                          .currentUser
                          ?.organizationId ??
                      'org_apad_demo';
                  await context.read<OngController>().saveCampaign(
                        CampaignModel(
                          id: 'camp_${DateTime.now().millisecondsSinceEpoch}',
                          organizationId: orgId,
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          kind: kind,
                          goalAmount: double.tryParse(goalCtrl.text) ?? 100,
                          unit: unitCtrl.text.trim().isEmpty
                              ? 'un'
                              : unitCtrl.text.trim(),
                          deadline:
                              DateTime.now().add(const Duration(days: 30)),
                          createdAt: DateTime.now(),
                        ),
                      );
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                },
                child: const Text('Publicar campanha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
