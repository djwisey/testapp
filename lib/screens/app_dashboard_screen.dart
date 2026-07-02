import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/game_catalog.dart';
import '../data/meta_game_catalog.dart';
import '../models/company_app.dart';
import '../providers/game_provider.dart';
import '../utils/build_info.dart';
import '../widgets/action_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/section_card.dart';

class AppDashboardScreen extends StatelessWidget {
  const AppDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();
    final AppCatalogEntry recommendedApp = appCatalog.firstWhere(
      (AppCatalogEntry entry) => game.apps.every((CompanyApp app) => app.name != entry.name),
      orElse: () => appCatalog.last,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.corporate_fare),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Startup Empire',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        game.welcomeBackMessage ?? 'Build software, hire talent, and scale the company.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Build $buildStamp',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            MetricCard(
              title: 'Cash',
              value: '\$${game.cash.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet,
              subtitle: 'Per second: \$${game.totalRevenuePerSecond.toStringAsFixed(1)}',
            ),
            MetricCard(title: 'Users', value: game.users.toString(), icon: Icons.people, subtitle: 'Revenue is growing'),
            MetricCard(title: 'Employees', value: game.employees.length.toString(), icon: Icons.groups, subtitle: 'Limit: ${game.employeeLimit}'),
            MetricCard(title: 'Office', value: 'Level ${game.officeLevel}', icon: Icons.apartment, subtitle: 'Founder level ${game.founderLevel}'),
            MetricCard(
              title: 'Research',
              value: game.researchPoints.toStringAsFixed(0),
              icon: Icons.science,
              subtitle: 'Active: ${game.snapshot.activeResearchIndex >= 0 ? game.researchTopics[game.snapshot.activeResearchIndex].name : 'None'}',
            ),
            MetricCard(title: 'Server Capacity', value: game.serverCapacity.toStringAsFixed(0), icon: Icons.dns, subtitle: 'Marketing ${game.marketingScore.toStringAsFixed(1)}'),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Quick Actions',
          subtitle: 'Move the company forward without navigating away.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              SizedBox(
                width: 260,
                child: ActionCard(
                  title: 'Start ${recommendedApp.name}',
                  subtitle: 'Cost: \$${recommendedApp.baseCost.toStringAsFixed(0)}',
                  icon: Icons.apps,
                  enabled: game.cash >= recommendedApp.baseCost,
                  onPressed: () => game.startAppDevelopment(recommendedApp.name),
                ),
              ),
              const SizedBox(width: 260, child: SizedBox.shrink()),
              SizedBox(
                width: 260,
                child: ActionCard(
                  title: 'Hire Developer',
                  subtitle: 'Build faster with more engineering capacity.',
                  icon: Icons.person_add,
                  onPressed: () => game.hireEmployee('Developer'),
                ),
              ),
              SizedBox(
                width: 260,
                child: ActionCard(
                  title: 'Research AI',
                  subtitle: 'Unlock smarter products and automation.',
                  icon: Icons.psychology_alt,
                  onPressed: () => game.startResearch('AI'),
                ),
              ),
              SizedBox(
                width: 260,
                child: ActionCard(
                  title: 'Upgrade Office',
                  subtitle: 'Expand employee capacity and productivity.',
                  icon: Icons.apartment,
                  enabled: game.officeLevel < officeCatalog.length,
                  onPressed: game.upgradeOffice,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Notifications',
          subtitle: 'Recent company events and system messages.',
          child: Column(
            children: game.notifications.isEmpty
                ? <Widget>[const Align(alignment: Alignment.centerLeft, child: Text('No notifications yet.'))]
                : game.notifications
                    .map(
                      (String message) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.notifications_active_outlined),
                        title: Text(message),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (game.activeEvent != null)
          SectionCard(
            title: game.activeEvent!.title,
            subtitle: game.activeEvent!.description,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: game.activeEvent!.choices
                  .asMap()
                  .entries
                  .map(
                    (MapEntry<int, GameEventChoice> entry) => SizedBox(
                      width: 300,
                      child: ActionCard(
                        title: entry.value.label,
                        subtitle: entry.value.notification,
                        icon: Icons.event_available,
                        onPressed: () => game.resolveActiveEventChoice(entry.key),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
