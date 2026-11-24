import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/help_request_controller.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';
import '../../models/user_model.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requests = context.watch<HelpRequestController>().allRequests;
    final openCount =
        requests.where((r) => r.status == RequestStatus.open).length;
    final activeHelpCount = requests
        .where((r) =>
            r.status == RequestStatus.inProgress ||
            r.status == RequestStatus.completed)
        .length;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.controlRadius,
                        child: Image.asset(
                          'assets/icon/icon.png',
                          width: 44,
                          height: 44,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.pets_rounded,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RedePatas',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rio do Sul e Alto Vale do Itajaí',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Conectando quem vê um animal precisando a quem pode ajudar.',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Toda ajuda conta.',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Faixa com 3 números ao vivo animados
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _LiveMetric(
                              value: openCount,
                              label: 'Abertos agora',
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: theme.colorScheme.outline,
                          ),
                          Expanded(
                            child: _LiveMetric(
                              value: activeHelpCount,
                              label: 'Em apoio',
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: theme.colorScheme.outline,
                          ),
                          Expanded(
                            child: _LiveMetric(
                              value: requests.length,
                              label: 'Casos na rede',
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3 benefícios claros
                  const _BenefitRow(
                    icon: Icons.add_location_alt_outlined,
                    title: 'Registre em 1 minuto',
                    subtitle:
                        'Informe água, alimento, abrigo ou socorro com foto e localização.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _BenefitRow(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Acompanhe o resgate',
                    subtitle:
                        'Linha do tempo transparente até o animal estar acolhido.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _BenefitRow(
                    icon: Icons.apartment_outlined,
                    title: 'Feito para ONGs e voluntários',
                    subtitle:
                        'Painel de métricas, adoção, mutirões, campanhas Pix e relatórios.',
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Ações grandes 56dp
                  FilledButton.icon(
                    onPressed: () => _showAuthSheet(context, isSignUp: false),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Entrar'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => _showAuthSheet(context, isSignUp: true),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Criar conta'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<AuthController>()
                          .signInAsDemo(role: UserRole.organization);
                    },
                    icon: const Icon(Icons.apartment_outlined),
                    label: const Text('Ver como ONG (Demonstração)'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<AuthController>().signInAsDemo();
                      },
                      child: const Text('Entrar como Visitante / Demonstração'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAuthSheet(BuildContext context, {required bool isSignUp}) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final cityController = TextEditingController(text: 'Rio do Sul');
    final formKey = GlobalKey<FormState>();
    UserRole selectedRole = UserRole.citizen;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.dialog),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom:
                    MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isSignUp
                          ? 'Criar conta comunitária'
                          : 'Entrar no RedePatas',
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      isSignUp
                          ? 'Cadastre seus dados básicos e escolha como quer participar.'
                          : 'Informe seu nome e e-mail para acessar os pedidos da comunidade.',
                      style: Theme.of(sheetContext).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Seu nome ou nome da ONG',
                        hintText: 'Ex: Lucas Gabriel ou APAD Rio do Sul',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Informe seu nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'seuemail@exemplo.com',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Informe seu e-mail';
                        }
                        return null;
                      },
                    ),
                    if (isSignUp) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'WhatsApp / Telefone (opcional)',
                          hintText: 'Ex: 47999112233',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: cityController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Cidade padrão',
                          hintText: 'Rio do Sul',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Seu papel no RedePatas',
                        style: Theme.of(sheetContext).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final role in UserRole.values)
                            ChoiceChip(
                              avatar: Icon(role.icon, size: 18),
                              label: Text(role.label),
                              selected: selectedRole == role,
                              onSelected: (_) =>
                                  setModalState(() => selectedRole = role),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final defaultCity = cityController.text.trim().isEmpty
                              ? 'Rio do Sul'
                              : cityController.text.trim();
                          context.read<AuthController>().signIn(
                                name: nameController.text,
                                email: emailController.text,
                                phone: phoneController.text,
                                defaultCity: defaultCity,
                                role: selectedRole,
                              );
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      child: Text(isSignUp ? 'Concluir cadastro' : 'Acessar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LiveMetric extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _LiveMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: AppMotion.duration(
            context,
            const Duration(milliseconds: 600),
          ),
          builder: (_, val, _) => Text(
            '$val',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: AppRadius.controlRadius,
          ),
          child: Icon(icon, size: 22, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
