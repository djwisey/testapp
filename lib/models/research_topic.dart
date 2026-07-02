class ResearchTopic {
  const ResearchTopic({
    required this.name,
    required this.progress,
    required this.unlocked,
    required this.description,
  });

  final String name;
  final double progress;
  final bool unlocked;
  final String description;

  factory ResearchTopic.fromMap(Map<dynamic, dynamic> map) {
    return ResearchTopic(
      name: map['name']?.toString() ?? 'Research',
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      unlocked: map['unlocked'] as bool? ?? false,
      description: map['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'progress': progress,
      'unlocked': unlocked,
      'description': description,
    };
  }

  ResearchTopic copyWith({
    String? name,
    double? progress,
    bool? unlocked,
    String? description,
  }) {
    return ResearchTopic(
      name: name ?? this.name,
      progress: progress ?? this.progress,
      unlocked: unlocked ?? this.unlocked,
      description: description ?? this.description,
    );
  }
}
