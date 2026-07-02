import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/game_catalog.dart';
import '../providers/game_provider.dart';
import '../widgets/section_card.dart';

class AppResearchScreen extends StatelessWidget {
  const AppResearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        SectionCard(
          title: 'Research Tree',
          subtitle: 'Research permanently improves the startup and unlocks stronger systems.',
          child: Column(
            children: List<Widget>.generate(
              game.researchTopics.length,
              (int index) {
                final topic = game.researchTopics[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(child: Text(topic.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                            Text(topic.unlocked ? 'Unlocked' : 'Locked'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(topic.description),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: topic.progress / 100),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => game.startResearch(topic.name),
                            icon: const Icon(Icons.science),
                            label: const Text('Research this topic'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Research Benefits',
          subtitle: 'Each topic unlocks new content and bonuses.',
          child: Column(
            children: researchCatalog
                .map((ResearchCatalogEntry entry) => ListTile(leading: const Icon(Icons.auto_awesome), title: Text(entry.name), subtitle: Text(entry.unlockNote)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
