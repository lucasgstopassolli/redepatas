import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_tokens.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const OnboardingScreen({super.key, this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.pets_rounded,
      eyebrow: 'BEM-VINDO AO REDEPATAS',
      title: 'Uma rede comunitária pelos animais de rua',
      description:
          'Conectamos moradores, voluntários e ONGs em Rio do Sul e no Alto Vale do Itajaí para organizar ajuda rápida com água, alimento, abrigo e socorro.',
    ),
    _OnboardingPageData(
      icon: Icons.volunteer_activism_outlined,
      eyebrow: 'COMO FUNCIONA',
      title: 'Registre, assuma e acompanhe cada caso',
      description:
          'Qualquer pessoa pode publicar um pedido com foto e localização. Voluntários ou ONGs assumem o atendimento e atualizam a linha do tempo até o animal estar seguro.',
    ),
    _OnboardingPageData(
      icon: Icons.apartment_outlined,
      eyebrow: 'PARA ONGS E PROTETORES',
      title: 'Gestão completa em um único lugar',
      description:
          'Painel com métricas, relatórios em PDF e CSV, mapa de casos urgentes, vitrine de adoção, mutirões com inscrição e campanhas de doação via Pix.',
    ),
    _OnboardingPageData(
      icon: Icons.health_and_safety_outlined,
      eyebrow: 'SEGURANÇA E TRANSPARÊNCIA',
      title: 'Abordagem segura e privacidade respeitada',
      description:
          'Oferecemos guia rápido de manejo seguro e acesso direto a contatos de emergência (193/190). Câmera e localização só são pedidas quando você escolher usá-las.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      context.read<AuthController>().completeOnboarding();
    }
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppMotion.duration(context, AppMotion.normal),
        curve: AppMotion.curve,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            color: theme.colorScheme.primary,
                            size: 26,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'RedePatas',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _finish,
                        child: const Text('Pular'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainer,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.colorScheme.outline,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    page.icon,
                                    size: 60,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  page.eyebrow,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  page.title,
                                  style: theme.textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  page.description,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final active = index == _currentPage;
                      return AnimatedContainer(
                        duration: AppMotion.duration(context, AppMotion.normal),
                        curve: AppMotion.curve,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: active
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          borderRadius: AppRadius.pillRadius,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _next,
                    icon: Icon(
                      isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    ),
                    label: Text(isLast ? 'Começar agora' : 'Próximo'),
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

class _OnboardingPageData {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
}
