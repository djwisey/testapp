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
