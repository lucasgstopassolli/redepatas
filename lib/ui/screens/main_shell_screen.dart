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

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeRequestsScreen(onNewRequestTap: () => _navigateToTab(2)),
      const SearchRequestsScreen(),
      NewRequestScreen(
        onRequestCreated: () => _navigateToTab(0),
      ),
      const MyActionsScreen(),
      const ProfileGuideScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _FloatingPillNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
      ),
    );
  }
}

class _FloatingPillNavigationBar extends StatelessWidget {
  // Geometria concêntrica exata:
  // Diâmetro do círculo interno = 48px (raio = 24px)
  // Padding interno uniforme em todos os lados = 8px
  // Borda = 1px
  // Altura total da barra = 48 + (8 * 2) + (1 * 2) = 66px
  // Raio da pílula externa = 66 / 2 = 33px (24 + 8 + 1 = 33px)
  static const double _itemDiameter = 48.0;
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
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
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
                    color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircularNavItem(
                    dimension: _itemDiameter,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    tooltip: 'Início',
                    isSelected: selectedIndex == 0,
                    onTap: () => onDestinationSelected(0),
                  ),
                  _CircularNavItem(
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
                  _CircularNavItem(
                    dimension: _itemDiameter,
                    icon: Icons.list_alt_outlined,
                    selectedIcon: Icons.list_alt_rounded,
                    tooltip: 'Pedidos',
                    isSelected: selectedIndex == 3,
                    onTap: () => onDestinationSelected(3),
                  ),
                  _CircularNavItem(
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

class _CircularNavItem extends StatelessWidget {
  final double dimension;
  final IconData icon;
  final IconData selectedIcon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _CircularNavItem({
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
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final activeColor = theme.colorScheme.primary;

    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: dimension,
        child: Material(
          color: isSelected
              ? theme.colorScheme.surfaceContainer
              : Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(
              child: Icon(
                isSelected ? selectedIcon : icon,
                size: 22,
                color: isSelected ? activeColor : secondaryTextColor,
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
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isSelected
        ? theme.colorScheme.onSurface
        : theme.colorScheme.primary;
    final fgColor = isSelected
        ? theme.colorScheme.surface
        : (isDark ? AppTheme.darkBackground : Colors.white);

    return Tooltip(
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
                size: 24,
                color: fgColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
