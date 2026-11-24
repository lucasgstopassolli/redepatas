import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/help_request_controller.dart';
import 'controllers/ong_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'core/theme/theme_controller.dart';
import 'repositories/i_help_request_repository.dart';
import 'repositories/i_ong_repository.dart';
import 'repositories/sqlite_help_repository.dart';
import 'repositories/sqlite_ong_repository.dart';
import 'ui/screens/main_shell_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final IHelpRequestRepository repository = SqliteHelpRepository();
  final IOngRepository ongRepository = SqliteOngRepository();

  runApp(
    RedePatasApp(
      repository: repository,
      ongRepository: ongRepository,
    ),
  );
}

class RedePatasApp extends StatelessWidget {
  final IHelpRequestRepository repository;
  final IOngRepository? ongRepository;

  const RedePatasApp({
    super.key,
    required this.repository,
    this.ongRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(
          create: (_) => HelpRequestController(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => OngController(ongRepository ?? SqliteOngRepository()),
        ),
      ],
      child: Selector<ThemeController, ThemeMode>(
        selector: (_, tc) => tc.themeMode,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'RedePatas',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            themeAnimationDuration: AppMotion.normal,
            themeAnimationCurve: AppMotion.curve,
            themeAnimationStyle: const AnimationStyle(
              duration: AppMotion.normal,
              curve: AppMotion.curve,
            ),
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authState = context.select<AuthController, (bool, bool, bool)>(
      (a) => (a.isInitialized, a.onboardingDone, a.isAuthenticated),
    );
    final (isInitialized, onboardingDone, isAuthenticated) = authState;

    final Widget child;
    if (!isInitialized) {
      child = const _SplashScreen(key: ValueKey('splash'));
    } else if (isAuthenticated) {
      child = const MainShellScreen(key: ValueKey('main_shell'));
    } else if (!onboardingDone) {
      child = const OnboardingScreen(key: ValueKey('onboarding'));
    } else {
      child = const WelcomeScreen(key: ValueKey('welcome'));
    }

    return AnimatedSwitcher(
      duration: AppMotion.duration(context, AppMotion.normal),
      switchInCurve: AppMotion.curve,
      switchOutCurve: AppMotion.curve,
      child: child,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icon/icon.png',
                width: 84,
                height: 84,
                errorBuilder: (_, _, _) => Icon(
                  Icons.pets_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'RedePatas',
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
