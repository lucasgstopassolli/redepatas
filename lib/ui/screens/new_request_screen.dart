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
import '../../models/help_request_model.dart';

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
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Novo pedido de apoio',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Registre informações claras para facilitar o atendimento pela comunidade.',
                style: TextStyle(color: secondaryTextColor, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // 1. Espécie e Identificação
              _SectionTitle('1. Espécie e Identificação do Animal'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<AnimalSpecies>(
                  segments: const [
                    ButtonSegment(
                      value: AnimalSpecies.dog,
                      label: Text('🐕 Cão'),
                    ),
                    ButtonSegment(
                      value: AnimalSpecies.cat,
                      label: Text('🐈 Gato'),
                    ),
                    ButtonSegment(
                      value: AnimalSpecies.other,
                      label: Text('🐾 Outro'),
                    ),
                  ],
                  selected: {_selectedSpecies},
                  onSelectionChanged: (selection) {
                    setState(() => _selectedSpecies = selection.first);
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Identificação do animal *',
                  hintText: 'Ex: Cão caramelo de porte médio, Gata cinza...',
                  prefixIcon: Icon(Icons.pets_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe uma identificação curta para o animal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. Tipo de necessidade (Múltipla escolha)
              _SectionTitle('2. Tipo de necessidade (selecione uma ou mais)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NeedType.values.map((need) {
                  final isSelected = _selectedNeeds.contains(need);
                  return FilterChip(
                    label: Text('${need.emoji} ${need.label}'),
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
              const SizedBox(height: 20),

              // 3. Nível de Urgência
              _SectionTitle('3. Nível de Urgência'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Normal'),
                    selected: _selectedUrgency == UrgencyLevel.normal,
                    onSelected: (_) =>
                        setState(() => _selectedUrgency = UrgencyLevel.normal),
                  ),
                  ChoiceChip(
                    label: const Text('⚠️ Alta'),
                    selected: _selectedUrgency == UrgencyLevel.high,
                    onSelected: (_) =>
                        setState(() => _selectedUrgency = UrgencyLevel.high),
                  ),
                  ChoiceChip(
                    label: const Text('🚨 Crítica (Risco/Ferido)'),
                    selected: _selectedUrgency == UrgencyLevel.critical,
                    onSelected: (_) => setState(
                      () => _selectedUrgency = UrgencyLevel.critical,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Localização (Rio do Sul + API IBGE)
              _SectionTitle('4. Localização (Rio do Sul & Região - IBGE)'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_city_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cidade selecionada',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                Text(
                                  '$_selectedCity - SC',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _openIbgeCityPicker(context),
                            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                            label: const Text('Trocar cidade'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isRioDoSul)
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRioDoSulBairro,
                          decoration: const InputDecoration(
                            labelText: 'Bairro em Rio do Sul *',
                            prefixIcon: Icon(Icons.map_outlined),
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
                            prefixIcon: const Icon(Icons.map_outlined),
                          ),
                          validator: (val) {
                            if (!_isRioDoSul &&
                                (val == null || val.trim().isEmpty)) {
                              return 'Informe o bairro';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _referenceController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Ponto de referência *',
                          hintText:
                              'Ex: Próximo à passarela / Em frente à padaria...',
                          prefixIcon: Icon(Icons.place_outlined),
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
              ),
              const SizedBox(height: 20),

              // 5. Descrição e Contato opcional
              _SectionTitle('5. Descrição da Situação'),
              const SizedBox(height: 8),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Seu WhatsApp para contato (opcional)',
                  hintText: 'Ex: 47999112233',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // 6. Foto do animal (opcional)
              _SectionTitle('6. Fotografia do Animal (opcional)'),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showPhotoSourceSheet(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurfaceContainer
                        : AppTheme.lightSurfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: _photoPath != null && !kIsWeb
                      ? Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_photoPath!),
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _showPhotoSourceSheet(context),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Trocar foto'),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      setState(() => _photoPath = null),
                                  icon: const Icon(Icons.delete_outline_rounded),
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
                              size: 34,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '+ Adicionar fotografia (Câmera ou Galeria)',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Uma foto ajuda voluntários a identificarem o animal e o local com mais rapidez.',
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
              const SizedBox(height: 28),

              // 7. Botão Principal: Publicar pedido
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.publish_rounded),
                label: Text(
                  _isSubmitting ? 'Publicando...' : 'Publicar pedido',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecionar Município (API IBGE - SC)',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Rio do Sul possui bairros pré-cadastrados. Para outros municípios de SC, a lista é carregada da API oficial do IBGE.',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setModalState(() {}),
                        decoration: const InputDecoration(
                          hintText:
                              'Buscar cidade (ex: Lontras, Ibirama, Taió...)',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.star_rounded),
                        title: const Text(
                          'Rio do Sul (Padrão com lista de bairros)',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
                                    ),
                                    title: Text('$city - SC'),
                                    trailing: _selectedCity == city
                                        ? Icon(
                                            Icons.check_circle_rounded,
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
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Tirar foto com a Câmera'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Escolher da Galeria'),
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

    // Reseta o formulário após publicação
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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
