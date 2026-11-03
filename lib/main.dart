import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/help_request_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'repositories/i_help_request_repository.dart';
import 'repositories/sqlite_help_repository.dart';
import 'ui/screens/main_shell_screen.dart';
import 'ui/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Repositório SQLite local (pronto para ser substituído por Firebase/Supabase no futuro)
  final IHelpRequestRepository repository = SqliteHelpRepository();

  runApp(
    RedePatasApp(repository: repository),
  );
}

class RedePatasApp extends StatelessWidget {
  final IHelpRequestRepository repository;

  const RedePatasApp({
    super.key,
    required this.repository,
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
      ],
      child: Consumer2<ThemeController, AuthController>(
        builder: (context, themeController, authController, _) {
          return MaterialApp(
            title: 'RedePatas',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: authController.isAuthenticated
                ? const MainShellScreen()
                : const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
