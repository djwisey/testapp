import 'company_app.dart';
import 'employee.dart';
import 'research_topic.dart';
import 'server_node.dart';
import 'game_snapshot.dart';

class CompanyState {
  CompanyState({
    required this.snapshot,
    required this.apps,
    required this.employees,
    required this.servers,
    required this.researchTopics,
    required this.notifications,
    required this.unlockedAchievementIds,
  });

  GameSnapshot snapshot;
  List<CompanyApp> apps;
  List<Employee> employees;
  List<ServerNode> servers;
  List<ResearchTopic> researchTopics;
  List<String> notifications;
  List<String> unlockedAchievementIds;

  factory CompanyState.initial() {
    return CompanyState(
      snapshot: GameSnapshot.initial(),
      apps: <CompanyApp>[
        const CompanyApp(
          name: 'Calculator',
          version: '1.0.0',
          developmentProgress: 100,
          rating: 65,
          bugCount: 4,
          users: 120,
          revenuePerSecond: 8,
          popularity: 1,
          maintenanceCost: 1.5,
          lifetimeRevenue: 0,
        ),
      ],
      employees: const <Employee>[],
      servers: <ServerNode>[
        const ServerNode(name: 'Bedroom Laptop', capacity: 1500, maintenanceCost: 15, powerUsage: 2, level: 1),
      ],
      researchTopics: const <ResearchTopic>[
        ResearchTopic(name: 'Programming', progress: 0, unlocked: true, description: 'Improve code output and product speed.'),
        ResearchTopic(name: 'AI', progress: 0, unlocked: false, description: 'Unlock smarter automation and features.'),
      ],
      notifications: <String>['Welcome to Startup Empire'],
      unlockedAchievementIds: <String>[],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'snapshot': snapshot.toMap(),
      'apps': apps.map((CompanyApp app) => app.toMap()).toList(),
      'employees': employees.map((Employee employee) => employee.toMap()).toList(),
      'servers': servers.map((ServerNode server) => server.toMap()).toList(),
      'researchTopics': researchTopics.map((ResearchTopic topic) => topic.toMap()).toList(),
      'notifications': notifications,
      'unlockedAchievementIds': unlockedAchievementIds,
    };
  }

  factory CompanyState.fromMap(Map<dynamic, dynamic> map) {
    return CompanyState(
      snapshot: GameSnapshot.fromMap(Map<dynamic, dynamic>.from(map['snapshot'] as Map? ?? <String, dynamic>{})),
      apps: ((map['apps'] as List?) ?? <dynamic>[])
          .map((dynamic entry) => CompanyApp.fromMap(Map<dynamic, dynamic>.from(entry as Map)))
          .toList(),
      employees: ((map['employees'] as List?) ?? <dynamic>[])
          .map((dynamic entry) => Employee.fromMap(Map<dynamic, dynamic>.from(entry as Map)))
          .toList(),
      servers: ((map['servers'] as List?) ?? <dynamic>[])
          .map((dynamic entry) => ServerNode.fromMap(Map<dynamic, dynamic>.from(entry as Map)))
          .toList(),
      researchTopics: ((map['researchTopics'] as List?) ?? <dynamic>[])
          .map((dynamic entry) => ResearchTopic.fromMap(Map<dynamic, dynamic>.from(entry as Map)))
          .toList(),
      notifications: ((map['notifications'] as List?) ?? <dynamic>[]).map((dynamic entry) => entry.toString()).toList(),
      unlockedAchievementIds: ((map['unlockedAchievementIds'] as List?) ?? <dynamic>[]).map((dynamic entry) => entry.toString()).toList(),
    );
  }
}
