import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'repositories/game_repository.dart';
import 'screens/game_shell_screen.dart';
import 'theme/startup_empire_theme.dart';

class StartupEmpireApp extends StatelessWidget {
  const StartupEmpireApp({super.key, required this.gameRepository});

  final GameRepository gameRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameProvider>(
      create: (_) => GameProvider(gameRepository: gameRepository)..initialize(),
      child: Consumer<GameProvider>(
        builder: (BuildContext context, GameProvider gameProvider, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Startup Empire',
            theme: StartupEmpireTheme.lightTheme,
            darkTheme: StartupEmpireTheme.darkTheme,
            themeMode: gameProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const GameShellScreen(),
          );
        },
      ),
    );
  }
}
