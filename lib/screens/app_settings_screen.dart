import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/meta_game_catalog.dart';
import '../providers/game_provider.dart';
import '../widgets/section_card.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        SectionCard(
          title: 'Settings',
          subtitle: 'Keep the save system and presentation under control.',
          child: Column(
            children: <Widget>[
              SwitchListTile(
                value: game.darkMode,
                onChanged: (_) => game.toggleDarkMode(),
                title: const Text('Dark Mode'),
              ),
              SwitchListTile(
                value: game.soundEnabled,
                onChanged: (_) => game.toggleSound(),
                title: const Text('Sound'),
              ),
              SwitchListTile(
                value: game.autosaveEnabled,
                onChanged: (_) => game.toggleAutosave(),
                title: const Text('Autosave'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton.tonalIcon(
                      onPressed: game.save,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Now'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final String json = game.exportSaveJson();
                        await Clipboard.setData(ClipboardData(text: json));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save exported to clipboard.')));
                        }
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text('Export Save'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showImportDialog(context, game),
                      icon: const Icon(Icons.download),
                      label: const Text('Import Save'),
                    ),
                    if (game.canPrestige)
                      FilledButton.icon(
                        onPressed: () => _showPrestigeDialog(context, game),
                        icon: const Icon(Icons.auto_awesome),
                        label: Text('Prestige +${game.prestigeGainPreview.toStringAsFixed(0)}'),
                      ),
                    OutlinedButton.icon(
                      onPressed: game.resetGame,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset Game'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Achievements',
          subtitle: '${game.unlockedAchievementIds.length} unlocked',
          child: Column(
            children: achievementCatalog
                .map(
                  (AchievementDefinition achievement) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      game.unlockedAchievementIds.contains(achievement.id) ? Icons.verified : Icons.lock_outline,
                    ),
                    title: Text(achievement.title),
                    subtitle: Text(achievement.description),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

Future<void> _showPrestigeDialog(BuildContext context, GameProvider game) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Prestige this company?'),
        content: Text(
          'This will reset cash, employees, apps, servers, and office level, but keep research, achievements, founder level, and prestige currency. You will gain +${game.prestigeGainPreview.toStringAsFixed(0)} prestige currency.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Prestige')),
        ],
      );
    },
  );

  if (confirm == true) {
    await game.prestige();
  }
}

Future<void> _showImportDialog(BuildContext context, GameProvider game) async {
  final TextEditingController controller = TextEditingController();
  final String? importedText = await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Import Save'),
        content: TextField(
          controller: controller,
          minLines: 6,
          maxLines: 12,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Paste exported save JSON here'),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text), child: const Text('Import')),
        ],
      );
    },
  );

  if (importedText == null || importedText.trim().isEmpty) {
    return;
  }

  try {
    await game.importSaveJson(importedText);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save imported successfully.')));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $error')));
    }
  }
}
