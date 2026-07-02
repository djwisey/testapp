import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/game_catalog.dart';
import '../providers/game_provider.dart';
import '../widgets/action_card.dart';
import '../widgets/section_card.dart';

class AppGamesPlaceholderScreen extends StatelessWidget {
  const AppGamesPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();
    final List<AppCatalogEntry> availableApps = appCatalog
        .where((AppCatalogEntry entry) => game.apps.every((app) => app.name != entry.name))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        SectionCard(
          title: title,
          subtitle: 'Build and ship software products from a bedroom startup to a software empire.',
          child: Column(
            children: game.apps
                .map(
                  (app) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(child: Text(app.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                              Text('v${app.version}'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(value: app.developmentProgress / 100),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: <Widget>[
                              Text('Users: ${app.users}'),
                              Text('Rating: ${app.rating.toStringAsFixed(0)}'),
                              Text('Bugs: ${app.bugCount}'),
                              Text('Revenue/s: \$${app.revenuePerSecond.toStringAsFixed(1)}'),
                              Text('Lifetime: \$${app.lifetimeRevenue.toStringAsFixed(0)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Start New Product',
          subtitle: 'Choose the next app to build.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: availableApps
                .map(
                  (AppCatalogEntry entry) => SizedBox(
                    width: 280,
                    child: ActionCard(
                      title: entry.name,
                      subtitle: '\$${entry.baseCost.toStringAsFixed(0)} • ${entry.description}',
                      icon: Icons.play_arrow,
                      enabled: game.cash >= entry.baseCost,
                      onPressed: () => game.startAppDevelopment(entry.name),
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
