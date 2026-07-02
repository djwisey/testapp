import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/game_catalog.dart';
import '../providers/game_provider.dart';
import '../widgets/action_card.dart';
import '../widgets/section_card.dart';

class AppServersScreen extends StatelessWidget {
  const AppServersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();
    final int nextIndex = game.servers.length < serverCatalog.length ? game.servers.length : serverCatalog.length - 1;
    final ServerCatalogEntry nextServer = serverCatalog[nextIndex];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        SectionCard(
          title: 'Server Stack',
          subtitle: 'Capacity must grow with the user base.',
          child: Column(
            children: game.servers
                .map(
                  (server) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.storage_outlined),
                    title: Text(server.name),
                    subtitle: Text('Capacity ${server.capacity} • Maintenance \$${server.maintenanceCost.toStringAsFixed(0)}'),
                    trailing: Text('Level ${server.level}'),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Upgrade Capacity',
          subtitle: 'Purchase the next server tier when the company outgrows the current stack.',
          child: SizedBox(
            width: 320,
            child: ActionCard(
              title: nextServer.name,
              subtitle: '\$${nextServer.cost.toStringAsFixed(0)} • ${nextServer.capacity} capacity',
              icon: Icons.dns,
              enabled: game.cash >= nextServer.cost,
              onPressed: game.buyServer,
            ),
          ),
        ),
      ],
    );
  }
}
