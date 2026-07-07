import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/game_catalog.dart';
import '../models/company_app.dart';
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
        .where((AppCatalogEntry entry) => game.apps.every((CompanyApp app) => app.name != entry.name))
        .toList();
    final int liveApps = game.apps.where((CompanyApp app) => app.developmentProgress >= 100).length;
    final int totalBugs = game.apps.fold<int>(0, (int total, CompanyApp app) => total + app.bugCount);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        SectionCard(
          title: 'Product Studio',
          subtitle: 'Design, launch, market, patch, and improve a portfolio of money-making apps.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _StudioStat(label: 'Live products', value: '$liveApps'),
              _StudioStat(label: 'Portfolio bugs', value: '$totalBugs'),
              _StudioStat(label: 'Gross revenue/s', value: '\$${game.totalRevenuePerSecond.toStringAsFixed(1)}'),
              _StudioStat(label: 'Reputation', value: game.reputation.toStringAsFixed(0)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: title,
          subtitle: 'Every product has trade-offs: new features add users, marketing creates demand, and bug fixing protects ratings.',
          child: Column(
            children: game.apps.map((CompanyApp app) => _AppProductCard(app: app)).toList(),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Start New Product',
          subtitle: availableApps.isEmpty ? 'Your studio has shipped every catalog product.' : 'Choose the next app to prototype and release.',
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
                      icon: Icons.rocket_launch,
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

class _AppProductCard extends StatelessWidget {
  const _AppProductCard({required this.app});

  final CompanyApp app;

  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();
    final bool isLive = app.developmentProgress >= 100;
    final double campaignCost = (app.users * 0.08 + app.popularity * 18 + 120).clamp(250, double.infinity).toDouble();
    final double bugFixCost = (app.bugCount * 90 + app.users * 0.015).clamp(120, double.infinity).toDouble();
    final double updateCost = (app.users * 0.035 + app.popularity * 35).clamp(400, double.infinity).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(isLive ? Icons.public : Icons.construction, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(app.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ),
                Chip(label: Text(isLive ? 'Live v${app.version}' : 'Building ${app.developmentProgress.toStringAsFixed(0)}%')),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: app.developmentProgress / 100),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: <Widget>[
                _Pill(icon: Icons.people, label: '${app.users} users'),
                _Pill(icon: Icons.star, label: '${app.rating.toStringAsFixed(0)} rating'),
                _Pill(icon: Icons.bug_report, label: '${app.bugCount} bugs'),
                _Pill(icon: Icons.trending_up, label: '${app.popularity.toStringAsFixed(1)} popularity'),
                _Pill(icon: Icons.payments, label: '\$${app.revenuePerSecond.toStringAsFixed(1)}/s'),
                _Pill(icon: Icons.savings, label: '\$${app.lifetimeRevenue.toStringAsFixed(0)} lifetime'),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                SizedBox(
                  width: 220,
                  child: ActionCard(
                    title: 'Ship feature update',
                    subtitle: 'Cost: \$${updateCost.toStringAsFixed(0)} • users + rating, may add bugs',
                    icon: Icons.new_releases,
                    enabled: isLive && game.cash >= updateCost,
                    onPressed: () => game.shipFeatureUpdate(app.name),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: ActionCard(
                    title: 'Run campaign',
                    subtitle: 'Cost: \$${campaignCost.toStringAsFixed(0)} • grow users and popularity',
                    icon: Icons.campaign,
                    enabled: isLive && game.cash >= campaignCost,
                    onPressed: () => game.runMarketingCampaign(app.name),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: ActionCard(
                    title: 'Fix bugs',
                    subtitle: 'Cost: \$${bugFixCost.toStringAsFixed(0)} • improves trust and rating',
                    icon: Icons.healing,
                    enabled: isLive && app.bugCount > 0 && game.cash >= bugFixCost,
                    onPressed: () => game.fixBugs(app.name),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StudioStat extends StatelessWidget {
  const _StudioStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
