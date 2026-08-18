import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/business_provider.dart';
import 'screens/game_shell_screen.dart';

class FieldFlowApp extends StatelessWidget {
  const FieldFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BusinessProvider>(
      create: (_) => BusinessProvider()..initialize(),
      child: Consumer<BusinessProvider>(
        builder: (BuildContext context, BusinessProvider businessProvider, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FieldFlow',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F5F7A)),
              useMaterial3: true,
            ),
            home: const WorkforceShellScreen(),
          );
        },
      ),
    );
  }
}
