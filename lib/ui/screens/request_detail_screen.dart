import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../controllers/ong_controller.dart';
import '../../core/services/report_export_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/case_update_model.dart';
import '../../models/help_request_model.dart';
import '../../models/shelter_animal_model.dart';
import '../widgets/section_header.dart';
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
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    final formattedDate =
        DateFormat('dd/MM/yyyy • HH:mm').format(request.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes do Pedido',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Compartilhar pedido',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ReportExportService.shareText(
                ReportExportService.buildRequestShareText(request),
                subject: 'Pedido RedePatas: ${request.title}',
              );
            },
          ),
          IconButton(
            tooltip: 'Editar informações do pedido',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditRequestModal(context, request),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto ou ilustração minimalista da espécie
            _DetailHeaderPhoto(request: request),
            const SizedBox(height: AppSpacing.md),

            // Badges de Status Atual e Nível de Urgência
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusBadge(status: request.status),
                UrgencyBadge(urgency: request.urgency, showNormal: true),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Stepper horizontal do ciclo de vida
            _StatusStepper(status: request.status),
            const SizedBox(height: AppSpacing.sm),

            // Título do animal + Data/Hora da publicação
            Text(
              request.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${request.species.label} • Publicado em $formattedDate',
              style: TextStyle(color: secondaryTextColor, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.md),

            // Chips de necessidades
            const SectionHeader(title: 'Necessidades'),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: request.needs.map((need) {
                return Chip(
                  avatar: Icon(need.icon, size: 16),
                  label: Text(need.label),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Superfície unificada com divisores finos
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.controlRadius,
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Localização
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Localização'),
                        _InfoRow(
                          label: 'Cidade e Bairro',
                          value: '${request.city} — Bairro ${request.neighborhood}',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          label: 'Ponto de referência',
                          value: request.referencePoint.isEmpty
                              ? 'Não informado'
                              : request.referencePoint,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Descrição
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Descrição da situação'),
                        Text(
                          request.description,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Registro e Atendimento
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Registro e Atendimento'),
                        _InfoRow(
                          label: 'Publicado por',
                          value: request.authorName,
                        ),
                        if (request.helperName != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _InfoRow(
                            label: request.status == RequestStatus.completed
                                ? 'Atendido por'
                                : 'Sendo atendido por',
                            value: request.helperName!,
                          ),
                          if (request.helperCommitment != null &&
                              request.helperCommitment!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Compromisso: ${request.helperCommitment}',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Ações extras de localização / ONG
            if (request.hasCoordinates) ...[
              OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=${request.latitude},${request.longitude}',
                  );
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.directions_outlined),
                label: const Text('Abrir rota no mapa'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Linha do tempo do caso (F7)
            Builder(
              builder: (context) {
                final ong = context.watch<OngController>();
                final auth = context.watch<AuthController>();
                final updates = ong.updatesForRequest(request.id);
                final dateFmt = DateFormat('dd/MM • HH:mm');

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeader(
                              title: 'Linha do tempo do caso',
                              padding: EdgeInsets.zero,
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _showAddUpdateDialog(context, request),
                              icon: const Icon(Icons.add_comment_outlined),
                              label: const Text('Atualizar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (updates.isEmpty)
                          Text(
                            'Nenhuma atualização adicional registrada ainda.',
                            style: theme.textTheme.bodyMedium,
                          )
                        else
                          for (final upd in updates)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    upd.type.icon,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${upd.type.label} • ${upd.authorName}',
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        Text(
                                          upd.message,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        Text(
                                          dateFmt.format(upd.createdAt),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        if (auth.isOrganization ||
                            request.status == RequestStatus.completed) ...[
                          const Divider(),
                          const SizedBox(height: AppSpacing.xs),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final orgId = auth.currentUser?.organizationId ??
                                  'org_apad_demo';
                              await ong.saveShelterAnimal(
                                ShelterAnimalModel(
                                  id: 'ani_from_${request.id}',
                                  organizationId: orgId,
                                  name: request.title,
                                  species: request.species,
                                  sex: 'Não informado',
                                  ageGroup: 'Adulto',
                                  size: 'Médio',
                                  temperament: 'Em avaliação',
                                  health: 'Resgatado via RedePatas',
                                  status: AnimalStatus.acolhido,
                                  photoPath: request.photoPath,
                                  description: request.description,
                                  originRequestId: request.id,
                                  createdAt: DateTime.now(),
                                ),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Animal registrado na vitrine de acolhidos/adoção!',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.pets_outlined),
                            label: const Text(
                              'Registrar como animal acolhido (ONG)',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
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
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        child: switch (request.status) {
          RequestStatus.open => FilledButton.icon(
              onPressed: () => _showVolunteerModal(context, request),
              icon: const Icon(Icons.volunteer_activism_outlined, size: 18),
              label: const Text('Quero Ajudar este Animal'),
            ),
          RequestStatus.inProgress => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (request.authorPhone != null &&
                    request.authorPhone!.trim().isNotEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: () => _openWhatsApp(context, request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.sageTertiary,
                      side: const BorderSide(
                        color: AppTheme.sageTertiary,
                        width: 1.2,
                      ),
                    ),
                    icon: const Icon(Icons.chat_outlined, size: 18),
                    label: const Text('Falar no WhatsApp com quem publicou'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                FilledButton.icon(
                  onPressed: () async {
                    final user = context.read<AuthController>().currentUser;
                    await controller.updateStatus(
                      request.id,
                      RequestStatus.completed,
                    );
                    if (context.mounted) {
                      await context.read<OngController>().addCaseUpdate(
                            CaseUpdateModel(
                              id: 'upd_${DateTime.now().millisecondsSinceEpoch}',
                              requestId: request.id,
                              authorId: user?.id ?? 'user_demo',
                              authorName: user?.name ?? 'Voluntário',
                              type: CaseUpdateType.concluido,
                              message: 'Atendimento marcado como concluído.',
                              createdAt: DateTime.now(),
                            ),
                          );
                    }
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
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Marcar ajuda como Concluída'),
                ),
              ],
            ),
          RequestStatus.completed => Row(
              children: [
                const Expanded(
                  child: Text(
                    'Este animal já recebeu auxílio.',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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

  void _showAddUpdateDialog(BuildContext context, HelpRequestModel request) {
    final msgCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: const Text('Adicionar atualização'),
        content: TextField(
          controller: msgCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'O que aconteceu?',
            hintText: 'Ex: Animal alimentado, levado ao veterinário...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final text = msgCtrl.text.trim();
              if (text.isEmpty) return;
              final user = context.read<AuthController>().currentUser;
              await context.read<OngController>().addCaseUpdate(
                    CaseUpdateModel(
                      id: 'upd_${DateTime.now().millisecondsSinceEpoch}',
                      requestId: request.id,
                      authorId: user?.id ?? 'user_demo',
                      authorName: user?.name ?? 'Voluntário',
                      type: CaseUpdateType.atualizacao,
                      message: text,
                      createdAt: DateTime.now(),
                    ),
                  );
              if (dlgCtx.mounted) Navigator.of(dlgCtx).pop();
            },
            child: const Text('Publicar'),
          ),
        ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.control * 2),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Confirmar apoio ao animal',
                    style:
                        Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Selecione o apoio que você fornecerá para "${request.title}":',
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                            title: Text(option, style: const TextStyle(fontSize: 14)),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: customController,
                    decoration: const InputDecoration(
                      labelText: 'Observação adicional (opcional)',
                      hintText: 'Ex: Chego no local por volta das 18h',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
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
                    child: const Text('Confirmar Compromisso'),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.control * 2),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Editar Pedido',
                    style:
                        Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Identificação do animal',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: refCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ponto de referência',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrição da situação',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
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
                  const SizedBox(height: AppSpacing.md),
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

  bool _hasValidPhoto(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
      return true;
    }
    return File(path).existsSync();
  }

  Widget _buildImage(String path, {required BoxFit fit}) {
    if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(
        path,
        width: double.infinity,
        fit: fit,
      );
    }
    return Image.file(
      File(path),
      width: double.infinity,
      fit: fit,
    );
  }

  void _openFullScreenPhoto(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullScreenPhotoViewer(
          heroTag: 'request_photo_${request.id}',
          title: request.title,
          imageBuilder: (fit) => _buildImage(path, fit: fit),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    final path = request.photoPath;
    if (path != null && _hasValidPhoto(path)) {
      return Material(
        color: Colors.transparent,
        borderRadius: AppRadius.controlRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openFullScreenPhoto(context, path),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              SizedBox(
                width: double.infinity,
                height: 220,
                child: Hero(
                  tag: 'request_photo_${request.id}',
                  child: _buildImage(path, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_full_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Ver foto completa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.controlRadius,
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            request.species.icon,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            request.species.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenPhotoViewer extends StatelessWidget {
  final String heroTag;
  final String title;
  final Widget Function(BoxFit fit) imageBuilder;

  const _FullScreenPhotoViewer({
    required this.heroTag,
    required this.title,
    required this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const Border(),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Hero(
              tag: heroTag,
              child: imageBuilder(BoxFit.contain),
            ),
          ),
        ),
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
    final secondaryTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _StatusStepper extends StatelessWidget {
  final RequestStatus status;

  const _StatusStepper({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStep = switch (status) {
      RequestStatus.open => 0,
      RequestStatus.inProgress => 1,
      RequestStatus.completed => 2,
    };
    const labels = ['Aberto', 'Em atendimento', 'Concluído'];

    return Row(
      children: List.generate(3, (index) {
        final active = index <= currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.duration(context, AppMotion.normal),
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        borderRadius: AppRadius.pillRadius,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (index < 2) const SizedBox(width: 6),
            ],
          ),
        );
      }),
    );
  }
}
