class CompanyApp {
  const CompanyApp({
    required this.name,
    required this.version,
    required this.developmentProgress,
    required this.rating,
    required this.bugCount,
    required this.users,
    required this.revenuePerSecond,
    required this.popularity,
    required this.maintenanceCost,
    required this.lifetimeRevenue,
  });

  final String name;
  final String version;
  final double developmentProgress;
  final double rating;
  final int bugCount;
  final int users;
  final double revenuePerSecond;
  final double popularity;
  final double maintenanceCost;
  final double lifetimeRevenue;

  factory CompanyApp.fromMap(Map<dynamic, dynamic> map) {
    return CompanyApp(
      name: map['name']?.toString() ?? 'App',
      version: map['version']?.toString() ?? '1.0.0',
      developmentProgress: (map['developmentProgress'] as num?)?.toDouble() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 50,
      bugCount: (map['bugCount'] as num?)?.toInt() ?? 0,
      users: (map['users'] as num?)?.toInt() ?? 0,
      revenuePerSecond: (map['revenuePerSecond'] as num?)?.toDouble() ?? 0,
      popularity: (map['popularity'] as num?)?.toDouble() ?? 0,
      maintenanceCost: (map['maintenanceCost'] as num?)?.toDouble() ?? 0,
      lifetimeRevenue: (map['lifetimeRevenue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'version': version,
      'developmentProgress': developmentProgress,
      'rating': rating,
      'bugCount': bugCount,
      'users': users,
      'revenuePerSecond': revenuePerSecond,
      'popularity': popularity,
      'maintenanceCost': maintenanceCost,
      'lifetimeRevenue': lifetimeRevenue,
    };
  }

  CompanyApp copyWith({
    String? name,
    String? version,
    double? developmentProgress,
    double? rating,
    int? bugCount,
    int? users,
    double? revenuePerSecond,
    double? popularity,
    double? maintenanceCost,
    double? lifetimeRevenue,
  }) {
    return CompanyApp(
      name: name ?? this.name,
      version: version ?? this.version,
      developmentProgress: developmentProgress ?? this.developmentProgress,
      rating: rating ?? this.rating,
      bugCount: bugCount ?? this.bugCount,
      users: users ?? this.users,
      revenuePerSecond: revenuePerSecond ?? this.revenuePerSecond,
      popularity: popularity ?? this.popularity,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
      lifetimeRevenue: lifetimeRevenue ?? this.lifetimeRevenue,
    );
  }
}
