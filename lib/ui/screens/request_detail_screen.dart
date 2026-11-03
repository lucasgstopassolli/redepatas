import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/help_request_model.dart';
import '../widgets/status_badge.dart';
import '../widgets/urgency_badge.dart';

class RequestDetailScreen extends StatelessWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HelpRequestController>();
    final request = controller.getById(requestId);

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Pedido')),
        body: const Center(child: Text('Pedido não encontrado.')),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final formattedDate =
        DateFormat('dd/MM/yyyy • HH:mm').format(request.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pedido'),
        actions: [
          IconButton(
            tooltip: 'Editar informações do pedido',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditRequestModal(context, request),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto ampliada no topo ou ilustração grande do animal
            _DetailHeaderPhoto(request: request),
            const SizedBox(height: 16),

            // Badges de Status Atual e Nível de Urgência
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusBadge(status: request.status),
                UrgencyBadge(urgency: request.urgency, showNormal: true),
              ],
            ),
            const SizedBox(height: 14),

            // Título do animal + Data/Hora da publicação
            Text(
              request.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Espécie: ${request.species.label} • Publicado em $formattedDate',
              style: TextStyle(color: secondaryTextColor, fontSize: 13.5),
            ),
            const SizedBox(height: 18),

            // Chips de todas as necessidades marcadas
            Text(
              'Necessidades identificadas',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: request.needs.map((need) {
                return Chip(
                  avatar: Text(need.emoji),
                  label: Text(
                    need.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Card de Localização
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Localização do Animal',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: 'Cidade / Bairro:',
                      value: '${request.city} — Bairro ${request.neighborhood}',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Ponto de referência:',
                      value: request.referencePoint.isEmpty
                          ? 'Não informado'
                          : request.referencePoint,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Descrição completa escrita pelo morador
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Descrição da Situação',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      request.description,
                      style: const TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Card de Acompanhamento / Quem publicou e Voluntário
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Registro e Atendimento',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: 'Publicado por:',
                      value: request.authorName,
                    ),
                    if (request.helperName != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.statusInProgressBgDark
                              : AppTheme.statusInProgressBgLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.status == RequestStatus.completed
                                  ? 'Atendido por ${request.helperName}'
                                  : 'Sendo atendido por ${request.helperName}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppTheme.statusInProgressTextDark
                                    : AppTheme.statusInProgressText,
                              ),
                            ),
                            if (request.helperCommitment != null &&
                                request.helperCommitment!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Apoio informado: "${request.helperCommitment}"',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppTheme.statusInProgressTextDark
                                      : AppTheme.statusInProgressText,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(context, request),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    HelpRequestModel request,
  ) {
    final controller = context.read<HelpRequestController>();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
            ),
          ),
        ),
        child: switch (request.status) {
          RequestStatus.open => FilledButton.icon(
              onPressed: () => _showVolunteerModal(context, request),
              icon: const Icon(Icons.volunteer_activism_rounded),
              label: const Text('Quero Ajudar este Animal'),
            ),
          RequestStatus.inProgress => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (request.authorPhone != null &&
                    request.authorPhone!.trim().isNotEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: () => _openWhatsApp(context, request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.sageTertiary,
                      side: const BorderSide(
                        color: AppTheme.sageTertiary,
                        width: 1.5,
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Falar no WhatsApp com quem publicou'),
                  ),
                  const SizedBox(height: 10),
                ],
                FilledButton.icon(
                  onPressed: () async {
                    await controller.updateStatus(
                      request.id,
                      RequestStatus.completed,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pedido marcado como Concluído! Obrigado por ajudar.',
                          ),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.sageTertiary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Marcar ajuda como Concluída'),
                ),
              ],
            ),
          RequestStatus.completed => Row(
              children: [
                const Expanded(
                  child: Text(
                    'Este animal já recebeu o auxílio necessário.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.updateStatus(
                      request.id,
                      RequestStatus.open,
                    );
                  },
                  child: const Text('Reabrir'),
                ),
              ],
            ),
        },
      ),
    );
  }

  void _showVolunteerModal(BuildContext context, HelpRequestModel request) {
    final options = [
      'Vou levar Alimento e Água hoje',
      'Vou levar Alimento hoje',
      'Vou levar Água fresca',
      'Vou providenciar Abrigo temporário',
      'Vou prestar Socorro / Transporte veterinário',
    ];
    String selectedCommitment = options.first;
    final customController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirmar apoio ao animal',
                    style:
                        Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Escolha o que você vai fornecer para "${request.title}" no bairro ${request.neighborhood}:',
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<String>(
                    groupValue: selectedCommitment,
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedCommitment = val);
                      }
                    },
                    child: Column(
                      children: [
                        for (final option in options)
                          RadioListTile<String>(
                            value: option,
                            title: Text(option),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: customController,
                    decoration: const InputDecoration(
                      labelText: 'Observação adicional (opcional)',
                      hintText: 'Ex: Chego no local por volta das 18h',
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () async {
                      final auth = context.read<AuthController>();
                      final user = auth.currentUser;
                      final extra = customController.text.trim();
                      final finalCommitment = extra.isEmpty
                          ? selectedCommitment
                          : '$selectedCommitment ($extra)';

                      await context
                          .read<HelpRequestController>()
                          .assignVolunteer(
                            requestId: request.id,
                            volunteerId: user?.id ?? 'user_demo',
                            volunteerName:
                                user?.name ?? 'Voluntário Comunitário',
                            commitment: finalCommitment,
                          );
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Status atualizado para EM ATENDIMENTO! Veja em "Pedidos -> Estou ajudando".',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.favorite_rounded),
                    label: const Text('Confirmar Compromisso'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditRequestModal(BuildContext context, HelpRequestModel request) {
    final titleCtrl = TextEditingController(text: request.title);
    final refCtrl = TextEditingController(text: request.referencePoint);
    final descCtrl = TextEditingController(text: request.description);
    UrgencyLevel selectedUrgency = request.urgency;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editar Pedido',
                    style:
                        Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Identificação do animal',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: refCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ponto de referência',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrição da situação',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: UrgencyLevel.values.map((u) {
                      return ChoiceChip(
                        label: Text('Urgência: ${u.label}'),
                        selected: selectedUrgency == u,
                        onSelected: (_) {
                          setModalState(() => selectedUrgency = u);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () async {
                      final updated = request.copyWith(
                        title: titleCtrl.text.trim().isEmpty
                            ? request.title
                            : titleCtrl.text.trim(),
                        referencePoint: refCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        urgency: selectedUrgency,
                      );
                      await context
                          .read<HelpRequestController>()
                          .updateRequest(updated);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    child: const Text('Salvar alterações'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openWhatsApp(
    BuildContext context,
    HelpRequestModel request,
  ) async {
    final digits = (request.authorPhone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    final phoneWithCountry = digits.startsWith('55') ? digits : '55$digits';
    final message = Uri.encodeComponent(
      'Olá ${request.authorName}! Vi seu pedido sobre "${request.title}" (${request.neighborhood} - ${request.city}) no aplicativo RedePatas e estou indo ajudar.',
    );
    final uri = Uri.parse('https://wa.me/$phoneWithCountry?text=$message');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível abrir o WhatsApp. Contato: ${request.authorPhone}',
          ),
        ),
      );
    }
  }
}

class _DetailHeaderPhoto extends StatelessWidget {
  final HelpRequestModel request;

  const _DetailHeaderPhoto({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (request.photoPath != null &&
        request.photoPath!.trim().isNotEmpty &&
        !kIsWeb) {
      final file = File(request.photoPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            file,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    final emoji = switch (request.species) {
      AnimalSpecies.dog => '🐕',
      AnimalSpecies.cat => '🐈',
      AnimalSpecies.other => '🐾',
    };

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurfaceContainer
            : AppTheme.lightSurfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkOutline : AppTheme.lightOutline,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 6),
          Text(
            request.species.label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
