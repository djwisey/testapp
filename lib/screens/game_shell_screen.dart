import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/golf_models.dart';
import '../providers/game_provider.dart';

class GameShellScreen extends StatelessWidget {
  const GameShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = context.select<GameProvider, int>((GameProvider p) => p.selectedTabIndex);
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: const <Widget>[PlayScreen(), RoundsScreen(), StatsScreen(), SocialScreen(), ProfileScreen()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: context.read<GameProvider>().selectTab,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Play'),
          NavigationDestination(icon: Icon(Icons.scoreboard_outlined), selectedIcon: Icon(Icons.scoreboard), label: 'Rounds'),
          NavigationDestination(icon: Icon(Icons.query_stats), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Social'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class PlayScreen extends StatelessWidget { const PlayScreen({super.key});
  @override Widget build(BuildContext context) { final GameProvider p = context.watch<GameProvider>(); final Hole h = p.currentHole;
    return _Frame(title: 'Play', child: ListView(padding: const EdgeInsets.all(16), children: <Widget>[
      if (p.activeRound == null) _SetupCard(p: p) else ...<Widget>[
        Text('${p.activeRound!.courseName} • ${p.activeRound!.tee} • ${_mode(p.activeRound!.scoringMode)}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _HeroHole(hole: h, score: p.currentScore, toPar: p.relativeToPar),
        const SizedBox(height: 12),
        _GpsCard(hole: h, mock: p.lastGpsWasMock),
        const SizedBox(height: 12),
        _MapPlaceholder(shots: p.currentShots),
        const SizedBox(height: 12),
        _ShotControls(p: p),
        const SizedBox(height: 12),
        _ScoreControls(p: p),
        const SizedBox(height: 12),
        Row(children: <Widget>[Expanded(child: OutlinedButton.icon(onPressed: p.previousHole, icon: const Icon(Icons.chevron_left), label: const Text('Previous'))), const SizedBox(width: 8), Expanded(child: FilledButton.icon(onPressed: p.nextHole, icon: const Icon(Icons.chevron_right), label: const Text('Next hole')))]),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(onPressed: p.completeRound, icon: const Icon(Icons.flag_circle), label: const Text('Complete round')),
      ],
    ])); }
}

class _SetupCard extends StatelessWidget { const _SetupCard({required this.p}); final GameProvider p;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    Text('Round setup', style: Theme.of(context).textTheme.headlineSmall), const Text('Select course, tee, scoring format and solo/group mode. A local QR/share placeholder is generated.'),
    DropdownButtonFormField<String>(value: p.selectedCourseId, decoration: const InputDecoration(labelText: 'Course'), items: p.courses.map((GolfCourse c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (String? v) => p.updateSetup(courseId: v)),
    DropdownButtonFormField<String>(value: p.selectedTee, decoration: const InputDecoration(labelText: 'Tee'), items: p.selectedCourse.tees.map((String t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (String? v) => p.updateSetup(tee: v)),
    DropdownButtonFormField<ScoringMode>(value: p.selectedMode, decoration: const InputDecoration(labelText: 'Scoring mode'), items: ScoringMode.values.map((ScoringMode m) => DropdownMenuItem(value: m, child: Text(_mode(m)))).toList(), onChanged: (ScoringMode? v) => p.updateSetup(mode: v)),
    SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Group round'), subtitle: const Text('Local-only group placeholder'), value: p.groupRound, onChanged: (bool v) => p.updateSetup(isGroup: v)),
    FilledButton.icon(onPressed: p.startRound, icon: const Icon(Icons.qr_code_2), label: const Text('Start round + generate share code')),
  ]))); }
}

class _HeroHole extends StatelessWidget { const _HeroHole({required this.hole, required this.score, required this.toPar}); final Hole hole; final HoleScore score; final int toPar;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    Text('Hole ${hole.number}', style: Theme.of(context).textTheme.headlineMedium), Text('Par ${hole.par} • ${hole.yards} yd • Stroke ${hole.handicap}'), Wrap(spacing: 8, children: <Widget>[_Chip('Score', '${score.strokes}'), _Chip('Putts', '${score.putts}'), _Chip('Penalties', '${score.penalties}'), _Chip('To par', toPar == 0 ? 'E' : '$toPar')])
  ]))); }
}

class _GpsCard extends StatelessWidget { const _GpsCard({required this.hole, required this.mock}); final Hole hole; final bool mock;
  @override Widget build(BuildContext context) => Card(child: ListTile(leading: const Icon(Icons.gps_fixed), title: const Text('GPS distances'), subtitle: Text('Front ${(hole.yards * .92).round()} yd • Middle ${hole.yards} yd • Back ${(hole.yards * 1.06).round()} yd${mock ? ' • using mock GPS' : ''}'))); }
}

class _MapPlaceholder extends StatelessWidget { const _MapPlaceholder({required this.shots}); final List<Shot> shots;
  @override Widget build(BuildContext context) => AspectRatio(aspectRatio: 1.6, child: Card(clipBehavior: Clip.antiAlias, child: CustomPaint(painter: _ShotMapPainter(shots.length), child: Center(child: Text('Course / hole map placeholder\n${shots.length} shot markers with replay line', textAlign: TextAlign.center))))); }
}

