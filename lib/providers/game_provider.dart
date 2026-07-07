import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../data/game_catalog.dart';
import '../data/meta_game_catalog.dart';
import '../models/company_app.dart';
import '../models/company_state.dart';
import '../models/employee.dart';
import '../models/game_snapshot.dart';
import '../models/research_topic.dart';
import '../models/server_node.dart';
import '../repositories/game_repository.dart';

class GameProvider extends ChangeNotifier with WidgetsBindingObserver {
  GameProvider({required this.gameRepository});

  final GameRepository gameRepository;
  final math.Random _random = math.Random();

  CompanyState _state = CompanyState.initial();
  Timer? _tickTimer;
  Timer? _autosaveTimer;
  bool _isInitialized = false;
  String? _welcomeBackMessage;
  final List<double> _revenueHistory = <double>[];
  final List<double> _cashHistory = <double>[];

  CompanyState get state => _state;
  GameSnapshot get snapshot => _state.snapshot;
  List<CompanyApp> get apps => List<CompanyApp>.unmodifiable(_state.apps);
  List<Employee> get employees => List<Employee>.unmodifiable(_state.employees);
  List<ServerNode> get servers => List<ServerNode>.unmodifiable(_state.servers);
  List<ResearchTopic> get researchTopics => List<ResearchTopic>.unmodifiable(_state.researchTopics);
  List<String> get notifications => List<String>.unmodifiable(_state.notifications);
  List<String> get unlockedAchievementIds => List<String>.unmodifiable(_state.unlockedAchievementIds);
  List<double> get revenueHistory => List<double>.unmodifiable(_revenueHistory);
  List<double> get cashHistory => List<double>.unmodifiable(_cashHistory);
  String? get welcomeBackMessage => _welcomeBackMessage;
  GameEventDefinition? get activeEvent {
    final String? eventId = _state.snapshot.activeEventId;
    if (eventId == null) {
      return null;
    }
    for (final GameEventDefinition event in randomEventCatalog) {
      if (event.id == eventId) {
        return event;
      }
    }
    return null;
  }

  int get selectedTabIndex => _state.snapshot.selectedTabIndex;
  double get cash => _state.snapshot.cash;
  int get users => _state.snapshot.users;
  double get reputation => _state.snapshot.reputation;
  double get researchPoints => _state.snapshot.researchPoints;
  double get developerProductivity => _state.snapshot.developerProductivity;
  double get serverCapacity => _state.snapshot.serverCapacity;
  double get marketingScore => _state.snapshot.marketingScore;
  int get founderLevel => _state.snapshot.founderLevel;
  int get officeLevel => _state.snapshot.officeLevel;
  bool get darkMode => _state.snapshot.darkMode;
  bool get soundEnabled => _state.snapshot.soundEnabled;
  bool get autosaveEnabled => _state.snapshot.autosaveEnabled;
  double get prestigeCurrency => _state.snapshot.prestigeCurrency;
  bool get unicornStatus => cash >= 1000000 || founderLevel >= 12;
  bool get canPrestige => unicornStatus;
  double get prestigeMultiplier => 1 + (_state.snapshot.prestigeCurrency * 0.02);
  double get prestigeGainPreview => math.max(1, ((cash / 250000) + (users / 50000)).floor().toDouble());
  int get employeeLimit => _officeCatalogEntry.employeeLimit;
  double get totalRevenuePerSecond => _revenueHistory.isEmpty ? _currentRevenuePerSecond() : _revenueHistory.last;
  double get totalExpensePerSecond => _currentExpensePerSecond();
  double get profitPerSecond => totalRevenuePerSecond - totalExpensePerSecond;

