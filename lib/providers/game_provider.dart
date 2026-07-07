import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../repositories/game_repository.dart';

class GolfShot {
  const GolfShot({
    required this.hole,
    required this.club,
    required this.yards,
    required this.lie,
    required this.note,
  });

  final int hole;
  final String club;
  final int yards;
  final String lie;
  final String note;
}

class CourseHole {
  const CourseHole({
    required this.number,
    required this.name,
    required this.par,
    required this.yards,
    required this.strokeIndex,
    required this.tip,
    required this.fairwayBend,
    required this.greenX,
    required this.greenY,
  });

  final int number;
  final String name;
  final int par;
  final int yards;
  final int strokeIndex;
  final String tip;
  final double fairwayBend;
  final double greenX;
  final double greenY;
}

class GameProvider extends ChangeNotifier with WidgetsBindingObserver {
  GameProvider({required this.gameRepository});

  final GameRepository gameRepository;

  bool _isInitialized = false;
  bool _darkMode = false;
  bool _soundEnabled = true;
  int _selectedTabIndex = 0;
  int _selectedHole = 1;
  int _shotsThisRound = 0;
  int _puttsThisRound = 0;
  double _windMph = 18;
  double _playerX = 0.28;
  double _playerY = 0.72;
  final List<GolfShot> _shots = <GolfShot>[
    const GolfShot(hole: 1, club: 'Driver', yards: 214, lie: 'Fairway', note: 'Downwind opening tee shot'),
    const GolfShot(hole: 1, club: '8 iron', yards: 128, lie: 'Green', note: 'Held up in a left-to-right breeze'),
  ];

  static const List<CourseHole> daleGolfCourse = <CourseHole>[
    CourseHole(number: 1, name: 'Breiwick', par: 4, yards: 356, strokeIndex: 7, tip: 'Aim at the right half of the fairway and let the wind feed the ball back.', fairwayBend: -0.16, greenX: 0.72, greenY: 0.18),
    CourseHole(number: 2, name: 'Sound View', par: 3, yards: 162, strokeIndex: 15, tip: 'Club up when the breeze comes over Lerwick harbour.', fairwayBend: 0.04, greenX: 0.62, greenY: 0.22),
    CourseHole(number: 3, name: 'Dale Burn', par: 4, yards: 382, strokeIndex: 3, tip: 'A controlled tee shot short of the burn leaves the best angle.', fairwayBend: 0.18, greenX: 0.78, greenY: 0.28),
    CourseHole(number: 4, name: 'Clickimin', par: 5, yards: 487, strokeIndex: 9, tip: 'Treat it as a three-shotter in strong Shetland wind.', fairwayBend: -0.22, greenX: 0.70, greenY: 0.16),
    CourseHole(number: 5, name: 'Knab', par: 4, yards: 331, strokeIndex: 11, tip: 'Accuracy beats length; the green is easiest from the left side.', fairwayBend: 0.12, greenX: 0.66, greenY: 0.24),
    CourseHole(number: 6, name: 'Bressay', par: 3, yards: 146, strokeIndex: 17, tip: 'Use the yardage plus wind adjustment rather than the card number.', fairwayBend: -0.02, greenX: 0.58, greenY: 0.20),
    CourseHole(number: 7, name: 'Gremista', par: 4, yards: 397, strokeIndex: 1, tip: 'The toughest hole: favour the safe centre and accept a longer approach.', fairwayBend: 0.20, greenX: 0.80, greenY: 0.18),
    CourseHole(number: 8, name: 'Scalloway', par: 4, yards: 344, strokeIndex: 13, tip: 'A hybrid or fairway wood keeps the ball below the breeze.', fairwayBend: -0.12, greenX: 0.69, greenY: 0.25),
    CourseHole(number: 9, name: 'Dale Home', par: 4, yards: 368, strokeIndex: 5, tip: 'Finish with a committed line at the clubhouse side of the fairway.', fairwayBend: 0.10, greenX: 0.76, greenY: 0.21),
  ];

  bool get isInitialized => _isInitialized;
  bool get darkMode => _darkMode;
  bool get soundEnabled => _soundEnabled;
  int get selectedTabIndex => _selectedTabIndex;
  int get selectedHole => _selectedHole;
  int get shotsThisRound => _shotsThisRound;
  int get puttsThisRound => _puttsThisRound;
  double get windMph => _windMph;
  double get playerX => _playerX;
  double get playerY => _playerY;
  List<GolfShot> get shots => List<GolfShot>.unmodifiable(_shots);
  CourseHole get currentHole => daleGolfCourse[_selectedHole - 1];
  int get scoreToPar => _shotsThisRound - daleGolfCourse.take(_selectedHole).fold<int>(0, (int total, CourseHole hole) => total + hole.par);
  double get distanceToPinYards {
    final double dx = currentHole.greenX - _playerX;
    final double dy = currentHole.greenY - _playerY;
    return math.sqrt((dx * dx) + (dy * dy)) * currentHole.yards;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void selectHole(int hole) {
    _selectedHole = hole.clamp(1, daleGolfCourse.length).toInt();
    _playerX = 0.26;
    _playerY = 0.76;
    notifyListeners();
  }

  void addShot({String club = '7 iron', int yards = 150, String lie = 'Fairway', String note = 'Tracked on course'}) {
    _shots.insert(0, GolfShot(hole: _selectedHole, club: club, yards: yards, lie: lie, note: note));
    _shotsThisRound += 1;
    if (club.toLowerCase().contains('putter')) {
      _puttsThisRound += 1;
    }
    _playerX = (_playerX + ((currentHole.greenX - _playerX) * 0.42)).clamp(0.08, 0.92).toDouble();
    _playerY = (_playerY + ((currentHole.greenY - _playerY) * 0.42)).clamp(0.08, 0.92).toDouble();
    notifyListeners();
  }

  void updateWind(double value) {
    _windMph = value.clamp(0, 45).toDouble();
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  Future<void> save() async {}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
