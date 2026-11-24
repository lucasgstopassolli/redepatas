import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/ong_controller.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/report_export_service.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/event_model.dart';
import '../../models/organization_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';

class EventsOngsScreen extends StatelessWidget {
  final int initialTab;

  const EventsOngsScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Eventos, ONGs e Voluntários'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mutirões e Eventos'),
              Tab(text: 'ONGs e Voluntários'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EventsTab(),
            _OrganizationsAndVolunteersTab(),
          ],
        ),
      ),
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab();

  static final _dateFmt = DateFormat('dd/MM/yyyy • HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final ong = context.watch<OngController>();
    final user = auth.currentUser;
    final events = ong.events;

    return Scaffold(
      floatingActionButton: auth.isOrganization
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateEventModal(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo evento'),
            )
          : null,
      body: events.isEmpty
          ? EmptyState(
              icon: Icons.event_outlined,
              title: 'Nenhum evento agendado',
              description:
                  'Feiras de adoção, mutirões de alimentação e ações de castração aparecerão aqui.',
              actionLabel: auth.isOrganization ? 'Criar evento' : null,
              onAction: auth.isOrganization
                  ? () => _showCreateEventModal(context)
                  : null,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl * 3,
              ),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final event = events[index];
                final signups = ong.signupsForEvent(event.id);
                final isSignedUp =
                    user != null && ong.isUserSignedUp(event.id, user.id);
                final remaining = (event.capacity - signups.length).clamp(0, 999);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              event.type.icon,
                              size: 24,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                event.title,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${event.type.label} • ${_dateFmt.format(event.startsAt)}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event.address} — ${event.city}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(event.description, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${signups.length}/${event.capacity} inscritos ($remaining vagas)',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (auth.isOrganization && signups.isNotEmpty)
                              TextButton.icon(
                                onPressed: () async {
                                  final csv =
                                      ReportExportService.buildEventSignupsCsv(
                                    event,
                                    signups,
                                  );
                                  await ReportExportService.shareFileBytes(
                                    bytes: Uint8List.fromList(utf8.encode(csv)),
                                    filename: 'inscritos_${event.id}.csv',
                                    mimeType: 'text/csv',
                                    text: 'Lista de inscritos: ${event.title}',
                                  );
                                },
                                icon: const Icon(Icons.download_outlined),
                                label: const Text('CSV'),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (isSignedUp)
                          OutlinedButton.icon(
                            onPressed: () {
                              ong.toggleEventSignup(
                                eventId: event.id,
                                userId: user.id,
                                userName: user.name,
                                phone: user.phone,
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline_rounded),
                            label: const Text('Inscrito — Cancelar inscrição'),
                          )
                        else
                          FilledButton.icon(
                            onPressed: remaining == 0 || user == null
                                ? null
                                : () async {
                                    await ong.toggleEventSignup(
                                      eventId: event.id,
                                      userId: user.id,
                                      userName: user.name,
                                      phone: user.phone,
                                    );
                                    await NotificationService.instance
                                        .showReminder(
                                      id: event.id.hashCode.abs() % 100000,
                                      title: 'Inscrição confirmada!',
                                      body:
                                          '${event.title} em ${_dateFmt.format(event.startsAt)}',
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Inscrição confirmada no evento!',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.event_available_outlined),
                            label: Text(
                              remaining == 0 ? 'Vagas esgotadas' : 'Inscrever-se',
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

  void _showCreateEventModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final capCtrl = TextEditingController(text: '20');
    EventType type = EventType.mutirao;

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
                'Novo evento ou mutirão',
                style: Theme.of(sheetCtx).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Título do evento'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final t in EventType.values)
                    ChoiceChip(
                      label: Text(t.label),
                      selected: type == t,
                      onSelected: (_) => setModal(() => type = t),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Endereço / Local'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: capCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Vagas'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) return;
                  final auth = context.read<AuthController>();
                  await context.read<OngController>().saveEvent(
                        CommunityEventModel(
                          id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
                          organizationId:
                              auth.currentUser?.organizationId ?? 'org_apad_demo',
                          title: titleCtrl.text.trim(),
                          type: type,
                          description: descCtrl.text.trim().isEmpty
                              ? 'Ação comunitária organizada pelo RedePatas.'
                              : descCtrl.text.trim(),
                          city: auth.currentUser?.defaultCity ?? 'Rio do Sul',
                          address: addressCtrl.text.trim().isEmpty
                              ? 'Centro'
                              : addressCtrl.text.trim(),
                          startsAt: DateTime.now().add(const Duration(days: 5)),
                          capacity: int.tryParse(capCtrl.text.trim()) ?? 20,
                          createdAt: DateTime.now(),
                        ),
                      );
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                },
                child: const Text('Publicar evento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrganizationsAndVolunteersTab extends StatelessWidget {
  const _OrganizationsAndVolunteersTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final ong = context.watch<OngController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl * 3,
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeader(title: 'ONGs e protetores da região'),
            TextButton.icon(
              onPressed: () => _showRegisterOrgModal(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Cadastrar ONG'),
            ),
          ],
        ),
        for (final org in ong.organizations) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          org.name,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (org.verified)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 18,
                              color: theme.colorScheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verificada',
                              style: TextStyle(
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(org.city, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(org.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (org.whatsapp != null && org.whatsapp!.isNotEmpty)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () async {
                            final digits =
                                org.whatsapp!.replaceAll(RegExp(r'\D'), '');
                            await launchUrl(
                              Uri.parse('https://wa.me/55$digits'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          icon: const Icon(Icons.chat_outlined, size: 18),
                          label: const Text('WhatsApp'),
                        ),
                      if (org.pixKey != null && org.pixKey!.isNotEmpty)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: org.pixKey!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Chave Pix copiada: ${org.pixKey}'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.pix_outlined, size: 18),
                          label: const Text('Copiar Pix'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeader(title: 'Voluntários cadastrados'),
            TextButton.icon(
              onPressed: () => _showVolunteerProfileModal(context, auth, ong),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Meu perfil voluntário'),
            ),
          ],
        ),
        for (final vol in ong.volunteers) ...[
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainer,
                child: Icon(
                  Icons.volunteer_activism_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(vol.userName ?? 'Voluntário'),
              subtitle: Text(
                '${vol.skills.join(" • ")}\n'
                '${vol.availability.join(", ")}${vol.hasVehicle ? " • Possui veículo" : ""} • Raio ${vol.radiusKm} km',
              ),
              isThreeLine: true,
              trailing: vol.userPhone != null && vol.userPhone!.isNotEmpty
                  ? IconButton(
                      tooltip: 'Chamar no WhatsApp',
                      icon: const Icon(Icons.chat_outlined),
                      onPressed: () async {
                        final digits =
                            vol.userPhone!.replaceAll(RegExp(r'\D'), '');
                        await launchUrl(
                          Uri.parse(
                            'https://wa.me/55$digits?text=${Uri.encodeComponent("Olá! Precisamos de apoio voluntário no RedePatas.")}',
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }

  void _showRegisterOrgModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final whatsCtrl = TextEditingController();
    final pixCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => SingleChildScrollView(
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
              'Cadastrar ONG / Coletivo',
              style: Theme.of(sheetCtx).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome da organização'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descrição da atuação'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: whatsCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'WhatsApp'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: pixCtrl,
              decoration: const InputDecoration(labelText: 'Chave Pix (opcional)'),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final city =
                    context.read<AuthController>().currentUser?.defaultCity ??
                        'Rio do Sul';
                await context.read<OngController>().saveOrganization(
                      OrganizationModel(
                        id: 'org_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim().isEmpty
                            ? 'Organização dedicada ao bem-estar animal.'
                            : descCtrl.text.trim(),
                        city: city,
                        whatsapp: whatsCtrl.text.trim(),
                        pixKey: pixCtrl.text.trim().isEmpty
                            ? null
                            : pixCtrl.text.trim(),
                        createdAt: DateTime.now(),
                      ),
                    );
                if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
              },
              child: const Text('Salvar organização'),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolunteerProfileModal(
    BuildContext context,
    AuthController auth,
    OngController ong,
  ) {
    final user = auth.currentUser;
    if (user == null) return;
    final existing = ong.getVolunteerByUserId(user.id);
    final selectedSkills =
        Set<String>.from(existing?.skills ?? ['Alimentação']);
    final selectedShifts =
        Set<String>.from(existing?.availability ?? ['Fins de semana']);
    bool hasVehicle = existing?.hasVehicle ?? false;
    double radiusKm = (existing?.radiusKm ?? 10).toDouble();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModal) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Perfil de Voluntário',
                style: Theme.of(sheetCtx).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Como você pode ajudar?',
                  style: Theme.of(sheetCtx).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final skill in VolunteerProfileModel.availableSkills)
                    FilterChip(
                      label: Text(skill),
                      selected: selectedSkills.contains(skill),
                      onSelected: (sel) => setModal(() {
                        if (sel) {
                          selectedSkills.add(skill);
                        } else {
                          selectedSkills.remove(skill);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Disponibilidade',
                  style: Theme.of(sheetCtx).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final shift in VolunteerProfileModel.availableShifts)
                    FilterChip(
                      label: Text(shift),
                      selected: selectedShifts.contains(shift),
                      onSelected: (sel) => setModal(() {
                        if (sel) {
                          selectedShifts.add(shift);
                        } else {
                          selectedShifts.remove(shift);
                        }
                      }),
                    ),
                ],
              ),
              SwitchListTile(
                title: const Text('Possuo veículo para transporte'),
                value: hasVehicle,
                onChanged: (v) => setModal(() => hasVehicle = v),
              ),
              Text('Raio de atuação: ${radiusKm.round()} km'),
              Slider(
                min: 2,
                max: 50,
                divisions: 24,
                value: radiusKm,
                onChanged: (v) => setModal(() => radiusKm = v),
              ),
              FilledButton(
                onPressed: () async {
                  await ong.saveVolunteer(
                    VolunteerProfileModel(
                      id: existing?.id ?? 'vol_${user.id}',
                      userId: user.id,
                      userName: user.name,
                      userPhone: user.phone,
                      skills: selectedSkills.toList(),
                      availability: selectedShifts.toList(),
                      hasVehicle: hasVehicle,
                      radiusKm: radiusKm.round(),
                      createdAt: existing?.createdAt ?? DateTime.now(),
                    ),
                  );
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                },
                child: const Text('Salvar perfil voluntário'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
