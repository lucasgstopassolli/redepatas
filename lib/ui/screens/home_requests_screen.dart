import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/help_request_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';

class HomeRequestsScreen extends StatelessWidget {
  final VoidCallback? onNewRequestTap;

  const HomeRequestsScreen({super.key, this.onNewRequestTap});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HelpRequestController>();
    final requests = controller.filteredRequests;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RedePatas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: InkWell(
              onTap: () => _showCityFilterModal(context, controller),
              borderRadius: AppRadius.pillRadius,
              child: Container(
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
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.selectedCityFilter ?? 'Rio do Sul e região',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 16,
                      color: secondaryTextColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final category in HomeFilterCategory.values)
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: AppSpacing.xs),
                              child: FilterChip(
                                avatar: Icon(category.icon, size: 16),
                                label: Text(category.label),
                                selected:
                                    controller.selectedCategory == category,
                                onSelected: (_) =>
                                    controller.setCategory(category),
                              ),
                            ),
                          FilterChip(
                            avatar: const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                            ),
                            label: const Text('Concluídos'),
                            selected: controller.showCompletedInHome,
                            onSelected: controller.toggleShowCompletedInHome,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${requests.length} ${requests.length == 1 ? "pedido" : "pedidos"}',
                      style: theme.textTheme.labelMedium,
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
                      'Tente ajustar o filtro ou registre um novo pedido de apoio para um animal.',
                  action: onNewRequestTap != null
                      ? OutlinedButton.icon(
                          onPressed: onNewRequestTap,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Solicitar ajuda para um animal'),
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
                  itemCount: requests.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final req = requests[index];
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
                  'Filtrar por cidade',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ListTile(
                leading: const Icon(Icons.public_outlined, size: 20),
                title: const Text(
                  'Rio do Sul e toda a região (Todas)',
                  style: TextStyle(fontSize: 14),
                ),
                trailing: controller.selectedCityFilter == null
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
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
                  leading: const Icon(Icons.location_city_outlined, size: 20),
                  title: Text(
                    city,
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: controller.selectedCityFilter == city
                      ? Icon(
                          Icons.check_rounded,
                          size: 20,
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
