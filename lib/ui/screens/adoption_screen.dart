import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/ong_controller.dart';
import '../../core/services/report_export_service.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';
import '../../models/shelter_animal_model.dart';
import '../widgets/empty_state.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  AnimalStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final ong = context.watch<OngController>();

    final animals = _statusFilter == null
        ? ong.shelterAnimals
        : ong.shelterAnimals.where((a) => a.status == _statusFilter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Adoção e Acolhidos')),
      floatingActionButton: auth.isOrganization
          ? FloatingActionButton.extended(
              onPressed: () => _showNewAnimalModal(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Cadastrar animal'),
            )
          : null,
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _statusFilter == null,
                  onSelected: (_) => setState(() => _statusFilter = null),
                ),
                const SizedBox(width: AppSpacing.xs),
                for (final st in [
                  AnimalStatus.disponivel,
                  AnimalStatus.larTemporario,
                  AnimalStatus.adotado,
                ]) ...[
                  FilterChip(
                    label: Text(st.label),
                    selected: _statusFilter == st,
                    onSelected: (_) => setState(() => _statusFilter = st),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
          ),
          Expanded(
            child: animals.isEmpty
                ? EmptyState(
                    icon: Icons.pets_outlined,
                    title: 'Nenhum animal nesta categoria',
                    description:
                        'Ajuste o filtro ou aguarde novos animais acolhidos pelas ONGs da região.',
                    actionLabel:
                        auth.isOrganization ? 'Cadastrar animal' : null,
                    onAction: auth.isOrganization
                        ? () => _showNewAnimalModal(context)
                        : null,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xl * 3,
                    ),
                    itemCount: animals.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      final interests = ong.interestsForAnimal(animal.id);
                      return Card(
                        child: InkWell(
                          borderRadius: AppRadius.controlRadius,
                          onTap: () => _showAnimalDetail(context, animal),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.surfaceContainer,
                                        borderRadius: AppRadius.controlRadius,
                                      ),
                                      child: Icon(
                                        animal.species.icon,
                                        size: 28,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            animal.name,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          Text(
                                            '${animal.species.label} • ${animal.sex} • ${animal.ageGroup} • Porte ${animal.size}',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  animal.description,
                                  style: theme.textTheme.bodyLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    Chip(label: Text(animal.status.label)),
                                    if (animal.vaccinated)
                                      const Chip(label: Text('Vacinado')),
                                    if (animal.castrated)
                                      const Chip(label: Text('Castrado')),
                                    if (auth.isOrganization &&
                                        interests.isNotEmpty)
                                      Chip(
                                        label: Text(
                                          '${interests.length} interessado(s)',
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAnimalDetail(BuildContext context, ShelterAnimalModel animal) {
    final theme = Theme.of(context);
    final auth = context.read<AuthController>();
    final ong = context.read<OngController>();
    final org = ong.getOrganizationById(animal.organizationId);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(animal.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '${animal.species.label} • ${animal.sex} • ${animal.ageGroup} • Porte ${animal.size}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(animal.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Temperamento: ${animal.temperament}\nSaúde: ${animal.health}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(sheetCtx).pop();
                  _showInterestDialog(context, animal, org?.whatsapp);
                },
                icon: const Icon(Icons.favorite_outline_rounded),
                label: Text(
                  animal.status == AnimalStatus.larTemporario
                      ? 'Oferecer lar temporário'
                      : 'Quero adotar ${animal.name}',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () {
                  ReportExportService.shareText(
                    ReportExportService.buildAdoptionShareText(animal),
                    subject: 'Adoção: ${animal.name}',
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartilhar divulgação'),
              ),
              if (auth.isOrganization) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Atualizar status (ONG)',
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final st in AnimalStatus.values)
                      ChoiceChip(
                        label: Text(st.label),
                        selected: animal.status == st,
                        onSelected: (_) async {
                          await ong.saveShelterAnimal(
                            animal.copyWith(status: st),
                          );
                          if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                        },
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showInterestDialog(
    BuildContext context,
    ShelterAnimalModel animal,
    String? orgWhatsapp,
  ) {
    final user = context.read<AuthController>().currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final msgCtrl = TextEditingController(
      text: 'Olá! Tenho interesse em acolher ${animal.name}.',
    );

    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text('Interesse em ${animal.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Seu nome'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Seu WhatsApp'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mensagem'),
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
              await context.read<OngController>().addAdoptionInterest(
                    AdoptionInterestModel(
                      id: 'int_${DateTime.now().millisecondsSinceEpoch}',
                      animalId: animal.id,
                      name: nameCtrl.text.trim().isEmpty
                          ? 'Interessado'
                          : nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      message: msgCtrl.text.trim(),
                      createdAt: DateTime.now(),
                    ),
                  );
              if (dlgCtx.mounted) Navigator.of(dlgCtx).pop();
              if (orgWhatsapp != null && orgWhatsapp.isNotEmpty) {
                final clean = orgWhatsapp.replaceAll(RegExp(r'\D'), '');
                final text = Uri.encodeComponent(msgCtrl.text.trim());
                await launchUrl(
                  Uri.parse('https://wa.me/55$clean?text=$text'),
                  mode: LaunchMode.externalApplication,
                );
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Interesse registrado com sucesso!'),
                  ),
                );
              }
            },
            child: const Text('Enviar interesse'),
          ),
        ],
      ),
    );
  }

  void _showNewAnimalModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    AnimalSpecies species = AnimalSpecies.dog;
    AnimalStatus status = AnimalStatus.disponivel;
    bool vaccinated = true;
    bool castrated = false;

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
                'Cadastrar animal acolhido',
                style: Theme.of(sheetCtx).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome do animal'),
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<AnimalSpecies>(
                segments: const [
                  ButtonSegment(value: AnimalSpecies.dog, label: Text('Cão')),
                  ButtonSegment(value: AnimalSpecies.cat, label: Text('Gato')),
                  ButtonSegment(
                    value: AnimalSpecies.other,
                    label: Text('Outro'),
                  ),
                ],
                selected: {species},
                onSelectionChanged: (s) => setModal(() => species = s.first),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'História e cuidados',
                ),
              ),
              SwitchListTile(
                title: const Text('Vacinado'),
                value: vaccinated,
                onChanged: (v) => setModal(() => vaccinated = v),
              ),
              SwitchListTile(
                title: const Text('Castrado'),
                value: castrated,
                onChanged: (v) => setModal(() => castrated = v),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final orgId = context
                          .read<AuthController>()
                          .currentUser
                          ?.organizationId ??
                      'org_apad_demo';
                  await context.read<OngController>().saveShelterAnimal(
                        ShelterAnimalModel(
                          id: 'ani_${DateTime.now().millisecondsSinceEpoch}',
                          organizationId: orgId,
                          name: nameCtrl.text.trim(),
                          species: species,
                          sex: 'Não informado',
                          ageGroup: 'Adulto',
                          size: 'Médio',
                          temperament: 'Dócil',
                          health: 'Avaliado pela ONG',
                          vaccinated: vaccinated,
                          castrated: castrated,
                          status: status,
                          description: descCtrl.text.trim().isEmpty
                              ? 'Animal acolhido aguardando família responsável.'
                              : descCtrl.text.trim(),
                          createdAt: DateTime.now(),
                        ),
                      );
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                },
                child: const Text('Salvar animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
