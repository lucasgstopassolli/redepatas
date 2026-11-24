import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import 'home_requests_screen.dart';
import 'my_actions_screen.dart';
import 'new_request_screen.dart';
import 'profile_guide_screen.dart';
import 'search_requests_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  final List<bool> _visited = [true, false, false, false, false];

  void _navigateToTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _visited[index] = true;
    });
  }

  Widget _buildTab(int index) {
    if (!_visited[index]) return const SizedBox.shrink();
    return switch (index) {
      0 => HomeRequestsScreen(onNewRequestTap: () => _navigateToTab(2)),
      1 => const SearchRequestsScreen(),
      2 => NewRequestScreen(onRequestCreated: () => _navigateToTab(0)),
      3 => const MyActionsScreen(),
      4 => const ProfileGuideScreen(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(5, _buildTab),
      ),
      bottomNavigationBar: RepaintBoundary(
        child: _FloatingPillNavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigateToTab,
        ),
      ),
    );
  }
}

class _FloatingPillNavigationBar extends StatelessWidget {
  // Geometria concêntrica:
  // Diâmetro do item = 56px (raio = 28px)
  // Padding interno uniforme = 8px
  // Borda = 1px
  // Altura total = 56 + 16 + 2 = 74px -> Raio externo = 37px
  static const double _itemDiameter = AppSizes.navItem;
  static const double _barPadding = 8.0;
  static const double _borderWidth = 1.0;
  static const double _barHeight =
      _itemDiameter + (_barPadding * 2) + (_borderWidth * 2);
  static const double _barRadius = _barHeight / 2;

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _FloatingPillNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              height: _barHeight,
              padding: const EdgeInsets.all(_barPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(_barRadius),
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: _borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: semantic.navShadow,
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PillNavItem(
                    dimension: _itemDiameter,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    tooltip: 'Início',
                    isSelected: selectedIndex == 0,
                    onTap: () => onDestinationSelected(0),
                  ),
                  _PillNavItem(
                    dimension: _itemDiameter,
                    icon: Icons.search_rounded,
                    selectedIcon: Icons.search_rounded,
                    tooltip: 'Buscar',
                    isSelected: selectedIndex == 1,
                    onTap: () => onDestinationSelected(1),
                  ),
                  _CenterCircularActionButton(
                    dimension: _itemDiameter,
                    tooltip: 'Novo',
                    isSelected: selectedIndex == 2,
                    onTap: () => onDestinationSelected(2),
                  ),
                  _PillNavItem(
                    dimension: _itemDiameter,
                    icon: Icons.list_alt_outlined,
                    selectedIcon: Icons.list_alt_rounded,
                    tooltip: 'Pedidos',
                    isSelected: selectedIndex == 3,
                    onTap: () => onDestinationSelected(3),
                  ),
                  _PillNavItem(
                    dimension: _itemDiameter,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    tooltip: 'Minha área',
                    isSelected: selectedIndex == 4,
                    onTap: () => onDestinationSelected(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillNavItem extends StatelessWidget {
  final double dimension;
  final IconData icon;
  final IconData selectedIcon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillNavItem({
    required this.dimension,
    required this.icon,
    required this.selectedIcon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label: tooltip,
      button: true,
      selected: isSelected,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(dimension / 2),
            child: AnimatedContainer(
              duration: AppMotion.duration(context, AppMotion.normal),
              curve: AppMotion.curve,
              height: dimension,
              constraints: BoxConstraints(minWidth: dimension),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 14 : 0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.surfaceContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(dimension / 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? selectedIcon : icon,
                    size: AppSizes.iconLg,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  AnimatedSize(
                    duration: AppMotion.duration(context, AppMotion.normal),
                    curve: AppMotion.curve,
                    child: isSelected
                        ? Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              tooltip,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: activeColor,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterCircularActionButton extends StatelessWidget {
  final double dimension;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterCircularActionButton({
    required this.dimension,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isSelected
        ? theme.colorScheme.onSurface
        : theme.colorScheme.primary;
    final fgColor = isSelected
        ? theme.colorScheme.surface
        : theme.colorScheme.onPrimary;

    return Semantics(
      label: 'Novo pedido',
      button: true,
      selected: isSelected,
      child: Tooltip(
        message: tooltip,
        child: SizedBox.square(
          dimension: dimension,
          child: Material(
            color: bgColor,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 30,
                  color: fgColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
