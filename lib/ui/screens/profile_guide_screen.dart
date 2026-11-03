import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../widgets/section_header.dart';

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
          AppSpacing.xl,
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
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            if (user?.phone != null &&
                                user!.phone!.trim().isNotEmpty) ...[
                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 13,
                                    color: secondaryTextColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    user.phone!,
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 13,
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: AppRadius.controlRadius,
                    ),
                    child: Row(
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
                  const SizedBox(height: 2),
                  Text(
                    'Escolha entre tema claro, escuro ou sincronizado com o sistema.',
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined, size: 16),
                          label: Text('Claro'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined, size: 16),
                          label: Text('Escuro'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.settings_suggest_outlined, size: 16),
                          label: Text('Sistema'),
                        ),
                      ],
                      selected: {themeController.themeMode},
                      onSelectionChanged: (modes) {
                        themeController.setThemeMode(modes.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

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
                      style: TextStyle(height: 1.45, fontSize: 13.5),
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
                      style: TextStyle(height: 1.45, fontSize: 13.5),
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
                      style: TextStyle(height: 1.45, fontSize: 13.5),
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
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      height: 1.3,
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
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
