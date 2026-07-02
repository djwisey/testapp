class ServerNode {
  const ServerNode({
    required this.name,
    required this.capacity,
    required this.maintenanceCost,
    required this.powerUsage,
    required this.level,
  });

  final String name;
  final int capacity;
  final double maintenanceCost;
  final double powerUsage;
  final int level;

  factory ServerNode.fromMap(Map<dynamic, dynamic> map) {
    return ServerNode(
      name: map['name']?.toString() ?? 'Server',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      maintenanceCost: (map['maintenanceCost'] as num?)?.toDouble() ?? 0,
      powerUsage: (map['powerUsage'] as num?)?.toDouble() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'capacity': capacity,
      'maintenanceCost': maintenanceCost,
      'powerUsage': powerUsage,
      'level': level,
    };
  }
}
