class GameSnapshot {
  const GameSnapshot({
    required this.cash,
    required this.users,
    required this.reputation,
    required this.researchPoints,
    required this.developerProductivity,
    required this.serverCapacity,
    required this.marketingScore,
    required this.founderLevel,
    required this.selectedTabIndex,
    required this.officeLevel,
    required this.activeResearchIndex,
    required this.darkMode,
    required this.soundEnabled,
    required this.autosaveEnabled,
    required this.prestigeCurrency,
    required this.activeEventId,
    required this.eventCooldownSeconds,
    required this.lastSaveTimestamp,
  });

  final double cash;
  final int users;
  final double reputation;
  final double researchPoints;
  final double developerProductivity;
  final double serverCapacity;
  final double marketingScore;
  final int founderLevel;
  final int selectedTabIndex;
  final int officeLevel;
  final int activeResearchIndex;
  final bool darkMode;
  final bool soundEnabled;
  final bool autosaveEnabled;
  final double prestigeCurrency;
  final String? activeEventId;
  final int eventCooldownSeconds;
  final DateTime lastSaveTimestamp;

  factory GameSnapshot.initial() {
    return GameSnapshot(
      cash: 5000,
      users: 120,
      reputation: 55,
      researchPoints: 0,
      developerProductivity: 1,
      serverCapacity: 1500,
      marketingScore: 1,
      founderLevel: 1,
      selectedTabIndex: 0,
      officeLevel: 1,
      activeResearchIndex: -1,
      darkMode: true,
      soundEnabled: true,
      autosaveEnabled: true,
      prestigeCurrency: 0,
      activeEventId: null,
      eventCooldownSeconds: 90,
      lastSaveTimestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cash': cash,
      'users': users,
      'reputation': reputation,
      'researchPoints': researchPoints,
      'developerProductivity': developerProductivity,
      'serverCapacity': serverCapacity,
      'marketingScore': marketingScore,
      'founderLevel': founderLevel,
      'selectedTabIndex': selectedTabIndex,
      'officeLevel': officeLevel,
      'activeResearchIndex': activeResearchIndex,
      'darkMode': darkMode,
      'soundEnabled': soundEnabled,
      'autosaveEnabled': autosaveEnabled,
      'prestigeCurrency': prestigeCurrency,
      'activeEventId': activeEventId,
      'eventCooldownSeconds': eventCooldownSeconds,
      'lastSaveTimestamp': lastSaveTimestamp.toIso8601String(),
    };
  }

  factory GameSnapshot.fromMap(Map<dynamic, dynamic> map) {
    return GameSnapshot(
      cash: (map['cash'] as num?)?.toDouble() ?? 5000,
      users: (map['users'] as num?)?.toInt() ?? 120,
      reputation: (map['reputation'] as num?)?.toDouble() ?? 55,
      researchPoints: (map['researchPoints'] as num?)?.toDouble() ?? 0,
      developerProductivity: (map['developerProductivity'] as num?)?.toDouble() ?? 1,
      serverCapacity: (map['serverCapacity'] as num?)?.toDouble() ?? 1500,
      marketingScore: (map['marketingScore'] as num?)?.toDouble() ?? 1,
      founderLevel: (map['founderLevel'] as num?)?.toInt() ?? 1,
      selectedTabIndex: (map['selectedTabIndex'] as num?)?.toInt() ?? 0,
      officeLevel: (map['officeLevel'] as num?)?.toInt() ?? 1,
      activeResearchIndex: (map['activeResearchIndex'] as num?)?.toInt() ?? -1,
      darkMode: map['darkMode'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      autosaveEnabled: map['autosaveEnabled'] as bool? ?? true,
      prestigeCurrency: (map['prestigeCurrency'] as num?)?.toDouble() ?? 0,
      activeEventId: map['activeEventId']?.toString(),
      eventCooldownSeconds: (map['eventCooldownSeconds'] as num?)?.toInt() ?? 90,
      lastSaveTimestamp: DateTime.tryParse(map['lastSaveTimestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  GameSnapshot copyWith({
    double? cash,
    int? users,
    double? reputation,
    double? researchPoints,
    double? developerProductivity,
    double? serverCapacity,
    double? marketingScore,
    int? founderLevel,
    int? selectedTabIndex,
    int? officeLevel,
    int? activeResearchIndex,
    bool? darkMode,
    bool? soundEnabled,
    bool? autosaveEnabled,
    double? prestigeCurrency,
    String? activeEventId,
    int? eventCooldownSeconds,
    DateTime? lastSaveTimestamp,
  }) {
    return GameSnapshot(
      cash: cash ?? this.cash,
      users: users ?? this.users,
      reputation: reputation ?? this.reputation,
      researchPoints: researchPoints ?? this.researchPoints,
      developerProductivity: developerProductivity ?? this.developerProductivity,
      serverCapacity: serverCapacity ?? this.serverCapacity,
      marketingScore: marketingScore ?? this.marketingScore,
      founderLevel: founderLevel ?? this.founderLevel,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      officeLevel: officeLevel ?? this.officeLevel,
      activeResearchIndex: activeResearchIndex ?? this.activeResearchIndex,
      darkMode: darkMode ?? this.darkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autosaveEnabled: autosaveEnabled ?? this.autosaveEnabled,
      prestigeCurrency: prestigeCurrency ?? this.prestigeCurrency,
      activeEventId: activeEventId ?? this.activeEventId,
      eventCooldownSeconds: eventCooldownSeconds ?? this.eventCooldownSeconds,
      lastSaveTimestamp: lastSaveTimestamp ?? this.lastSaveTimestamp,
    );
  }
}
