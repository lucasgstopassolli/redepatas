import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../widgets/section_header.dart';
import 'my_actions_screen.dart';

class ProfileGuideScreen extends StatelessWidget {
  const ProfileGuideScreen({super.key});

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'RP';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final requestsController = context.watch<HelpRequestController>();
    final themeController = context.watch<ThemeController>();
    final user = auth.currentUser;
    final userId = user?.id ?? 'user_demo';

    final createdCount = requestsController.myCreatedRequests(userId).length;
    final helpedCount = requestsController.myHelpingRequests(userId).length;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guia & Minha Área',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sair / Trocar conta',
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout_outlined, size: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl * 3.5,
        ),
        children: [
          // Bloco 1: Perfil do Cidadão/Voluntário
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _getInitials(user?.name ?? 'VC'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Voluntário Comunitário',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.place_outlined,
                                  size: 13,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${user?.defaultCity ?? "Rio do Sul"} - SC',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            if (user?.phone != null &&
                                user!.phone!.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 15,
                                    color: secondaryTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.phone!,
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Editar perfil',
                        onPressed: () => _showEditProfileModal(context, auth),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MyActionsScreen(),
                        ),
                      );
                    },
                    borderRadius: AppRadius.controlRadius,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: AppRadius.controlRadius,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                count: createdCount.toString(),
                                label: 'pedidos criados',
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: theme.colorScheme.outline,
                              ),
                              _StatItem(
                                count: helpedCount.toString(),
                                label: 'animais ajudados',
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const Divider(),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ver meus pedidos e ações',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Bloco 2: Aparência do Aplicativo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema do Aplicativo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Escolha entre tema claro, escuro ou sincronizado com o sistema.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _ThemeOptionCard(
                          label: 'Claro',
                          icon: Icons.light_mode_outlined,
                          selected: themeController.themeMode == ThemeMode.light,
                          onTap: () =>
                              themeController.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _ThemeOptionCard(
                          label: 'Escuro',
                          icon: Icons.dark_mode_outlined,
                          selected: themeController.themeMode == ThemeMode.dark,
                          onTap: () =>
                              themeController.setThemeMode(ThemeMode.dark),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _ThemeOptionCard(
                          label: 'Sistema',
                          icon: Icons.settings_suggest_outlined,
                          selected:
                              themeController.themeMode == ThemeMode.system,
                          onTap: () =>
                              themeController.setThemeMode(ThemeMode.system),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Bloco 3: Guia Rápido de Abordagem Segura
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: SectionHeader(title: 'Guia de Abordagem Segura'),
                ),
                const ExpansionTile(
                  leading: Icon(Icons.water_drop_outlined, size: 20),
                  title: Text(
                    'Como oferecer água e alimento com segurança?',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  childrenPadding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  children: [
                    Text(
                      '• Utilize potes plásticos limpos e sem bordas cortantes (evite latas abertas).\n'
                      '• Posicione os recipientes em local sombreado e afastado do fluxo de veículos.\n'
                      '• Aproxime-se devagar, sem movimentos bruscos, permitindo que o animal sinta segurança.',
                      style: TextStyle(height: 1.45, fontSize: 15),
                    ),
                  ],
                ),
                const Divider(),
                const ExpansionTile(
                  leading: Icon(Icons.medical_services_outlined, size: 20),
                  title: Text(
                    'O que fazer se o animal estiver ferido ou acuado?',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  childrenPadding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  children: [
                    Text(
                      '• Animais com dor podem reagir por medo. Não tente forçar a captura sem guia, toalha grossa ou caixa de transporte.\n'
                      '• Sinalize o pedido no RedePatas com urgência "Crítica" e acione imediatamente os órgãos de resgate ou proteção abaixo.',
                      style: TextStyle(height: 1.45, fontSize: 15),
                    ),
                  ],
                ),
                const Divider(),
                const ExpansionTile(
                  leading: Icon(Icons.umbrella_outlined, size: 20),
                  title: Text(
                    'Cuidados em dias de chuva ou frio no Alto Vale',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  childrenPadding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  children: [
                    Text(
                      '• Em períodos de chuva forte ou cheias em Rio do Sul, priorize abrigar o animal em áreas altas e cobertas.\n'
                      '• Caixas de papelão revestidas com plástico e cobertores secos ajudam a evitar hipotermia.',
                      style: TextStyle(height: 1.45, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Bloco 4: Contatos Úteis
          const SectionHeader(title: 'Contatos Úteis em Rio do Sul e Região'),
          const SizedBox(height: AppSpacing.xs),
          const _EmergencyContactCard(
            title: 'APAD Rio do Sul',
            subtitle:
                'Associação Protetora dos Animais Desamparados — Apoio, adoção e orientação.',
            actionLabel: 'Instagram',
            url: 'https://www.instagram.com/apadriodosul/',
          ),
          const SizedBox(height: AppSpacing.xs),
          const _EmergencyContactCard(
            title: 'Bem-Estar Animal / Prefeitura',
            subtitle:
                'Atendimento municipal, denúncias e políticas de proteção animal.',
            actionLabel: 'Ligar',
            url: 'tel:4735311200',
          ),
          const SizedBox(height: AppSpacing.xs),
          const _EmergencyContactCard(
            title: 'Corpo de Bombeiros Militar (193)',
            subtitle:
                'Resgate de animais em locais de risco, bueiros, telhados ou cheias.',
            actionLabel: 'Ligar 193',
            url: 'tel:193',
          ),
          const SizedBox(height: AppSpacing.xs),
          const _EmergencyContactCard(
            title: 'Polícia Militar Ambiental',
            subtitle:
                'Fiscalização e denúncias de maus-tratos ou abandono (Lei 9.605/98).',
            actionLabel: 'Ligar 190',
            url: 'tel:190',
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, AuthController auth) {
    final user = auth.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final cityCtrl =
        TextEditingController(text: user?.defaultCity ?? 'Rio do Sul');

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
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Editar Perfil',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'WhatsApp / Telefone'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'Cidade base'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  auth.updateProfile(
                    name: nameCtrl.text,
                    phone: phoneCtrl.text,
                    defaultCity: cityCtrl.text.trim().isEmpty
                        ? 'Rio do Sul'
                        : cityCtrl.text.trim(),
                  );
                  Navigator.of(sheetContext).pop();
                },
                child: const Text('Salvar alterações'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.darkSecondaryText
        : AppTheme.lightSecondaryText;

    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: secondaryTextColor),
        ),
      ],
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final String url;

  const _EmergencyContactCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.call_outlined,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            OutlinedButton(
              onPressed: () async {
                final uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppSizes.tapMin),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: 'Tema $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.controlRadius,
          child: AnimatedContainer(
            duration: AppMotion.duration(context, const Duration(milliseconds: 200)),
            curve: AppMotion.curve,
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.surfaceContainer
                  : theme.colorScheme.surface,
              borderRadius: AppRadius.controlRadius,
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
