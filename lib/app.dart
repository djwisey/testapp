import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/business_provider.dart';
import 'screens/game_shell_screen.dart';
import 'screens/login_screen.dart';
import 'services/pocketbase_service.dart';

class FieldFlowApp extends StatelessWidget {
  const FieldFlowApp({super.key, this.backend});

  final PocketBaseService? backend;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BusinessProvider>(
      create: (_) => BusinessProvider(backend: backend)..initialize(),
      child: Consumer<BusinessProvider>(
        builder:
            (BuildContext context, BusinessProvider provider, Widget? child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'EMN Plant',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF0D1B4E),
                    primary: const Color(0xFF0D1B4E),
                    secondary: const Color(0xFFF5C400),
                  ),
                  useMaterial3: true,
                  scaffoldBackgroundColor: const Color(0xFFF5F6F8),
                  cardTheme: const CardThemeData(
                    elevation: 0,
                    margin: EdgeInsets.only(bottom: 10),
                    color: Colors.white,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  filledButtonTheme: FilledButtonThemeData(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                home: provider.isInitializing && !provider.isAuthenticated
                    ? const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      )
                    : provider.isAuthenticated
                    ? const WorkforceShellScreen()
                    : const LoginScreen(),
              );
            },
      ),
    );
  }
}