  OfficeCatalogEntry get _officeCatalogEntry {
    final int tierIndex = math.max(0, math.min(snapshot.officeLevel - 1, officeCatalog.length - 1));
    return officeCatalog[tierIndex];
  }

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    _state = await gameRepository.loadState();
    _applyOfflineProgress();
    _recordSnapshots();
    notifyListeners();

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _advanceTick());

    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_state.snapshot.autosaveEnabled) {
        save();
      }
    });
  }

  void selectTab(int index) {
    if (index == selectedTabIndex) {
      return;
    }
    _state.snapshot = _state.snapshot.copyWith(selectedTabIndex: index);
    notifyListeners();
    save();
  }

  void startAppDevelopment(String appName) {
    final AppCatalogEntry? template = _findAppTemplate(appName);
    if (template == null || cash < template.baseCost) {
      return;
    }

    _evaluateAchievements();
    if (_state.apps.any((CompanyApp app) => app.name == template.name)) {
      return;
    }

    _state.snapshot = _state.snapshot.copyWith(cash: cash - template.baseCost);
    _state.apps = <CompanyApp>[
      ..._state.apps,
      CompanyApp(
        name: template.name,
        version: '0.1.0',
        developmentProgress: 0,
        rating: template.baseRating,
        bugCount: 3,
        users: 0,
        revenuePerSecond: 0,
        popularity: 0,
        maintenanceCost: template.maintenanceCost,
        lifetimeRevenue: 0,
      ),
    ];
    _addNotification('Started building ${template.name}.');
    notifyListeners();
    save();
  }

  void hireEmployee(String role) {
    final EmployeeCatalogEntry? template = _findEmployeeTemplate(role);
    if (template == null || cash < template.salary * 10) {
      return;
    }

    if (employees.length >= employeeLimit) {
      _addNotification('Office capacity reached. Upgrade the office first.');
      notifyListeners();
      return;
    }

    _state.snapshot = _state.snapshot.copyWith(cash: cash - (template.salary * 10));
    _state.employees = <Employee>[
      ..._state.employees,
      Employee(
        role: template.role,
        salary: template.salary,
        productivity: template.productivity,
        experience: 0,
        level: 1,
        upgradeCost: template.salary * 14,
        description: template.description,
      ),
    ];
    _addNotification('Hired a ${template.role}.');
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void startResearch(String topicName) {
    final int topicIndex = _state.researchTopics.indexWhere((ResearchTopic topic) => topic.name == topicName);
    if (topicIndex == -1) {
      return;
    }

    if (_state.snapshot.activeResearchIndex == topicIndex) {
      return;
    }

    _state.snapshot = _state.snapshot.copyWith(activeResearchIndex: topicIndex);
    _addNotification('Research started: ${_state.researchTopics[topicIndex].name}.');
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void buyServer() {
    final int nextIndex = math.min(_state.servers.length, serverCatalog.length - 1);
    final ServerCatalogEntry template = serverCatalog[nextIndex];
    if (cash < template.cost) {
      return;
    }

    _state.snapshot = _state.snapshot.copyWith(cash: cash - template.cost);
    _state.servers = <ServerNode>[
      ..._state.servers,
      ServerNode(
        name: template.name,
        capacity: template.capacity,
        maintenanceCost: template.maintenanceCost,
        powerUsage: template.powerUsage,
        level: nextIndex + 1,
      ),
    ];
    _addNotification('${template.name} added to the server stack.');
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void runMarketingCampaign(String appName) {
    final int appIndex = _state.apps.indexWhere((CompanyApp app) => app.name == appName);
    if (appIndex == -1) {
      return;
    }

    final CompanyApp app = _state.apps[appIndex];
    final double campaignCost = math.max(250, 120 + (app.users * 0.08) + (app.popularity * 18));
    if (cash < campaignCost || app.developmentProgress < 100) {
      return;
    }

    final int gainedUsers = math.max(25, (app.users * (0.05 + marketingScore * 0.006)).round());
    final List<CompanyApp> apps = List<CompanyApp>.from(_state.apps);
    apps[appIndex] = app.copyWith(
      users: app.users + gainedUsers,
      popularity: math.min(100, app.popularity + 4.5).toDouble(),
      lifetimeRevenue: app.lifetimeRevenue,
    );
    _state.apps = apps;
    _state.snapshot = _state.snapshot.copyWith(
      cash: cash - campaignCost,
      users: apps.fold<int>(0, (int total, CompanyApp entry) => total + entry.users),
      marketingScore: marketingScore + 0.8,
      reputation: math.min(100, reputation + 0.4).toDouble(),
    );
    _addNotification('Marketing campaign for ${app.name} gained $gainedUsers users.');
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void fixBugs(String appName) {
    final int appIndex = _state.apps.indexWhere((CompanyApp app) => app.name == appName);
    if (appIndex == -1) {
      return;
    }

    final CompanyApp app = _state.apps[appIndex];
    if (app.bugCount <= 0 || app.developmentProgress < 100) {
      return;
    }

    final double fixCost = math.max(120, app.bugCount * 90 + app.users * 0.015);
    if (cash < fixCost) {
      return;
    }

    final int fixedBugs = math.min(app.bugCount, math.max(1, 2 + _employeeCountMatching('QA Tester')));
    final List<CompanyApp> apps = List<CompanyApp>.from(_state.apps);
    apps[appIndex] = app.copyWith(
      bugCount: app.bugCount - fixedBugs,
      rating: math.min(100, app.rating + fixedBugs * 1.7).toDouble(),
    );
    _state.apps = apps;
    _state.snapshot = _state.snapshot.copyWith(
      cash: cash - fixCost,
      reputation: math.min(100, reputation + fixedBugs * 0.25).toDouble(),
    );
    _addNotification('Fixed $fixedBugs bugs in ${app.name}.');
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void shipFeatureUpdate(String appName) {
    final int appIndex = _state.apps.indexWhere((CompanyApp app) => app.name == appName);
    if (appIndex == -1) {
      return;
    }

    final CompanyApp app = _state.apps[appIndex];
    if (app.developmentProgress < 100) {
      return;
    }

    final double updateCost = math.max(400, app.users * 0.035 + app.popularity * 35);
    if (cash < updateCost) {
      return;
    }

    final int nextMinor = _minorVersion(app.version);
    final int gainedUsers = math.max(40, (app.users * 0.025 + developerProductivity * 12).round());
    final List<CompanyApp> apps = List<CompanyApp>.from(_state.apps);
    apps[appIndex] = app.copyWith(
      version: '1.${nextMinor + 1}.0',
      users: app.users + gainedUsers,
      rating: math.min(100, app.rating + 1.2).toDouble(),
      popularity: math.min(100, app.popularity + 2.2).toDouble(),
      bugCount: app.bugCount + math.max(1, (3 - _employeeCountMatching('QA Tester')).clamp(0, 3).toInt()),
    );
    _state.apps = apps;
    _state.snapshot = _state.snapshot.copyWith(
      cash: cash - updateCost,
      users: apps.fold<int>(0, (int total, CompanyApp entry) => total + entry.users),
      reputation: math.min(100, reputation + 0.8).toDouble(),
    );
    _addNotification('Shipped ${app.name} v1.${nextMinor + 1}.0 with $gainedUsers new users.');
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void upgradeOffice() {
    if (_state.snapshot.officeLevel >= officeCatalog.length) {
      return;
    }

    final OfficeCatalogEntry nextOffice = officeCatalog[_state.snapshot.officeLevel];
    if (cash < nextOffice.cost) {
      return;
    }

    _state.snapshot = _state.snapshot.copyWith(
      cash: cash - nextOffice.cost,
      officeLevel: snapshot.officeLevel + 1,
      reputation: math.min(100, reputation + 1.8),
    );
    _addNotification('Moved into the ${nextOffice.name}.');
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void toggleDarkMode() {
    _state.snapshot = _state.snapshot.copyWith(darkMode: !darkMode);
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void toggleSound() {
    _state.snapshot = _state.snapshot.copyWith(soundEnabled: !soundEnabled);
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void toggleAutosave() {
    _state.snapshot = _state.snapshot.copyWith(autosaveEnabled: !autosaveEnabled);
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  void clearWelcomeBackMessage() {
    _welcomeBackMessage = null;
    notifyListeners();
  }

  Future<void> resetGame() async {
    _state = CompanyState.initial();
    _revenueHistory.clear();
    _cashHistory.clear();
    _welcomeBackMessage = null;
    _evaluateAchievements();
    notifyListeners();
    await save();
  }

  Future<void> save() {
    _state.snapshot = _state.snapshot.copyWith(lastSaveTimestamp: DateTime.now());
    return gameRepository.saveState(_state);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _autosaveTimer?.cancel();
    super.dispose();
  }

  void _advanceTick({bool recordHistory = true, int seconds = 1}) {
    final int clampedSeconds = math.max(1, seconds);
    final double officeBonus = _officeCatalogEntry.productivityBonus;
    final double prestigeBonus = prestigeMultiplier;
    final int developerCount = _employeeCountMatching('Developer');
    final int researcherCount = _employeeCountMatching('Researcher');
    final int marketingCount = _employeeCountMatching('Marketing Manager');
    final int qaCount = _employeeCountMatching('QA Tester');
    final int devOpsCount = _employeeCountMatching('DevOps Engineer');
    final int productCount = _employeeCountMatching('Product Manager');
    final int hrCount = _employeeCountMatching('HR');

    double totalProductivity = _state.employees.fold<double>(0, (double total, Employee employee) => total + employee.productivity);
    totalProductivity += developerCount * 0.35 + devOpsCount * 0.18 + productCount * 0.14;
    totalProductivity *= officeBonus;
    totalProductivity *= prestigeBonus;
    totalProductivity += _state.snapshot.researchPoints * 0.015;
    final double developerPower = math.max(0.6, totalProductivity);
    final double researchPower = math.max(0.45, (researcherCount * 0.7) + (hrCount * 0.06) + 0.4);
    final double marketingPower = math.max(0.05, (marketingCount * 0.3) + (_state.snapshot.marketingScore * 0.02));

    final List<CompanyApp> updatedApps = <CompanyApp>[];
    for (final CompanyApp app in _state.apps) {
      final AppCatalogEntry template = _findAppTemplate(app.name) ?? appCatalog.first;
      CompanyApp nextApp = app;

      if (app.developmentProgress < 100) {
        final double developmentIncrease = developerPower * clampedSeconds * 0.42;
        final double progress = math.min(100, app.developmentProgress + developmentIncrease);
        final bool justReleased = progress >= 100;
        nextApp = nextApp.copyWith(developmentProgress: progress);
        if (justReleased && app.users == 0) {
          nextApp = nextApp.copyWith(
            users: template.baseUsers,
            rating: template.baseRating,
            popularity: 1,
            version: '1.0.0',
          );
          _addNotification('${app.name} is now live.');
        }
      } else {
        final double growthMultiplier = 1 + (reputation / 120) + (marketingPower * 0.5) + (founderLevel * 0.02);
        final double userGrowth = (template.baseUsers * 0.0035 + app.popularity * 2.5 + marketingPower * 1.5) * growthMultiplier * clampedSeconds;
        final int gainedUsers = userGrowth.floor();
        final double bugPressure = math.max(0, app.bugCount - qaCount).toDouble();
        final double ratingDelta = math.min(0.25, 0.01 + (qaCount * 0.01) - (bugPressure * 0.004));
        final double newRating = (app.rating + ratingDelta).clamp(0, 100).toDouble();
        final double revenuePerUser = 0.035 + (newRating * 0.0012);
        final int newUsers = math.max(0, app.users + gainedUsers);
        final double revenuePerSecond = (newUsers * revenuePerUser) - app.maintenanceCost;
        final double revenue = math.max(0, revenuePerSecond).toDouble() * clampedSeconds;
        final double popularity = math.min(100, app.popularity + (newUsers > app.users ? 0.15 : 0.03)).toDouble();
        final double lifetimeRevenue = app.lifetimeRevenue + revenue;
        final int bugCount = math.max(0, app.bugCount + ((developerCount + qaCount) > 0 ? -1 : 1));

        nextApp = nextApp.copyWith(
          users: newUsers,
          rating: newRating,
          revenuePerSecond: revenuePerSecond.clamp(0, double.infinity).toDouble(),
          popularity: popularity,
          lifetimeRevenue: lifetimeRevenue,
          bugCount: bugCount,
        );
      }

      updatedApps.add(nextApp);
    }

    _state.apps = updatedApps;

    final int totalUsers = _state.apps.fold<int>(0, (int total, CompanyApp app) => total + app.users);
    final double grossRevenuePerSecond = _currentRevenuePerSecond() * prestigeBonus;
    final double expensePerSecond = _currentExpensePerSecond();
    final double netPerSecond = grossRevenuePerSecond - expensePerSecond;
    final double updatedCash = cash + (netPerSecond * clampedSeconds);

    final double overloadPenalty = totalUsers > serverCapacity ? (totalUsers - serverCapacity) / serverCapacity : 0;
    final double reputationDelta = (overloadPenalty > 0 ? -1.3 * overloadPenalty : 0.08) * clampedSeconds;
    final double updatedReputation = (reputation + reputationDelta).clamp(5, 100);
    final double updatedResearchPoints = researchPoints + (researchPower * clampedSeconds * 0.85);
    final double updatedMarketingScore = marketingScore + (marketingPower * clampedSeconds * 0.12);
    final int updatedFounderLevel = math.max(1, 1 + (updatedCash ~/ 100000) + (totalUsers ~/ 20000));

    _state.snapshot = _state.snapshot.copyWith(
      cash: updatedCash,
      users: totalUsers,
      reputation: updatedReputation,
      researchPoints: updatedResearchPoints,
      developerProductivity: developerPower,
      serverCapacity: _currentServerCapacity().toDouble(),
      marketingScore: updatedMarketingScore,
      founderLevel: updatedFounderLevel,
    );

    _advanceResearch(clampedSeconds, researchPower);

    if (recordHistory) {
      _revenueHistory.add(grossRevenuePerSecond);
      _cashHistory.add(updatedCash);
      if (_revenueHistory.length > 120) {
        _revenueHistory.removeAt(0);
      }
      if (_cashHistory.length > 120) {
        _cashHistory.removeAt(0);
      }
    }

    if (updatedCash < 0 && _state.notifications.length < 20) {
      _addNotification('Cash is negative. Cut costs or ship a stronger app.');
    }

    _state.snapshot = _state.snapshot.copyWith(
      eventCooldownSeconds: math.max(0, _state.snapshot.eventCooldownSeconds - clampedSeconds),
    );

    _maybeTriggerRandomEvent();
    _evaluateAchievements();

    notifyListeners();
  }

  void _advanceResearch(int seconds, double researchPower) {
    final int activeIndex = _state.snapshot.activeResearchIndex;
    if (activeIndex < 0 || activeIndex >= _state.researchTopics.length) {
      return;
    }

    final ResearchTopic activeTopic = _state.researchTopics[activeIndex];
    if (activeTopic.unlocked) {
      return;
    }

    final double progress = math.min(100, activeTopic.progress + (researchPower * seconds * 1.5));
    final bool completed = progress >= 100;
    final List<ResearchTopic> topics = <ResearchTopic>[];

    for (int index = 0; index < _state.researchTopics.length; index++) {
      final ResearchTopic topic = _state.researchTopics[index];
      if (index == activeIndex) {
        topics.add(topic.copyWith(progress: progress, unlocked: completed));
      } else {
        topics.add(topic);
      }
    }

    _state.researchTopics = topics;

    if (completed) {
      _state.snapshot = _state.snapshot.copyWith(activeResearchIndex: -1, researchPoints: researchPoints + 50);
      _addNotification('Research complete: ${activeTopic.name}. ${activeTopic.description}');
    }
  }

  void _applyOfflineProgress() {
    final Duration elapsed = DateTime.now().difference(snapshot.lastSaveTimestamp);
    if (elapsed.inSeconds <= 3) {
      return;
    }

    final double cashBefore = cash;
    final int usersBefore = users;
    final double researchBefore = researchPoints;
    final int totalSeconds = math.min(elapsed.inSeconds, 6 * 60 * 60);
    int remainingSeconds = totalSeconds;

    while (remainingSeconds > 0) {
      final int chunk = math.min(60, remainingSeconds);
      _advanceTick(recordHistory: false, seconds: chunk);
      remainingSeconds -= chunk;
    }

    final double earnedCash = cash - cashBefore;
    final int gainedUsers = users - usersBefore;
    final double gainedResearch = researchPoints - researchBefore;
    _welcomeBackMessage = 'Welcome back. Away for ${_formatElapsed(elapsed)}. Earned ${_formatMoney(earnedCash)}, gained $gainedUsers users, +${gainedResearch.toStringAsFixed(0)} research.';
    _addNotification('Offline progress applied for ${_formatElapsed(elapsed)}.');
  }

  void _recordSnapshots() {
    _revenueHistory.add(_currentRevenuePerSecond());
    _cashHistory.add(cash);
  }

  void _addNotification(String message) {
    _state.notifications = <String>[message, ..._state.notifications].take(12).toList();
  }

  double _currentRevenuePerSecond() {
    return _state.apps.fold<double>(0, (double total, CompanyApp app) => total + math.max(0, app.revenuePerSecond));
  }

  double _currentExpensePerSecond() {
    final double salary = _state.employees.fold<double>(0, (double total, Employee employee) => total + (employee.salary / 3600));
    final double serverCost = _state.servers.fold<double>(0, (double total, ServerNode server) => total + (server.maintenanceCost / 3600));
    final double appMaintenance = _state.apps.fold<double>(0, (double total, CompanyApp app) => total + app.maintenanceCost);
    return salary + serverCost + appMaintenance;
  }

  int _currentServerCapacity() {
    return _state.servers.fold<int>(0, (int total, ServerNode server) => total + server.capacity) + (_state.snapshot.officeLevel * 220);
  }

  AppCatalogEntry? _findAppTemplate(String name) {
    for (final AppCatalogEntry entry in appCatalog) {
      if (entry.name == name) {
        return entry;
      }
    }
    return null;
  }

  EmployeeCatalogEntry? _findEmployeeTemplate(String role) {
    for (final EmployeeCatalogEntry entry in employeeCatalog) {
      if (entry.role == role) {
        return entry;
      }
    }
    return null;
  }

  int _employeeCountMatching(String query) {
    return _state.employees.where((Employee employee) => employee.role.contains(query)).length;
  }


  int _minorVersion(String version) {
    final List<String> parts = version.split('.');
    if (parts.length < 2) {
      return 0;
    }
    return int.tryParse(parts[1]) ?? 0;
  }

  String _formatMoney(double amount) {
    final String sign = amount >= 0 ? '' : '-';
    return '$sign\$${amount.abs().toStringAsFixed(0)}';
  }

  String _formatElapsed(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${duration.inMinutes}m';
  }

  void resolveActiveEventChoice(int choiceIndex) {
    final GameEventDefinition? event = activeEvent;
    if (event == null || choiceIndex < 0 || choiceIndex >= event.choices.length) {
      return;
    }

    final GameEventChoice choice = event.choices[choiceIndex];
    _state.snapshot = _state.snapshot.copyWith(
      cash: cash + choice.cashDelta,
      users: math.max(0, users + choice.usersDelta),
      reputation: (reputation + choice.reputationDelta).clamp(0, 100),
      researchPoints: math.max(0, researchPoints + choice.researchDelta),
      marketingScore: math.max(0, marketingScore + choice.marketingDelta),
    );
    if (choice.bugDelta != 0) {
      _state.apps = _state.apps
          .map(
            (CompanyApp app) => app.copyWith(bugCount: math.max(0, app.bugCount + choice.bugDelta)),
          )
          .toList();
    }

    _state.snapshot = _state.snapshot.copyWith(activeEventId: null, eventCooldownSeconds: 180);
    _addNotification(choice.notification);
    _evaluateAchievements();
    notifyListeners();
    save();
  }

  Future<void> prestige() async {
    if (!canPrestige) {
      return;
    }

    final double bonusGain = math.max(1, ((cash / 250000) + (users / 50000)).floor().toDouble());
    final double totalPrestigeCurrency = prestigeCurrency + bonusGain;
    final double keptResearchPoints = researchPoints;

    final List<ResearchTopic> keptResearch = _state.researchTopics;
    final List<String> keptAchievements = List<String>.from(_state.unlockedAchievementIds);

    _state = CompanyState.initial();
    _state.snapshot = _state.snapshot.copyWith(
      cash: 0,
      users: 0,
      reputation: 50,
      researchPoints: keptResearchPoints,
      founderLevel: founderLevel,
      selectedTabIndex: selectedTabIndex,
      officeLevel: 1,
      activeResearchIndex: -1,
      prestigeCurrency: totalPrestigeCurrency,
      activeEventId: null,
      eventCooldownSeconds: 120,
    );
    _state.researchTopics = keptResearch;
    _state.unlockedAchievementIds = keptAchievements;
    _state.apps = <CompanyApp>[];
    _state.servers = <ServerNode>[
      const ServerNode(name: 'Bedroom Laptop', capacity: 1500, maintenanceCost: 15, powerUsage: 2, level: 1),
    ];
    _state.employees = <Employee>[];
    _state.notifications = <String>[
      'Prestige complete. Permanent bonuses increased by ${bonusGain.toStringAsFixed(0)}.',
      ..._state.notifications,
    ].take(12).toList();
    _revenueHistory.clear();
    _cashHistory.clear();
    _welcomeBackMessage = null;
    _evaluateAchievements();
    notifyListeners();
    await save();
  }

  String exportSaveJson() {
    return jsonEncode(_state.toMap());
  }

  Future<void> importSaveJson(String jsonString) async {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map) {
      throw FormatException('Save data must be a JSON object.');
    }

    _state = CompanyState.fromMap(Map<dynamic, dynamic>.from(decoded));
    _welcomeBackMessage = null;
    _revenueHistory.clear();
    _cashHistory.clear();
    _recordSnapshots();
    _evaluateAchievements();
    notifyListeners();
    await save();
  }

  void _maybeTriggerRandomEvent() {
    if (_state.snapshot.activeEventId != null) {
      return;
    }

    if (_state.snapshot.eventCooldownSeconds > 0) {
      return;
    }

    if (_random.nextDouble() > 0.12) {
      return;
    }

    final GameEventDefinition event = randomEventCatalog[_random.nextInt(randomEventCatalog.length)];
    _state.snapshot = _state.snapshot.copyWith(
      activeEventId: event.id,
      eventCooldownSeconds: 240,
    );
    _addNotification('Event triggered: ${event.title}');
  }

  void _evaluateAchievements() {
    final Set<String> unlocked = _state.unlockedAchievementIds.toSet();
    for (final AchievementDefinition achievement in achievementCatalog) {
      if (unlocked.contains(achievement.id)) {
        continue;
      }

      if (_matchesAchievement(achievement)) {
        unlocked.add(achievement.id);
        _addNotification('Achievement unlocked: ${achievement.title}');
      }
    }
    _state.unlockedAchievementIds = unlocked.toList();
  }

  bool _matchesAchievement(AchievementDefinition achievement) {
    switch (achievement.id) {
      case 'first_cash_100':
        return cash >= 100;
      case 'first_employee':
        return employees.isNotEmpty;
      case 'users_100':
        return users >= 100;
      case 'users_10000':
        return users >= 10000;
      case 'millionaire':
        return cash >= 1000000;
      case 'apps_5':
        return apps.where((CompanyApp app) => app.developmentProgress >= 100).length >= 5;
      case 'first_ai':
        return apps.any((CompanyApp app) => app.name == 'AI Assistant' && app.developmentProgress >= 100);
      case 'first_data_center':
        return servers.any((ServerNode server) => server.name.contains('Data Center'));
      case 'employees_50':
        return employees.length >= 50;
      case 'prestige_1':
        return prestigeCurrency > 0;
      default:
        return false;
    }
  }
}
