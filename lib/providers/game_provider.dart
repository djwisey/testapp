import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/golf_models.dart';
import '../repositories/game_repository.dart';
import '../services/course_store.dart';
import '../services/location_service.dart';
import '../services/mock_social_service.dart';
import '../services/round_store.dart';
import '../services/stats_service.dart';

class GameProvider extends ChangeNotifier {
  GameProvider({required this.gameRepository});
  final GameRepository gameRepository;
  final RoundStore _roundStore = RoundStore();
  final CourseStore _courseStore = CourseStore();
  final LocationService _locationService = LocationService();
  final StatsService statsService = StatsService();
  final MockSocialService _socialService = MockSocialService();
  final Uuid _uuid = const Uuid();

  bool darkMode = false;
  int selectedTabIndex = 0;
  int currentHoleNumber = 1;
  List<GolfCourse> courses = CourseStore().loadSeedCourses();
  List<Club> clubs = CourseStore().defaultClubs();
  UserProfile profile = UserProfile.defaultProfile();
  GolfRound? activeRound;
  List<GolfRound> completedRounds = <GolfRound>[];
  List<Friend> friends = MockSocialService().friends();
  List<SocialPost> posts = MockSocialService().seedPosts();
  String selectedCourseId = 'dale';
  String selectedTee = 'White';
  ScoringMode selectedMode = ScoringMode.strokePlay;
  bool groupRound = false;
  String selectedLie = 'Fairway';
  String selectedResult = 'Good';
  String selectedClubId = '7i';
  bool lastGpsWasMock = false;

  Future<void> initialize() async {
    courses = _courseStore.loadSeedCourses();
    clubs = _courseStore.defaultClubs();
    friends = _socialService.friends();
    posts = _socialService.seedPosts();
    profile = await _roundStore.loadProfile();
    activeRound = await _roundStore.loadActiveRound();
    completedRounds = await _roundStore.loadCompletedRounds();
    notifyListeners();
  }

  GolfCourse get selectedCourse => courses.firstWhere((GolfCourse c) => c.id == selectedCourseId);
  GolfCourse get activeCourse => courses.firstWhere((GolfCourse c) => c.id == (activeRound?.courseId ?? selectedCourseId));
  Hole get currentHole => activeCourse.holes[currentHoleNumber - 1];
  HoleScore get currentScore => activeRound?.scores.firstWhere((HoleScore s) => s.holeNumber == currentHoleNumber) ?? HoleScore(holeNumber: currentHoleNumber);
  List<Shot> get currentShots => activeRound?.shots.where((Shot s) => s.holeNumber == currentHoleNumber).toList() ?? <Shot>[];
  StatsSummary get stats => statsService.summarize(completedRounds);
  int get relativeToPar => (activeRound?.scores ?? const <HoleScore>[]).fold(0, (int total, HoleScore score) {
    if (score.strokes == 0) return total;
    final Hole hole = activeCourse.holes[score.holeNumber - 1];
    return total + score.strokes - hole.par;
  });

  void selectTab(int index) { selectedTabIndex = index; notifyListeners(); }
  void updateSetup({String? courseId, String? tee, ScoringMode? mode, bool? isGroup}) { selectedCourseId = courseId ?? selectedCourseId; selectedTee = tee ?? selectedTee; selectedMode = mode ?? selectedMode; groupRound = isGroup ?? groupRound; notifyListeners(); }
  void updateShotOptions({String? clubId, String? lie, String? result}) { selectedClubId = clubId ?? selectedClubId; selectedLie = lie ?? selectedLie; selectedResult = result ?? selectedResult; notifyListeners(); }
  void toggleDarkMode() { darkMode = !darkMode; notifyListeners(); }

