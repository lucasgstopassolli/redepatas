import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/request_card.dart';
import 'abuse_report_screen.dart';
import 'adoption_screen.dart';
import 'campaigns_screen.dart';
import 'events_ongs_screen.dart';
import 'org_dashboard_screen.dart';
import 'request_detail_screen.dart';
import 'requests_map_screen.dart';

enum _HomeViewMode { list, map }

class HomeRequestsScreen extends StatefulWidget {
  final VoidCallback? onNewRequestTap;

  const HomeRequestsScreen({super.key, this.onNewRequestTap});

  @override
  State<HomeRequestsScreen> createState() => _HomeRequestsScreenState();
}

class _HomeRequestsScreenState extends State<HomeRequestsScreen> {
  _HomeViewMode _viewMode = _HomeViewMode.list;
  bool _sortByNearest = false;
  LocationPoint? _userLocation;
  bool _loadingLocation = false;

  Future<void> _toggleNearMe(bool enable) async {
    if (!enable) {
      setState(() => _sortByNearest = false);
      return;
    }
    setState(() => _loadingLocation = true);
    final (point, error) = await LocationService().getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _loadingLocation = false;
      _userLocation = point ?? LocationService.rioDoSulCenter;
      _sortByNearest = true;
    });
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$error Usando o centro de Rio do Sul como referência.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HelpRequestController>();
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final all = controller.allRequests;
    final openTotal = all.where((r) => r.status == RequestStatus.open).length;
    final urgentTotal = all
        .where(
          (r) =>
              r.status != RequestStatus.completed &&
              (r.urgency != UrgencyLevel.normal ||
                  r.needs.contains(NeedType.medical)),
        )
        .length;
    final completedTotal =
        all.where((r) => r.status == RequestStatus.completed).length;

    final requests = List<HelpRequestModel>.from(controller.filteredRequests);
    if (_sortByNearest && _userLocation != null) {
      requests.sort((a, b) {
        final dA = a.hasCoordinates
            ? LocationService.distanceKm(
                _userLocation!.latitude,
                _userLocation!.longitude,
                a.latitude!,
                a.longitude!,
              )
            : 9999.0;
        final dB = b.hasCoordinates
            ? LocationService.distanceKm(
                _userLocation!.latitude,
                _userLocation!.longitude,
                b.latitude!,
                b.longitude!,
              )
            : 9999.0;
        return dA.compareTo(dB);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('RedePatas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: InkWell(
              onTap: () => _showCityFilterModal(context, controller),
              borderRadius: AppRadius.pillRadius,
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: AppRadius.pillRadius,
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.selectedCityFilter ?? 'Rio do Sul e região',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _viewMode == _HomeViewMode.map
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _buildViewToggle(),
                ),
                Expanded(
                  child: RequestsMapScreen(requests: requests),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: controller.loadRequests,
              child: CustomScrollView(
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
                          // Resumo da região
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Resumo da região',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      if (auth.isOrganization)
                                        TextButton.icon(
                                          onPressed: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  const OrgDashboardScreen(),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.analytics_outlined,
                                            size: 18,
                                          ),
                                          label: const Text('Painel ONG'),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SummaryPill(
                                          value: '$openTotal',
                                          label: 'Abertos',
                                          color: semantic.statusOpenFg,
                                          bg: semantic.statusOpenBg,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: _SummaryPill(
                                          value: '$urgentTotal',
                                          label: 'Urgentes',
                                          color: semantic.urgencyCriticalFg,
                                          bg: semantic.urgencyCriticalBg,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: _SummaryPill(
                                          value: '$completedTotal',
                                          label: 'Concluídos',
                                          color: semantic.statusCompletedFg,
                                          bg: semantic.statusCompletedBg,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Atalhos rápidos da rede (ONGs, Adoção, Mutirões, Doações, Denúncia)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _ShortcutChip(
                                  icon: Icons.analytics_outlined,
                                  label: 'Painel ONG',
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const OrgDashboardScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _ShortcutChip(
                                  icon: Icons.pets_outlined,
                                  label: 'Adoção',
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const AdoptionScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _ShortcutChip(
                                  icon: Icons.event_outlined,
                                  label: 'Mutirões',
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const EventsOngsScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _ShortcutChip(
                                  icon: Icons.volunteer_activism_outlined,
                                  label: 'Doações Pix',
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const CampaignsScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _ShortcutChip(
                                  icon: Icons.gavel_outlined,
                                  label: 'Denunciar',
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const AbuseReportScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Alternância Lista / Mapa
                          _buildViewToggle(),
                          const SizedBox(height: AppSpacing.sm),

                          // Filtros por categoria + Perto de mim + Concluídos
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final category
                                    in HomeFilterCategory.values)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.xs,
                                    ),
                                    child: FilterChip(
                                      avatar: Icon(category.icon, size: 18),
                                      label: Text(
                                        category == HomeFilterCategory.urgent &&
                                                urgentTotal > 0
                                            ? '${category.label} ($urgentTotal)'
                                            : category.label,
                                      ),
                                      selected: controller.selectedCategory ==
                                          category,
                                      onSelected: (_) =>
                                          controller.setCategory(category),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.xs,
                                  ),
                                  child: FilterChip(
                                    avatar: _loadingLocation
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.near_me_outlined,
                                            size: 18,
                                          ),
                                    label: const Text('Perto de mim'),
                                    selected: _sortByNearest,
                                    onSelected: _toggleNearMe,
                                  ),
                                ),
                                FilterChip(
                                  avatar: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Concluídos'),
                                  selected: controller.showCompletedInHome,
                                  onSelected:
                                      controller.toggleShowCompletedInHome,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${requests.length} ${requests.length == 1 ? "pedido" : "pedidos"}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (controller.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (requests.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.search_off_outlined,
                        title: 'Nenhum pedido encontrado',
                        description:
                            'Viu um animal precisando de água, alimento ou abrigo? Registre em 1 minuto ou ajuste os filtros.',
                        actionLabel: widget.onNewRequestTap != null
                            ? 'Solicitar ajuda para um animal'
                            : null,
                        onAction: widget.onNewRequestTap,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.xl * 4,
                      ),
                      sliver: SliverList.separated(
                        itemCount: requests.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final req = requests[index];
                          String? distLabel;
                          if (_sortByNearest &&
                              _userLocation != null &&
                              req.hasCoordinates) {
                            distLabel = LocationService.formatDistance(
                              LocationService.distanceKm(
                                _userLocation!.latitude,
                                _userLocation!.longitude,
                                req.latitude!,
                                req.longitude!,
                              ),
                            );
                          }
                          return RequestCard(
                            request: req,
                            distanceLabel: distLabel,
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
            ),
    );
  }

  Widget _buildViewToggle() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<_HomeViewMode>(
        segments: const [
          ButtonSegment(
            value: _HomeViewMode.list,
            icon: Icon(Icons.view_list_outlined),
            label: Text('Lista'),
          ),
          ButtonSegment(
            value: _HomeViewMode.map,
            icon: Icon(Icons.map_outlined),
            label: Text('Mapa'),
          ),
        ],
        selected: {_viewMode},
        onSelectionChanged: (sel) => setState(() => _viewMode = sel.first),
      ),
    );
  }

  void _showCityFilterModal(
    BuildContext context,
    HelpRequestController controller,
  ) {
    final cities = controller.availableCities;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.dialog),
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
                  'Filtrar por cidade',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ListTile(
                leading: const Icon(Icons.public_outlined, size: 22),
                title: const Text('Rio do Sul e toda a região (Todas)'),
                trailing: controller.selectedCityFilter == null
                    ? Icon(
                        Icons.check_rounded,
                        size: 22,
                        color: Theme.of(sheetContext).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  controller.setCityFilter(null);
                  Navigator.of(sheetContext).pop();
                },
              ),
              for (final city in cities)
                ListTile(
                  leading: const Icon(Icons.location_city_outlined, size: 22),
                  title: Text(city),
                  trailing: controller.selectedCityFilter == city
                      ? Icon(
                          Icons.check_rounded,
                          size: 22,
                          color: Theme.of(sheetContext).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    controller.setCityFilter(city);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const _SummaryPill({
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.controlRadius,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, size: 18, color: theme.colorScheme.primary),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
