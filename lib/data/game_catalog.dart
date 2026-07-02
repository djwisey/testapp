class AppCatalogEntry {
  const AppCatalogEntry({
    required this.name,
    required this.baseCost,
    required this.baseRating,
    required this.baseUsers,
    required this.maintenanceCost,
    required this.description,
  });

  final String name;
  final double baseCost;
  final double baseRating;
  final int baseUsers;
  final double maintenanceCost;
  final String description;
}

class EmployeeCatalogEntry {
  const EmployeeCatalogEntry({
    required this.role,
    required this.salary,
    required this.productivity,
    required this.description,
    required this.unlockResearch,
  });

  final String role;
  final double salary;
  final double productivity;
  final String description;
  final String unlockResearch;
}

class ServerCatalogEntry {
  const ServerCatalogEntry({
    required this.name,
    required this.capacity,
    required this.maintenanceCost,
    required this.powerUsage,
    required this.cost,
  });

  final String name;
  final int capacity;
  final double maintenanceCost;
  final double powerUsage;
  final double cost;
}

class OfficeCatalogEntry {
  const OfficeCatalogEntry({
    required this.name,
    required this.employeeLimit,
    required this.productivityBonus,
    required this.cost,
  });

  final String name;
  final int employeeLimit;
  final double productivityBonus;
  final double cost;
}

class ResearchCatalogEntry {
  const ResearchCatalogEntry({
    required this.name,
    required this.description,
    required this.cost,
    required this.progressPerSecond,
    required this.unlockNote,
  });

  final String name;
  final String description;
  final double cost;
  final double progressPerSecond;
  final String unlockNote;
}

const List<AppCatalogEntry> appCatalog = <AppCatalogEntry>[
  AppCatalogEntry(name: 'Calculator', baseCost: 0, baseRating: 55, baseUsers: 120, maintenanceCost: 1.5, description: 'Simple utility app that proves the team can ship.'),
  AppCatalogEntry(name: 'Todo App', baseCost: 250, baseRating: 58, baseUsers: 160, maintenanceCost: 2, description: 'A practical productivity app for small teams.'),
  AppCatalogEntry(name: 'Weather App', baseCost: 750, baseRating: 62, baseUsers: 240, maintenanceCost: 3, description: 'Useful consumer app with recurring check-ins.'),
  AppCatalogEntry(name: 'Notes App', baseCost: 1200, baseRating: 66, baseUsers: 330, maintenanceCost: 4, description: 'Sticky notes, sync, and offline access.'),
  AppCatalogEntry(name: 'Messenger', baseCost: 3500, baseRating: 70, baseUsers: 550, maintenanceCost: 8, description: 'Chat platform with strong retention loops.'),
  AppCatalogEntry(name: 'Music Streaming', baseCost: 7000, baseRating: 72, baseUsers: 800, maintenanceCost: 12, description: 'Content-heavy platform with larger maintenance costs.'),
  AppCatalogEntry(name: 'Video Platform', baseCost: 14000, baseRating: 76, baseUsers: 1200, maintenanceCost: 18, description: 'Media engine that scales with brand and infrastructure.'),
  AppCatalogEntry(name: 'Search Engine', baseCost: 30000, baseRating: 80, baseUsers: 2000, maintenanceCost: 30, description: 'High-scale product with strong monetization potential.'),
  AppCatalogEntry(name: 'Cloud Platform', baseCost: 52000, baseRating: 84, baseUsers: 2600, maintenanceCost: 42, description: 'Enterprise software backbone with premium pricing.'),
  AppCatalogEntry(name: 'Game Engine', baseCost: 80000, baseRating: 88, baseUsers: 3500, maintenanceCost: 55, description: 'Developer tooling with long-tail revenue.'),
  AppCatalogEntry(name: 'Operating System', baseCost: 140000, baseRating: 92, baseUsers: 5000, maintenanceCost: 75, description: 'Massive platform play with deep ecosystem effects.'),
  AppCatalogEntry(name: 'AI Assistant', baseCost: 220000, baseRating: 95, baseUsers: 7000, maintenanceCost: 100, description: 'Cutting-edge product with very high upside.'),
];

