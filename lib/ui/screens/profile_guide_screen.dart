import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';

class ProfileGuideScreen extends StatelessWidget {
  const ProfileGuideScreen({super.key});

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
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Sair / Trocar conta',
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Bloco 1: Perfil do Cidadão/Voluntário
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.16),
                        child: Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Voluntário Comunitário',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '📍 ${user?.defaultCity ?? "Rio do Sul"} - SC',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13.5,
                              ),
                            ),
                            if (user?.phone != null)
                              Text(
                                '📱 ${user!.phone}',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Editar perfil',
                        onPressed: () => _showEditProfileModal(context, auth),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceContainer
                          : AppTheme.lightSurfaceContainer,
                      borderRadius: BorderRadius.circular(12),
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
                          height: 28,
                          color: isDark
                              ? AppTheme.darkOutline
                              : AppTheme.lightOutline,
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
          const SizedBox(height: 16),

          // Bloco 2: Aparência do Aplicativo (Seletor de Tema)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tema do Aplicativo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Escolha entre modo Claro, Escuro ou automático do Sistema.',
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('☀️ Claro'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('🌙 Escuro'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('📱 Sistema'),
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
          const SizedBox(height: 16),

          // Bloco 3: Guia Rápido de Abordagem Segura
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Guia Rápido de Abordagem Segura',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const ExpansionTile(
                  leading: Text('💧', style: TextStyle(fontSize: 20)),
                  title: Text(
                    'Como oferecer água e alimento com segurança?',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  childrenPadding: EdgeInsets.fromLTRB(18, 0, 18, 14),
                  children: [
                    Text(
                      '• Utilize potes plásticos limpos e sem bordas cortantes (evite latas abertas).\n'
                      '• Posicione os recipientes em local sombreado e afastado do fluxo de veículos.\n'
                      '• Aproxime-se devagar, sem movimentos bruscos, permitindo que o animal sinta segurança.',
                      style: TextStyle(height: 1.45),
                    ),
                  ],
                ),
                const ExpansionTile(
                  leading: Text('🩺', style: TextStyle(fontSize: 20)),
                  title: Text(
                    'O que fazer se o animal estiver ferido ou acuado?',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  childrenPadding: EdgeInsets.fromLTRB(18, 0, 18, 14),
                  children: [
                    Text(
                      '• Animais com dor podem reagir por medo. Não tente forçar a captura sem guia, toalha grossa ou caixa de transporte.\n'
                      '• Sinalize o pedido no RedePatas com urgência "Crítica" e acione imediatamente os órgãos de resgate ou proteção abaixo.',
                      style: TextStyle(height: 1.45),
                    ),
                  ],
                ),
                const ExpansionTile(
                  leading: Text('🌧️', style: TextStyle(fontSize: 20)),
                  title: Text(
                    'Cuidados em dias de chuva ou frio intenso no Alto Vale',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  childrenPadding: EdgeInsets.fromLTRB(18, 0, 18, 14),
                  children: [
                    Text(
                      '• Em períodos de chuva forte ou cheias em Rio do Sul, priorize abrigar o animal em áreas altas e cobertas.\n'
                      '• Caixas de papelão revestidas com plástico e cobertores secos ajudam a evitar hipotermia.',
                      style: TextStyle(height: 1.45),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bloco 4: Contatos Úteis em Rio do Sul e Região
          Text(
            'Contatos Úteis em Rio do Sul e Região',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const _EmergencyContactCard(
            title: 'APAD Rio do Sul',
            subtitle:
                'Associação Protetora dos Animais Desamparados — Apoio, adoção e orientação.',
            icon: Icons.pets_rounded,
            actionLabel: 'Instagram / Contato',
            url: 'https://www.instagram.com/apadriodosul/',
          ),
          const SizedBox(height: 10),
          const _EmergencyContactCard(
            title: 'Bem-Estar Animal / Prefeitura de Rio do Sul',
            subtitle:
                'Atendimento municipal, denúncias e políticas públicas de proteção animal.',
            icon: Icons.account_balance_outlined,
            actionLabel: 'Ligar (47) 3531-1200',
            url: 'tel:4735311200',
          ),
          const SizedBox(height: 10),
          const _EmergencyContactCard(
            title: 'Corpo de Bombeiros Militar (193)',
            subtitle:
                'Resgate de animais em locais de risco, bueiros, telhados ou enchentes.',
            icon: Icons.local_fire_department_outlined,
            actionLabel: 'Ligar 193',
            url: 'tel:193',
          ),
          const SizedBox(height: 10),
          const _EmergencyContactCard(
            title: 'Polícia Militar / Denúncia de Maus-Tratos (190)',
            subtitle:
                'Abandono e maus-tratos a animais são crimes (Lei Federal nº 9.605/98).',
            icon: Icons.shield_outlined,
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
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Perfil',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'WhatsApp / Telefone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'Cidade base'),
              ),
              const SizedBox(height: 18),
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
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final String url;

  const _EmergencyContactCard({
    required this.title,
    required this.subtitle,
    required this.icon,
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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.sageTertiary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.sageTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: secondaryTextColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: () async {
                final uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