  Future<void> startRound() async {
    final GolfCourse course = selectedCourse;
    activeRound = GolfRound(id: _uuid.v4(), courseId: course.id, courseName: course.name, tee: selectedTee, scoringMode: selectedMode, isGroupRound: groupRound, createdAt: DateTime.now(), status: RoundStatus.inProgress, shareCode: 'QR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}', scores: course.holes.map((Hole h) => HoleScore(holeNumber: h.number)).toList(), shots: const <Shot>[]);
    currentHoleNumber = 1;
    await _roundStore.saveActiveRound(activeRound);
    notifyListeners();
  }

  Future<void> updateCurrentScore({int? strokes, int? putts, int? penalties, bool? fir, bool? gir, bool? sandSave, bool? upAndDown, String? matchResult}) async {
    final GolfRound? round = activeRound;
    if (round == null) return;
    final List<HoleScore> scores = round.scores.map((HoleScore score) => score.holeNumber == currentHoleNumber ? score.copyWith(strokes: strokes, putts: putts, penalties: penalties, fairwayHit: fir, greenInRegulation: gir, sandSave: sandSave, upAndDown: upAndDown, matchResult: matchResult) : score).toList();
    activeRound = round.copyWith(scores: scores);
    await _roundStore.saveActiveRound(activeRound);
    notifyListeners();
  }

  Future<void> addShot() async {
    final GolfRound? round = activeRound;
    if (round == null) await startRound();
    final GolfRound live = activeRound!;
    final Club club = clubs.firstWhere((Club c) => c.id == selectedClubId);
    final List<Shot> holeShots = live.shots.where((Shot s) => s.holeNumber == currentHoleNumber).toList();
    final Shot? previous = holeShots.isEmpty ? null : holeShots.last;
    final GpsPoint point = await _locationService.currentPoint(fallbackLat: currentHole.teeLat, fallbackLng: currentHole.teeLng);
    lastGpsWasMock = point.isMock;
    final int yards = previous == null ? club.averageYards : _locationService.distanceYards(previous.latitude, previous.longitude, point.latitude, point.longitude);
    final Shot shot = Shot(id: _uuid.v4(), holeNumber: currentHoleNumber, clubId: club.id, clubName: club.name, latitude: point.latitude, longitude: point.longitude, distanceYards: yards, lie: selectedLie, result: selectedResult, timestamp: DateTime.now());
    activeRound = live.copyWith(shots: <Shot>[...live.shots, shot]);
    await _roundStore.saveActiveRound(activeRound);
    notifyListeners();
  }

  Future<void> deleteShot(String id) async { final GolfRound? r = activeRound; if (r == null) return; activeRound = r.copyWith(shots: r.shots.where((Shot s) => s.id != id).toList()); await _roundStore.saveActiveRound(activeRound); notifyListeners(); }
  Future<void> editShot(Shot shot) async { final GolfRound? r = activeRound; if (r == null) return; activeRound = r.copyWith(shots: r.shots.map((Shot s) => s.id == shot.id ? shot : s).toList()); await _roundStore.saveActiveRound(activeRound); notifyListeners(); }
  void previousHole() { currentHoleNumber = (currentHoleNumber - 1).clamp(1, activeCourse.holes.length); notifyListeners(); }
  void nextHole() { currentHoleNumber = (currentHoleNumber + 1).clamp(1, activeCourse.holes.length); notifyListeners(); }

  Future<void> completeRound() async {
    final GolfRound? round = activeRound;
    if (round == null) return;
    final GolfRound done = round.copyWith(status: RoundStatus.completed, completedAt: DateTime.now());
    completedRounds = <GolfRound>[done, ...completedRounds];
    activeRound = null;
    await _roundStore.saveCompletedRounds(completedRounds);
    await _roundStore.saveActiveRound(null);
    posts = <SocialPost>[SocialPost(id: _uuid.v4(), author: profile.name, text: 'Shared ${done.totalStrokes} at ${done.courseName} (${done.shareCode}).', createdAt: DateTime.now(), likes: 0, comments: const <String>['Nice round!']), ...posts];
    selectedTabIndex = 1;
    notifyListeners();
  }
}
