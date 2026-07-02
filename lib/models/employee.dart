class Employee {
  const Employee({
    required this.role,
    required this.salary,
    required this.productivity,
    required this.experience,
    required this.level,
    required this.upgradeCost,
    required this.description,
  });

  final String role;
  final double salary;
  final double productivity;
  final double experience;
  final int level;
  final double upgradeCost;
  final String description;

  factory Employee.fromMap(Map<dynamic, dynamic> map) {
    return Employee(
      role: map['role']?.toString() ?? 'Employee',
      salary: (map['salary'] as num?)?.toDouble() ?? 0,
      productivity: (map['productivity'] as num?)?.toDouble() ?? 1,
      experience: (map['experience'] as num?)?.toDouble() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      upgradeCost: (map['upgradeCost'] as num?)?.toDouble() ?? 0,
      description: map['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'role': role,
      'salary': salary,
      'productivity': productivity,
      'experience': experience,
      'level': level,
      'upgradeCost': upgradeCost,
      'description': description,
    };
  }
}