const List<EmployeeCatalogEntry> employeeCatalog = <EmployeeCatalogEntry>[
  EmployeeCatalogEntry(role: 'Intern', salary: 120, productivity: 0.45, description: 'Low-cost helper who learns quickly.', unlockResearch: 'Programming'),
  EmployeeCatalogEntry(role: 'Junior Developer', salary: 240, productivity: 0.7, description: 'Entry-level engineer for routine implementation.', unlockResearch: 'Programming'),
  EmployeeCatalogEntry(role: 'Developer', salary: 420, productivity: 1, description: 'Solid generalist for day-to-day feature work.', unlockResearch: 'Programming'),
  EmployeeCatalogEntry(role: 'Senior Developer', salary: 820, productivity: 1.5, description: 'Experienced engineer for complex features.', unlockResearch: 'Programming'),
  EmployeeCatalogEntry(role: 'Lead Developer', salary: 1250, productivity: 2.1, description: 'Technical leader who improves team output.', unlockResearch: 'Management'),
  EmployeeCatalogEntry(role: 'QA Tester', salary: 320, productivity: 0.9, description: 'Reduces bugs and protects release quality.', unlockResearch: 'Security'),
  EmployeeCatalogEntry(role: 'UI Designer', salary: 360, productivity: 0.95, description: 'Improves product polish and retention.', unlockResearch: 'Mobile'),
  EmployeeCatalogEntry(role: 'Researcher', salary: 480, productivity: 1.1, description: 'Generates research points and unlocks new systems.', unlockResearch: 'AI'),
  EmployeeCatalogEntry(role: 'Marketing Manager', salary: 520, productivity: 1.2, description: 'Improves user acquisition and brand lift.', unlockResearch: 'Marketing'),
  EmployeeCatalogEntry(role: 'DevOps Engineer', salary: 760, productivity: 1.35, description: 'Improves infrastructure efficiency and uptime.', unlockResearch: 'Cloud'),
  EmployeeCatalogEntry(role: 'Product Manager', salary: 680, productivity: 1.25, description: 'Keeps features aligned with user demand.', unlockResearch: 'Management'),
  EmployeeCatalogEntry(role: 'HR', salary: 420, productivity: 0.8, description: 'Supports scaling the team sustainably.', unlockResearch: 'Management'),
  EmployeeCatalogEntry(role: 'CEO Assistant', salary: 900, productivity: 1.4, description: 'Removes friction for the founder and leadership.', unlockResearch: 'Automation'),
];

const List<ServerCatalogEntry> serverCatalog = <ServerCatalogEntry>[
  ServerCatalogEntry(name: 'Laptop', capacity: 400, maintenanceCost: 10, powerUsage: 1, cost: 0),
  ServerCatalogEntry(name: 'Gaming PC', capacity: 1200, maintenanceCost: 24, powerUsage: 2, cost: 2000),
  ServerCatalogEntry(name: 'Cheap VPS', capacity: 2600, maintenanceCost: 38, powerUsage: 2.5, cost: 5200),
  ServerCatalogEntry(name: 'Dedicated Server', capacity: 4200, maintenanceCost: 58, powerUsage: 3, cost: 11000),
  ServerCatalogEntry(name: 'Server Rack', capacity: 7600, maintenanceCost: 92, powerUsage: 4, cost: 24000),
  ServerCatalogEntry(name: 'Cloud Cluster', capacity: 13500, maintenanceCost: 150, powerUsage: 5.5, cost: 52000),
  ServerCatalogEntry(name: 'GPU Cluster', capacity: 21000, maintenanceCost: 240, powerUsage: 9, cost: 98000),
  ServerCatalogEntry(name: 'Small Data Center', capacity: 32000, maintenanceCost: 360, powerUsage: 13, cost: 175000),
  ServerCatalogEntry(name: 'Large Data Center', capacity: 52000, maintenanceCost: 600, powerUsage: 18, cost: 340000),
];

