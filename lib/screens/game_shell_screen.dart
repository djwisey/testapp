import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/app_bottom_nav.dart';
import 'app_dashboard_screen.dart';
import 'app_employees_screen.dart';
import 'app_finance_screen.dart';
import 'app_games_placeholder_screen.dart';
import 'app_research_screen.dart';
import 'app_servers_screen.dart';
import 'app_settings_screen.dart';

class GameShellScreen extends StatelessWidget {
  const GameShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = context.select<GameProvider, int>((GameProvider provider) => provider.selectedTabIndex);
    final List<Widget> screens = <Widget>[
      const AppDashboardScreen(),
      const AppGamesPlaceholderScreen(title: 'Apps'),
      const AppEmployeesScreen(),
      const AppResearchScreen(),
      const AppServersScreen(),
      const AppFinanceScreen(),
      const AppSettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
