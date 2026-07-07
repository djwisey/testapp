import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

class GameShellScreen extends StatelessWidget {
  const GameShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = context.select<GameProvider, int>((GameProvider provider) => provider.selectedTabIndex);
    final List<Widget> screens = <Widget>[
      const _DashboardScreen(),
      const _CourseMapScreen(),
      const _ShotLogScreen(),
      const _SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: context.read<GameProvider>().selectTab,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.sports_golf), label: 'Round'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Dale Map'),
          NavigationDestination(icon: Icon(Icons.straighten), label: 'Shots'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    final GameProvider provider = context.watch<GameProvider>();
    final CourseHole hole = provider.currentHole;
    return _ScreenFrame(
      title: 'Dale Golf Caddie',
      subtitle: 'Optimised for Shetland Golf Club at Dale, Lerwick',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _HeroCourseCard(hole: hole),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _StatCard(label: 'Hole', value: '${hole.number}', icon: Icons.flag),
              _StatCard(label: 'Par', value: '${hole.par}', icon: Icons.emoji_events_outlined),
              _StatCard(label: 'Card yards', value: '${hole.yards}', icon: Icons.straighten),
              _StatCard(label: 'To pin', value: '${provider.distanceToPinYards.round()} yd', icon: Icons.my_location),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text('Shetland wind helper', style: Theme.of(context).textTheme.titleLarge),
                Text('${provider.windMph.round()} mph. Add ${_windAdjustment(provider.windMph)} yards into the wind.'),
                Slider(value: provider.windMph, min: 0, max: 45, divisions: 45, label: '${provider.windMph.round()} mph', onChanged: provider.updateWind),
                Text(hole.tip),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => provider.addShot(club: 'Tracked club', yards: provider.distanceToPinYards.round(), lie: 'Live position', note: 'Quick shot from Dale course map'),
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Track shot from current location'),
          ),
        ],
      ),
    );
  }

  int _windAdjustment(double windMph) => (windMph * 0.65).round();
}

class _CourseMapScreen extends StatelessWidget {
  const _CourseMapScreen();

  @override
  Widget build(BuildContext context) {
    final GameProvider provider = context.watch<GameProvider>();
    return _ScreenFrame(
      title: 'Dale course map',
      subtitle: 'Hole routing, green target and your simulated GPS marker',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 0.78,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: CustomPaint(
                painter: _CoursePainter(provider.currentHole, provider.playerX, provider.playerY),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: GameProvider.daleGolfCourse.map((CourseHole hole) {
              return ChoiceChip(
                label: Text('${hole.number}'),
                selected: provider.selectedHole == hole.number,
                onSelected: (_) => provider.selectHole(hole.number),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ShotLogScreen extends StatelessWidget {
  const _ShotLogScreen();

  @override
  Widget build(BuildContext context) {
    final GameProvider provider = context.watch<GameProvider>();
    return _ScreenFrame(
      title: 'Shot tracker',
      subtitle: 'Clubs, yardages, lies and notes for this round',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _StatCard(label: 'Shots', value: '${provider.shotsThisRound}', icon: Icons.sports_score),
          const SizedBox(height: 12),
          _StatCard(label: 'Putts', value: '${provider.puttsThisRound}', icon: Icons.golf_course),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: () => provider.addShot(), icon: const Icon(Icons.add), label: const Text('Add sample shot')),
          const SizedBox(height: 16),
          for (final GolfShot shot in provider.shots)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${shot.hole}')),
                title: Text('${shot.club} • ${shot.yards} yd'),
                subtitle: Text('${shot.lie} — ${shot.note}'),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    final GameProvider provider = context.watch<GameProvider>();
    return _ScreenFrame(
      title: 'Caddie settings',
      subtitle: 'Build-safe Flutter settings kept inside the existing app shell',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          SwitchListTile(title: const Text('Dark mode'), value: provider.darkMode, onChanged: (_) => provider.toggleDarkMode()),
          SwitchListTile(title: const Text('Shot sounds'), value: provider.soundEnabled, onChanged: (_) => provider.toggleSound()),
          const ListTile(leading: Icon(Icons.place), title: Text('Home course'), subtitle: Text('Dale Golf Course, Shetland')),
        ],
      ),
    );
  }
}

class _ScreenFrame extends StatelessWidget {
  const _ScreenFrame({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ]),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _HeroCourseCard extends StatelessWidget {
  const _HeroCourseCard({required this.hole});

  final CourseHole hole;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Hole ${hole.number}: ${hole.name}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Par ${hole.par} • ${hole.yards} yards • stroke index ${hole.strokeIndex}'),
          const SizedBox(height: 8),
          Text(hole.tip),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Icon(icon),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label),
          ]),
        ),
      ),
    );
  }
}

class _CoursePainter extends CustomPainter {
  _CoursePainter(this.hole, this.playerX, this.playerY);

  final CourseHole hole;
  final double playerX;
  final double playerY;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint rough = Paint()..color = const Color(0xFF2F6B3C);
    final Paint fairway = Paint()..color = const Color(0xFF80B957);
    final Paint green = Paint()..color = const Color(0xFFB8E986);
    final Paint bunker = Paint()..color = const Color(0xFFE8D49B);
    final Paint blue = Paint()..color = const Color(0xFF5DADE2);
    canvas.drawRect(Offset.zero & size, rough);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.05, size.height * 0.07, size.width * 0.32, size.height * 0.16), blue);

    final Path fairwayPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.82)
      ..cubicTo(size.width * (0.42 + hole.fairwayBend), size.height * 0.62, size.width * (0.48 - hole.fairwayBend), size.height * 0.42, size.width * hole.greenX, size.height * hole.greenY)
      ..cubicTo(size.width * (hole.greenX - 0.16), size.height * (hole.greenY + 0.08), size.width * 0.32, size.height * 0.60, size.width * 0.17, size.height * 0.85)
      ..close();
    canvas.drawPath(fairwayPath, fairway);
    canvas.drawOval(Rect.fromCircle(center: Offset(size.width * hole.greenX, size.height * hole.greenY), radius: 34), green);
    canvas.drawOval(Rect.fromLTWH(size.width * (hole.greenX - 0.18), size.height * (hole.greenY + 0.03), 42, 24), bunker);
    canvas.drawCircle(Offset(size.width * playerX, size.height * playerY), 11, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * playerX, size.height * playerY), 7, Paint()..color = const Color(0xFF0057FF));
    final Paint flagPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3;
    final Offset pin = Offset(size.width * hole.greenX, size.height * hole.greenY);
    canvas.drawLine(pin, pin.translate(0, -42), flagPaint);
    canvas.drawPath(Path()..moveTo(pin.dx, pin.dy - 42)..lineTo(pin.dx + 28, pin.dy - 32)..lineTo(pin.dx, pin.dy - 22), Paint()..color = Colors.redAccent);
  }

  @override
  bool shouldRepaint(covariant _CoursePainter oldDelegate) => oldDelegate.hole != hole || oldDelegate.playerX != playerX || oldDelegate.playerY != playerY;
}