class _ShotControls extends StatelessWidget { const _ShotControls({required this.p}); final GameProvider p;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: <Widget>[
    Row(children: <Widget>[Expanded(child: DropdownButtonFormField<String>(value: p.selectedClubId, decoration: const InputDecoration(labelText: 'Club'), items: p.clubs.map((Club c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (String? v) => p.updateShotOptions(clubId: v))), const SizedBox(width: 8), Expanded(child: DropdownButtonFormField<String>(value: p.selectedLie, decoration: const InputDecoration(labelText: 'Lie'), items: const ['Tee', 'Fairway', 'Rough', 'Sand', 'Green', 'Recovery'].map((String l) => DropdownMenuItem(value: l, child: Text(l))).toList(), onChanged: (String? v) => p.updateShotOptions(lie: v)))]),
    DropdownButtonFormField<String>(value: p.selectedResult, decoration: const InputDecoration(labelText: 'Result'), items: const ['Good', 'Left', 'Right', 'Short', 'Long', 'Penalty', 'Holed'].map((String r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (String? v) => p.updateShotOptions(result: v)),
    FilledButton.icon(onPressed: p.addShot, icon: const Icon(Icons.add_location_alt), label: const Text('Add shot from GPS')),
    for (final Shot s in p.currentShots) ListTile(title: Text('${s.clubName} • ${s.distanceYards} yd'), subtitle: Text('${s.lie} • ${s.result} • ${DateFormat.Hm().format(s.timestamp)}'), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => p.deleteShot(s.id))),
  ]))); }
}

class _ScoreControls extends StatelessWidget { const _ScoreControls({required this.p}); final GameProvider p;
  @override Widget build(BuildContext context) { final HoleScore s = p.currentScore; return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    Text('Score entry', style: Theme.of(context).textTheme.titleLarge), Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
      _Counter(label: 'Strokes', value: s.strokes, onChanged: (int v) => p.updateCurrentScore(strokes: v)), _Counter(label: 'Putts', value: s.putts, onChanged: (int v) => p.updateCurrentScore(putts: v)), _Counter(label: 'Penalties', value: s.penalties, onChanged: (int v) => p.updateCurrentScore(penalties: v)),
    ]), SwitchListTile(title: const Text('FIR'), value: s.fairwayHit, onChanged: (bool v) => p.updateCurrentScore(fir: v)), SwitchListTile(title: const Text('GIR'), value: s.greenInRegulation, onChanged: (bool v) => p.updateCurrentScore(gir: v)), SwitchListTile(title: const Text('Sand save'), value: s.sandSave, onChanged: (bool v) => p.updateCurrentScore(sandSave: v)), SwitchListTile(title: const Text('Up-and-down'), value: s.upAndDown, onChanged: (bool v) => p.updateCurrentScore(upAndDown: v)), Text('Stableford: ${p.statsService.stablefordPoints(p.currentHole, s)} • Match: ${s.matchResult}')]))); }
}

class RoundsScreen extends StatelessWidget { const RoundsScreen({super.key});
  @override Widget build(BuildContext context) { final GameProvider p = context.watch<GameProvider>(); return _Frame(title: 'Rounds', child: ListView(padding: const EdgeInsets.all(16), children: <Widget>[
    if (p.activeRound != null) Card(child: ListTile(leading: const Icon(Icons.save), title: const Text('In-progress round restored'), subtitle: Text('${p.activeRound!.courseName} • ${p.activeRound!.shareCode}'))),
    if (p.completedRounds.isEmpty) const Card(child: ListTile(title: Text('No completed rounds yet'), subtitle: Text('Finish a round from Play to build history.'))),
    for (final GolfRound r in p.completedRounds) ExpansionTile(title: Text('${r.courseName} • ${r.totalStrokes}'), subtitle: Text('${DateFormat.yMMMd().format(r.completedAt ?? r.createdAt)} • ${_mode(r.scoringMode)} • ${r.shareCode}'), children: <Widget>[
      const ListTile(title: Text('Full scorecard + map replay placeholder')),
      for (final HoleScore s in r.scores) ListTile(dense: true, leading: CircleAvatar(child: Text('${s.holeNumber}')), title: Text('Strokes ${s.strokes}, putts ${s.putts}, penalties ${s.penalties}'), subtitle: Text('FIR ${s.fairwayHit ? 'Y' : 'N'} • GIR ${s.greenInRegulation ? 'Y' : 'N'} • Match ${s.matchResult}')),
      for (final Shot shot in r.shots) ListTile(dense: true, leading: const Icon(Icons.near_me), title: Text('Hole ${shot.holeNumber}: ${shot.clubName} ${shot.distanceYards} yd'), subtitle: Text('${shot.lie} • ${shot.result}')),
    ]),
  ])); }
}

