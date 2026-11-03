import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/help_request_controller.dart';
import '../../core/constants/rio_do_sul_bairros.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/request_card.dart';
import '../widgets/section_header.dart';
import 'request_detail_screen.dart';

class SearchRequestsScreen extends StatefulWidget {
  const SearchRequestsScreen({super.key});

  @override
  State<SearchRequestsScreen> createState() => _SearchRequestsScreenState();
}

class _SearchRequestsScreenState extends State<SearchRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AnimalSpecies? _selectedSpecies;
  NeedType? _selectedNeed;
  UrgencyLevel? _selectedUrgency;
  String? _selectedBairro;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _searchController.text.trim().isNotEmpty ||
      _selectedSpecies != null ||
      _selectedNeed != null ||
      _selectedUrgency != null ||
      _selectedBairro != null;

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSpecies = null;
      _selectedNeed = null;
      _selectedUrgency = null;
      _selectedBairro = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HelpRequestController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    final query = _searchController.text.trim().toLowerCase();
    final results = controller.allRequests.where((req) {
      if (_selectedSpecies != null && req.species != _selectedSpecies) {
        return false;
      }
      if (_selectedNeed != null && !req.needs.contains(_selectedNeed)) {
        return false;
      }
      if (_selectedUrgency != null && req.urgency != _selectedUrgency) {
        return false;
      }
      if (_selectedBairro != null &&
          req.neighborhood.toLowerCase() != _selectedBairro!.toLowerCase()) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchesTitle = req.title.toLowerCase().contains(query);
        final matchesNeighborhood =
            req.neighborhood.toLowerCase().contains(query);
        final matchesCity = req.city.toLowerCase().contains(query);
        final matchesRef = req.referencePoint.toLowerCase().contains(query);
        final matchesDesc = req.description.toLowerCase().contains(query);
        final matchesSpecies = req.species.label.toLowerCase().contains(query);
        final matchesNeeds = req.needs.any(
          (n) => n.label.toLowerCase().contains(query),
        );
        if (!matchesTitle &&
            !matchesNeighborhood &&
            !matchesCity &&
            !matchesRef &&
            !matchesDesc &&
            !matchesSpecies &&
            !matchesNeeds) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar e Filtrar',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                label: const Text('Limpar'),
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'Buscar por bairro, animal, ponto de referência...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Filtro por Espécie e Urgência
                  const SectionHeader(title: 'Espécie e Urgência'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final species in AnimalSpecies.values)
                          Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.xs),
                            child: FilterChip(
                              avatar: Icon(species.icon, size: 16),
                              label: Text(species.label),
                              selected: _selectedSpecies == species,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSpecies = selected ? species : null;
                                });
                              },
                            ),
                          ),
                        for (final urgency in UrgencyLevel.values)
                          Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.xs),
                            child: FilterChip(
                              avatar: const Icon(
                                Icons.priority_high_rounded,
                                size: 15,
                              ),
                              label: Text('Urgência ${urgency.label}'),
                              selected: _selectedUrgency == urgency,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedUrgency = selected ? urgency : null;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Filtro por Necessidade e Bairro
                  const SectionHeader(title: 'Necessidade e Bairro'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: ActionChip(
                            avatar: const Icon(Icons.place_outlined, size: 16),
                            label: Text(_selectedBairro ?? 'Bairro'),
                            backgroundColor: _selectedBairro != null
                                ? theme.colorScheme.surfaceContainer
                                : null,
                            onPressed: () => _showBairroPicker(context),
                          ),
                        ),
                        for (final need in NeedType.values)
                          Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.xs),
                            child: FilterChip(
                              avatar: Icon(need.icon, size: 16),
                              label: Text(need.label),
                              selected: _selectedNeed == need,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedNeed = selected ? need : null;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${results.length} ${results.length == 1 ? "resultado encontrado" : "resultados encontrados"}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_outlined,
                title: 'Nenhum pedido corresponde aos filtros',
                description:
                    'Tente limpar os filtros selecionados ou buscar por outro termo.',
                action: _hasActiveFilters
                    ? OutlinedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Limpar filtros'),
                      )
                    : null,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xl * 3.5,
              ),
              sliver: SliverList.separated(
                itemCount: results.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final req = results[index];
                  return RequestCard(
                    request: req,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              RequestDetailScreen(requestId: req.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showBairroPicker(BuildContext context) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'Filtrar por bairro (Rio do Sul)',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.apps_rounded, size: 20),
                      title: const Text(
                        'Todos os bairros',
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: _selectedBairro == null
                          ? Icon(
                              Icons.check_rounded,
                              size: 20,
                              color:
                                  Theme.of(sheetContext).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedBairro = null);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    for (final bairro in bairrosRioDoSul)
                      ListTile(
                        leading: const Icon(Icons.place_outlined, size: 20),
                        title: Text(
                          bairro,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: _selectedBairro == bairro
                            ? Icon(
                                Icons.check_rounded,
                                size: 20,
                                color:
                                    Theme.of(sheetContext).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedBairro = bairro);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
