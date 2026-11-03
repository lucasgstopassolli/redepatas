import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final illustrationBg =
        isDark ? AppTheme.darkSurfaceContainer : AppTheme.lightSurfaceContainer;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho em terracota
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurface
                    : AppTheme.terracottaPrimary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RedePatas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Juntos pelos animais da comunidade',
                          style: TextStyle(
                            color: Color(0xFFFDE8DF),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo central rolável
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  children: [
                    // Ilustração central em container arredondado cor areia suave
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 34,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: illustrationBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkOutline
                              : AppTheme.lightOutline,
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '🐕',
                                  style: TextStyle(fontSize: 64),
                                ),
                              ),
                              Positioned(
                                right: -6,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.pets_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: const [
                              _WelcomePill(emoji: '💧', label: 'Água'),
                              _WelcomePill(emoji: '🥣', label: 'Alimento'),
                              _WelcomePill(emoji: '🏠', label: 'Abrigo'),
                              _WelcomePill(emoji: '🩺', label: 'Socorro'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Toda ajuda conta.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Encontre animais que precisam de água, alimento ou abrigo em Rio do Sul e no Alto Vale do Itajaí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.5,
                        height: 1.45,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botão primário: Entrar
                    FilledButton.icon(
                      onPressed: () => _showAuthSheet(context, isSignUp: false),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Entrar'),
                    ),
                    const SizedBox(height: 12),

                    // Botão secundário: Criar conta
                    OutlinedButton.icon(
                      onPressed: () => _showAuthSheet(context, isSignUp: true),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Criar conta'),
                    ),
                    const SizedBox(height: 14),

                    // Botão discreto para apresentação em sala de aula
                    TextButton.icon(
                      onPressed: () {
                        context.read<AuthController>().signInAsDemo();
                      },
                      icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                      label: const Text(
                        'Entrar como Visitante / Demonstração',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSignUp ? 'Criar conta comunitária' : 'Entrar no RedePatas',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isSignUp
                      ? 'Cadastre seus dados básicos para publicar pedidos ou ajudar animais.'
                      : 'Informe seu nome e e-mail para acessar os pedidos da comunidade.',
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Seu nome',
                    hintText: 'Ex: Lucas Gabriel ou Ariel Jahn',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Informe seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'seuemail@exemplo.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Informe seu e-mail';
                    }
                    return null;
                  },
                ),
                if (isSignUp) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp / Telefone (opcional)',
                      hintText: 'Ex: 47999112233',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cityController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Cidade padrão',
                      hintText: 'Rio do Sul',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
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
  }
}

class _WelcomePill extends StatelessWidget {
  final String emoji;
  final String label;

  const _WelcomePill({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
