import '../models/golf_models.dart';

class StatsSummary {
  const StatsSummary({required this.scoringAverage, required this.firPercentage, required this.girPercentage, required this.puttsPerRound, required this.penaltiesPerRound, required this.averageDistanceByClub});
  final double scoringAverage; final double firPercentage; final double girPercentage; final double puttsPerRound; final double penaltiesPerRound; final Map<String, double> averageDistanceByClub;
}

class StatsService {
  StatsSummary summarize(List<GolfRound> rounds) {
    if (rounds.isEmpty) {
      return const StatsSummary(scoringAverage: 83.4, firPercentage: 57, girPercentage: 44, puttsPerRound: 32.1, penaltiesPerRound: 2.2, averageDistanceByClub: <String, double>{'Driver': 238, '7 iron': 151, 'Pitching wedge': 112, 'Putter': 7});
    }
    final int count = rounds.length;
    final Iterable<HoleScore> scores = rounds.expand((GolfRound r) => r.scores);
    final int fairways = scores.where((HoleScore s) => s.fairwayHit).length;
    final int greens = scores.where((HoleScore s) => s.greenInRegulation).length;
    final Map<String, List<int>> byClub = <String, List<int>>{};
    for (final Shot shot in rounds.expand((GolfRound r) => r.shots)) {
      byClub.putIfAbsent(shot.clubName, () => <int>[]).add(shot.distanceYards);
    }
    return StatsSummary(
      scoringAverage: rounds.fold<int>(0, (int t, GolfRound r) => t + r.totalStrokes) / count,
      firPercentage: scores.isEmpty ? 0 : fairways / scores.length * 100,
      girPercentage: scores.isEmpty ? 0 : greens / scores.length * 100,
      puttsPerRound: rounds.fold<int>(0, (int t, GolfRound r) => t + r.totalPutts) / count,
      penaltiesPerRound: rounds.fold<int>(0, (int t, GolfRound r) => t + r.totalPenalties) / count,
      averageDistanceByClub: byClub.map((String club, List<int> values) => MapEntry<String, double>(club, values.fold<int>(0, (int a, int b) => a + b) / values.length)),
    );
  }

  int stablefordPoints(Hole hole, HoleScore score) {
    if (score.strokes == 0) return 0;
    final int net = score.strokes - hole.par;
    if (net <= -2) return 4;
    if (net == -1) return 3;
    if (net == 0) return 2;
    if (net == 1) return 1;
    return 0;
  }
}
