import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/help_request_controller.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';

class HomeRequestsScreen extends StatefulWidget {
  final VoidCallback? onNewRequestTap;

  const HomeRequestsScreen({super.key, this.onNewRequestTap});

  @override
  State<HomeRequestsScreen> createState() => _HomeRequestsScreenState();
}

class _HomeRequestsScreenState extends State<HomeRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RedePatas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: () => _showCityFilterModal(context, controller),
              borderRadius: BorderRadius.circular(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.selectedCityFilter == null
                        ? '📍 Rio do Sul e região'
                        : '📍 ${controller.selectedCityFilter}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? AppTheme.darkSecondaryText
                          : Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 18,
                    color: isDark
                        ? AppTheme.darkSecondaryText
                        : Colors.white.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets_rounded, size: 22),
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
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como você quer ajudar?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pedidos de apoio da comunidade',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: controller.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Buscar por bairro, animal ou necessidade',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: controller.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  controller.setSearchQuery('');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final category in HomeFilterCategory.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category.label),
                                selected:
                                    controller.selectedCategory == category,
                                onSelected: (_) =>
                                    controller.setCategory(category),
                              ),
                            ),
                          FilterChip(
                            label: const Text('✓ Concluídos'),
                            selected: controller.showCompletedInHome,
                            onSelected: controller.toggleShowCompletedInHome,
                          ),
                        ],
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
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets_outlined,
                        size: 56,
                        color: secondaryTextColor.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum pedido encontrado com esses filtros.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tente limpar a busca ou registre um novo pedido de ajuda para um animal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      if (widget.onNewRequestTap != null) ...[
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: widget.onNewRequestTap,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: const Text('Solicitar ajuda para um animal'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList.separated(
                  itemCount: requests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
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
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Filtrar por cidade',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.public_rounded),
                title: const Text('Rio do Sul e toda a região (Todas)'),
                trailing: controller.selectedCityFilter == null
                    ? Icon(
                        Icons.check_circle_rounded,
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
                  leading: const Icon(Icons.location_city_rounded),
                  title: Text(city),
                  trailing: controller.selectedCityFilter == city
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(sheetContext).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    controller.setCityFilter(city);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