class StatsScreen extends StatelessWidget { const StatsScreen({super.key});
  @override Widget build(BuildContext context) { final GameProvider p = context.watch<GameProvider>(); final StatsSummary s = p.stats; return _Frame(title: 'Stats', child: ListView(padding: const EdgeInsets.all(16), children: <Widget>[
    Wrap(spacing: 8, runSpacing: 8, children: <Widget>[_Metric('Scoring avg', s.scoringAverage.toStringAsFixed(1)), _Metric('FIR', '${s.firPercentage.toStringAsFixed(0)}%'), _Metric('GIR', '${s.girPercentage.toStringAsFixed(0)}%'), _Metric('Putts/round', s.puttsPerRound.toStringAsFixed(1)), _Metric('Penalties/round', s.penaltiesPerRound.toStringAsFixed(1))]),
    const Card(child: ListTile(leading: Icon(Icons.show_chart), title: Text('Score trend placeholder'), subtitle: Text('Charts can plug in here when a charting package is selected.'))),
    const Card(child: ListTile(leading: Icon(Icons.trending_down), title: Text('Handicap / progress placeholder'), subtitle: Text('Local-first handicap tracking TODO.'))),
    Card(child: Column(children: <Widget>[const ListTile(title: Text('Average distance by club')), for (final MapEntry<String, double> e in s.averageDistanceByClub.entries) ListTile(dense: true, title: Text(e.key), trailing: Text('${e.value.round()} yd'))])),
  ])); }
}

class SocialScreen extends StatelessWidget { const SocialScreen({super.key});
  @override Widget build(BuildContext context) { final GameProvider p = context.watch<GameProvider>(); return _Frame(title: 'Friends/Social', child: ListView(padding: const EdgeInsets.all(16), children: <Widget>[
    Text('Friends', style: Theme.of(context).textTheme.titleLarge), for (final Friend f in p.friends) Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(f.name), subtitle: Text('HI ${f.handicap} • ${f.status}'))),
    Text('Local feed', style: Theme.of(context).textTheme.titleLarge), for (final SocialPost post in p.posts) Card(child: ListTile(title: Text(post.author), subtitle: Text('${post.text}\n${post.likes} likes • ${post.comments.length} comments • UI only'), trailing: const Icon(Icons.favorite_border))),
  ])); }
}

class ProfileScreen extends StatelessWidget { const ProfileScreen({super.key});
  @override Widget build(BuildContext context) { final GameProvider p = context.watch<GameProvider>(); return _Frame(title: 'Profile', child: ListView(padding: const EdgeInsets.all(16), children: <Widget>[
    Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.sports_golf)), title: Text(p.profile.name), subtitle: Text('${p.profile.homeCourse} • HI ${p.profile.handicapIndex} • Favorite ${p.profile.favoriteClub}'))),
    SwitchListTile(title: const Text('Dark mode'), value: p.darkMode, onChanged: (_) => p.toggleDarkMode()),
    const Card(child: ListTile(title: Text('Local-first'), subtitle: Text('No login, Firebase, subscriptions, backend, or paywalls. Rounds, shots, courses, clubs and profile are stored locally.'))),
  ])); }
}

class _Frame extends StatelessWidget { const _Frame({required this.title, required this.child}); final String title; final Widget child; @override Widget build(BuildContext context) => SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(title, style: Theme.of(context).textTheme.headlineLarge)), Expanded(child: child)])); }
class _Chip extends StatelessWidget { const _Chip(this.label, this.value); final String label; final String value; @override Widget build(BuildContext context) => Chip(label: Text('$label: $value')); }
class _Metric extends StatelessWidget { const _Metric(this.label, this.value); final String label; final String value; @override Widget build(BuildContext context) => SizedBox(width: 165, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label), Text(value, style: Theme.of(context).textTheme.headlineSmall)])))); }
class _Counter extends StatelessWidget { const _Counter({required this.label, required this.value, required this.onChanged}); final String label; final int value; final ValueChanged<int> onChanged; @override Widget build(BuildContext context) => InputChip(label: Text('$label: $value'), onPressed: () => onChanged(value + 1), onDeleted: value > 0 ? () => onChanged(value - 1) : null); }
class _ShotMapPainter extends CustomPainter { const _ShotMapPainter(this.count); final int count; @override void paint(Canvas canvas, Size size) { final Paint fairway = Paint()..color = const Color(0xFF78C679); final Paint line = Paint()..color = Colors.white..strokeWidth = 3; final Paint marker = Paint()..color = Colors.orange; canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)), fairway); Offset last = Offset(size.width * .12, size.height * .85); for (int i = 0; i < count; i++) { final Offset next = Offset(size.width * (.18 + i * .16).clamp(.18, .86), size.height * (.78 - i * .12).clamp(.18, .78)); canvas.drawLine(last, next, line); canvas.drawCircle(next, 8, marker); last = next; } canvas.drawCircle(Offset(size.width * .82, size.height * .18), 18, Paint()..color = const Color(0xFF2E7D32)); } @override bool shouldRepaint(covariant _ShotMapPainter oldDelegate) => oldDelegate.count != count; }
String _mode(ScoringMode mode) => switch (mode) { ScoringMode.strokePlay => 'Stroke Play', ScoringMode.matchPlay => 'Match Play', ScoringMode.stableford => 'Stableford', ScoringMode.gpsOnly => 'GPS-only' };