const List<OfficeCatalogEntry> officeCatalog = <OfficeCatalogEntry>[
  OfficeCatalogEntry(name: 'Bedroom', employeeLimit: 4, productivityBonus: 1, cost: 0),
  OfficeCatalogEntry(name: 'Garage', employeeLimit: 8, productivityBonus: 1.04, cost: 1800),
  OfficeCatalogEntry(name: 'Shared Office', employeeLimit: 14, productivityBonus: 1.08, cost: 6000),
  OfficeCatalogEntry(name: 'Small Office', employeeLimit: 24, productivityBonus: 1.12, cost: 18000),
  OfficeCatalogEntry(name: 'Startup Office', employeeLimit: 40, productivityBonus: 1.18, cost: 48000),
  OfficeCatalogEntry(name: 'Corporate Office', employeeLimit: 65, productivityBonus: 1.24, cost: 110000),
  OfficeCatalogEntry(name: 'Campus', employeeLimit: 100, productivityBonus: 1.32, cost: 260000),
  OfficeCatalogEntry(name: 'Tech Headquarters', employeeLimit: 160, productivityBonus: 1.4, cost: 620000),
  OfficeCatalogEntry(name: 'Skyscraper', employeeLimit: 240, productivityBonus: 1.5, cost: 1200000),
];

const List<ResearchCatalogEntry> researchCatalog = <ResearchCatalogEntry>[
  ResearchCatalogEntry(name: 'Programming', description: 'Improves developer output and release speed.', cost: 1200, progressPerSecond: 0.6, unlockNote: 'Unlocks better software output.'),
  ResearchCatalogEntry(name: 'AI', description: 'Unlocks smarter automation and premium products.', cost: 4200, progressPerSecond: 0.5, unlockNote: 'Unlocks AI products and assistants.'),
  ResearchCatalogEntry(name: 'Cloud', description: 'Reduces infrastructure friction and server costs.', cost: 5200, progressPerSecond: 0.5, unlockNote: 'Unlocks cloud tiers and DevOps boosts.'),
  ResearchCatalogEntry(name: 'Security', description: 'Lowers bug impact and improves trust.', cost: 3600, progressPerSecond: 0.55, unlockNote: 'Unlocks QA and security bonuses.'),
  ResearchCatalogEntry(name: 'Mobile', description: 'Improves consumer engagement and retention.', cost: 2400, progressPerSecond: 0.58, unlockNote: 'Unlocks mobile-first growth bonuses.'),
  ResearchCatalogEntry(name: 'Game Development', description: 'Helps you build interactive products faster.', cost: 2800, progressPerSecond: 0.56, unlockNote: 'Unlocks game-like product bonuses.'),
  ResearchCatalogEntry(name: 'Networking', description: 'Improves connectivity and product scale.', cost: 4600, progressPerSecond: 0.52, unlockNote: 'Unlocks multiplayer and sync systems.'),
  ResearchCatalogEntry(name: 'Hardware', description: 'Improves office and server efficiency.', cost: 5600, progressPerSecond: 0.48, unlockNote: 'Unlocks hardware-driven upgrades.'),
  ResearchCatalogEntry(name: 'Marketing', description: 'Increases user acquisition and virality.', cost: 1800, progressPerSecond: 0.62, unlockNote: 'Unlocks growth systems.'),
  ResearchCatalogEntry(name: 'Management', description: 'Improves scaling and employee limits.', cost: 2600, progressPerSecond: 0.6, unlockNote: 'Unlocks team scaling tools.'),
  ResearchCatalogEntry(name: 'Automation', description: 'Lets the startup run more smoothly on its own.', cost: 9200, progressPerSecond: 0.46, unlockNote: 'Unlocks automation and prestige bonuses.'),
];