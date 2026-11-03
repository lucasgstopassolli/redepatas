import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../core/constants/rio_do_sul_bairros.dart';
import '../../core/services/ibge_city_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';
import '../widgets/section_header.dart';

class NewRequestScreen extends StatefulWidget {
  final VoidCallback? onRequestCreated;

  const NewRequestScreen({super.key, this.onRequestCreated});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _customNeighborhoodController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  final IbgeCityService _ibgeService = IbgeCityService();
  final ImagePicker _picker = ImagePicker();

  AnimalSpecies _selectedSpecies = AnimalSpecies.dog;
  final Set<NeedType> _selectedNeeds = {NeedType.food, NeedType.water};
  UrgencyLevel _selectedUrgency = UrgencyLevel.normal;
  String _selectedCity = 'Rio do Sul';
  String _selectedRioDoSulBairro = bairrosRioDoSul.first;
  String? _photoPath;
  bool _isSubmitting = false;

  bool get _isRioDoSul =>
      _selectedCity.trim().toLowerCase() == 'rio do sul';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user?.phone != null && _phoneController.text.isEmpty) {
        _phoneController.text = user!.phone!;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customNeighborhoodController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitar Ajuda',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outline, width: 1),
            ),
          ),
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Publicar pedido'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Novo pedido de apoio',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Informe dados claros para orientar quem puder ajudar.',
                style: TextStyle(color: secondaryTextColor, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 1. Espécie e Identificação
              const SectionHeader(title: 'Animal'),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<AnimalSpecies>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: AnimalSpecies.dog,
                      icon: Icon(Icons.pets_outlined, size: 16),
                      label: Text('Cão'),
                    ),
                    ButtonSegment(
                      value: AnimalSpecies.cat,
                      icon: Icon(Icons.pets_outlined, size: 16),
                      label: Text('Gato'),
                    ),
                    ButtonSegment(
                      value: AnimalSpecies.other,
                      icon: Icon(Icons.cruelty_free_outlined, size: 16),
                      label: Text('Outro'),
                    ),
                  ],
                  selected: {_selectedSpecies},
                  onSelectionChanged: (selection) {
                    setState(() => _selectedSpecies = selection.first);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Identificação do animal *',
                  hintText: 'Ex: Cão caramelo de porte médio, Gata cinza...',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe uma identificação curta para o animal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Tipo de necessidade (Múltipla escolha)
              const SectionHeader(title: 'Necessidades'),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: NeedType.values.map((need) {
                  final isSelected = _selectedNeeds.contains(need);
                  return FilterChip(
                    avatar: Icon(need.icon, size: 16),
                    label: Text(need.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedNeeds.add(need);
                        } else if (_selectedNeeds.length > 1) {
                          _selectedNeeds.remove(need);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Nível de Urgência
              const SectionHeader(title: 'Urgência'),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  ChoiceChip(
                    label: const Text('Normal'),
                    selected: _selectedUrgency == UrgencyLevel.normal,
                    onSelected: (_) =>
                        setState(() => _selectedUrgency = UrgencyLevel.normal),
                  ),
                  ChoiceChip(
                    label: const Text('Alta'),
                    selected: _selectedUrgency == UrgencyLevel.high,
                    onSelected: (_) =>
                        setState(() => _selectedUrgency = UrgencyLevel.high),
                  ),
                  ChoiceChip(
                    label: const Text('Crítica (Risco / Ferido)'),
                    selected: _selectedUrgency == UrgencyLevel.critical,
                    onSelected: (_) => setState(
                      () => _selectedUrgency = UrgencyLevel.critical,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Localização (Rio do Sul + API IBGE)
              const SectionHeader(title: 'Localização'),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
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
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            '$_selectedCity - SC',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _openIbgeCityPicker(context),
                          child: const Text('Trocar cidade'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_isRioDoSul)
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRioDoSulBairro,
                        decoration: const InputDecoration(
                          labelText: 'Bairro em Rio do Sul *',
                        ),
                        items: bairrosRioDoSul
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: Text(b),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedRioDoSulBairro = val);
                          }
                        },
                      )
                    else
                      TextFormField(
                        controller: _customNeighborhoodController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Bairro em $_selectedCity *',
                          hintText: 'Digite o nome do bairro ou localidade',
                        ),
                        validator: (val) {
                          if (!_isRioDoSul &&
                              (val == null || val.trim().isEmpty)) {
                            return 'Informe o bairro';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _referenceController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Ponto de referência *',
                        hintText:
                            'Ex: Próximo à passarela / Em frente à padaria...',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Informe um ponto de referência para encontrar o animal';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. Descrição e Contato
              const SectionHeader(title: 'Situação e Contato'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Detalhes sobre o animal *',
                  hintText:
                      'Ex: Animal sem alimentação, parece dócil mas assustado...',
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Descreva brevemente a situação do animal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Seu WhatsApp para contato (opcional)',
                  hintText: 'Ex: 47999112233',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 6. Foto do animal (opcional)
              const SectionHeader(title: 'Fotografia (opcional)'),
              InkWell(
                onTap: () => _showPhotoSourceSheet(context),
                borderRadius: AppRadius.controlRadius,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: AppRadius.controlRadius,
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: _photoPath != null
                      ? Column(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.controlRadius,
                              child: kIsWeb ||
                                      _photoPath!.startsWith('http') ||
                                      _photoPath!.startsWith('blob:')
                                  ? Image.network(
                                      _photoPath!,
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_photoPath!),
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _showPhotoSourceSheet(context),
                                  icon: const Icon(Icons.refresh_outlined, size: 16),
                                  label: const Text('Trocar foto'),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      setState(() => _photoPath = null),
                                  icon: const Icon(Icons.delete_outline, size: 16),
                                  label: const Text('Remover'),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 28,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Adicionar fotografia (Câmera ou Galeria)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ajuda voluntários na localização do animal.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openIbgeCityPicker(BuildContext context) async {
    final searchController = TextEditingController();
    List<String> allCities = [];
    bool isLoading = true;

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
            if (isLoading && allCities.isEmpty) {
              _ibgeService.fetchSantaCatarinaCities().then((cities) {
                if (sheetContext.mounted) {
                  setModalState(() {
                    allCities = cities;
                    isLoading = false;
                  });
                }
              });
            }

            final query = searchController.text.trim().toLowerCase();
            final filteredCities = allCities
                .where((c) => c.toLowerCase().contains(query))
                .toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.92,
              minChildSize: 0.5,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecionar Município (IBGE - SC)',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Rio do Sul possui bairros cadastrados. Outros municípios de SC são obtidos da API do IBGE.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setModalState(() {}),
                        decoration: const InputDecoration(
                          hintText:
                              'Buscar cidade (ex: Lontras, Ibirama, Taió...)',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.star_outline_rounded, size: 20),
                        title: const Text(
                          'Rio do Sul (Padrão)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        onTap: () {
                          setState(() => _selectedCity = 'Rio do Sul');
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                      const Divider(),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: filteredCities.length,
                                itemBuilder: (_, index) {
                                  final city = filteredCities[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.location_city_outlined,
                                      size: 18,
                                    ),
                                    title: Text(
                                      '$city - SC',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    trailing: _selectedCity == city
                                        ? Icon(
                                            Icons.check_rounded,
                                            size: 18,
                                            color: Theme.of(sheetContext)
                                                .colorScheme
                                                .primary,
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() => _selectedCity = city);
                                      Navigator.of(sheetContext).pop();
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showPhotoSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.control * 2),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined, size: 20),
                  title: const Text('Câmera', style: TextStyle(fontSize: 14)),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, size: 20),
                  title: const Text('Galeria', style: TextStyle(fontSize: 14)),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 82,
      );
      if (picked != null && mounted) {
        setState(() => _photoPath = picked.path);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Câmera/Galeria indisponível neste ambiente. O pedido pode ser publicado sem foto.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthController>();
    final user = auth.currentUser;
    final neighborhood = _isRioDoSul
        ? _selectedRioDoSulBairro
        : _customNeighborhoodController.text.trim();

    final newRequest = HelpRequestModel(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      species: _selectedSpecies,
      needs: _selectedNeeds.toList(),
      urgency: _selectedUrgency,
      city: _selectedCity,
      neighborhood: neighborhood,
      referencePoint: _referenceController.text.trim(),
      description: _descriptionController.text.trim(),
      photoPath: _photoPath,
      status: RequestStatus.open,
      authorId: user?.id ?? 'user_demo',
      authorName: user?.name ?? 'Morador da Comunidade',
      authorPhone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      createdAt: DateTime.now(),
    );

    await context.read<HelpRequestController>().createRequest(newRequest);

    if (!mounted) return;

    _titleController.clear();
    _customNeighborhoodController.clear();
    _referenceController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedSpecies = AnimalSpecies.dog;
      _selectedNeeds
        ..clear()
        ..addAll([NeedType.food, NeedType.water]);
      _selectedUrgency = UrgencyLevel.normal;
      _photoPath = null;
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pedido publicado com sucesso no Mural Comunitário!'),
      ),
    );

    widget.onRequestCreated?.call();
  }
}
