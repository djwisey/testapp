class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

class GameEventChoice {
  const GameEventChoice({
    required this.label,
    required this.notification,
    this.cashDelta = 0,
    this.usersDelta = 0,
    this.reputationDelta = 0,
    this.researchDelta = 0,
    this.marketingDelta = 0,
    this.bugDelta = 0,
  });

  final String label;
  final String notification;
  final double cashDelta;
  final int usersDelta;
  final double reputationDelta;
  final double researchDelta;
  final double marketingDelta;
  final int bugDelta;
}

class GameEventDefinition {
  const GameEventDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
  });

  final String id;
  final String title;
  final String description;
  final List<GameEventChoice> choices;
}

const List<AchievementDefinition> achievementCatalog = <AchievementDefinition>[
  AchievementDefinition(id: 'first_cash_100', title: r'First $100', description: r'Reach $100 cash.'),
  AchievementDefinition(id: 'first_employee', title: 'First Employee', description: 'Hire your first employee.'),
  AchievementDefinition(id: 'users_100', title: '100 Users', description: 'Reach 100 users.'),
  AchievementDefinition(id: 'users_10000', title: '10,000 Users', description: 'Reach 10,000 users.'),
  AchievementDefinition(id: 'millionaire', title: 'Millionaire', description: r'Reach $1,000,000 cash.'),
  AchievementDefinition(id: 'apps_5', title: 'Release 5 Apps', description: 'Ship five software products.'),
  AchievementDefinition(id: 'first_ai', title: 'First AI Product', description: 'Build the AI Assistant product.'),
  AchievementDefinition(id: 'first_data_center', title: 'First Data Center', description: 'Buy your first data center.'),
  AchievementDefinition(id: 'employees_50', title: 'Hire 50 Employees', description: 'Grow the team to 50 employees.'),
  AchievementDefinition(id: 'prestige_1', title: 'Prestige Once', description: 'Prestige for the first time.'),
];

const List<GameEventDefinition> randomEventCatalog = <GameEventDefinition>[
  GameEventDefinition(
    id: 'investor_offer',
    title: 'Investor Offer',
    description: 'A local investor wants to fund your growth.',
    choices: <GameEventChoice>[
      GameEventChoice(label: 'Take the money', notification: 'You accepted investor funding.', cashDelta: 12000, reputationDelta: -1.5, marketingDelta: 3),
      GameEventChoice(label: 'Keep control', notification: 'You declined funding and stayed independent.', reputationDelta: 2, researchDelta: 20),
    ],
  ),
  GameEventDefinition(
    id: 'server_outage',
    title: 'Server Outage',
    description: 'Traffic spikes are causing service instability.',
    choices: <GameEventChoice>[
      GameEventChoice(label: 'Pay emergency fixes', notification: 'The outage was patched quickly.', cashDelta: -2000, reputationDelta: 2, bugDelta: -3),
      GameEventChoice(label: 'Ride it out', notification: 'The outage hurt trust and retention.', reputationDelta: -4, usersDelta: -180, bugDelta: 2),
    ],
  ),
  GameEventDefinition(
    id: 'developer_quits',
    title: 'Developer Quits',
    description: 'A developer leaves after feeling overloaded.',
    choices: <GameEventChoice>[
      GameEventChoice(label: 'Hire a replacement', notification: 'A new developer joined the team.', cashDelta: -800, reputationDelta: 1),
      GameEventChoice(label: 'Absorb the workload', notification: 'The team pushed through the setback.', researchDelta: 10, usersDelta: 20),
    ],
  ),
  GameEventDefinition(
    id: 'app_viral',
    title: 'App Goes Viral',
    description: 'One of your products is suddenly trending.',
    choices: <GameEventChoice>[
      GameEventChoice(label: 'Scale up fast', notification: 'The viral spike translated into revenue.', cashDelta: 8000, usersDelta: 1200, marketingDelta: 4),
      GameEventChoice(label: 'Stay cautious', notification: 'You slowed growth but kept things stable.', reputationDelta: 1.5, researchDelta: 30),
    ],
  ),
  GameEventDefinition(
    id: 'competitor_copy',
    title: 'Competitor Copies Feature',
    description: 'A competitor clones one of your ideas.',
    choices: <GameEventChoice>[
      GameEventChoice(label: 'Release a response', notification: 'You launched a better follow-up feature.', cashDelta: -1500, reputationDelta: 2.5, researchDelta: 35),
      GameEventChoice(label: 'Ignore them', notification: 'You focused on execution instead of the noise.', marketingDelta: 2, usersDelta: 80),
    ],
  ),
  GameEventDefinition(
    id: 'burnout',
    title: 'Employee Burnout',
    description: 'Your team needs support and balance.',
    choices: <GameEventChoice>[
      GameEventChoice(label: 'Give bonuses', notification: 'Morale recovered after the bonuses.', cashDelta: -1800, reputationDelta: 3, marketingDelta: 1),
      GameEventChoice(label: 'Push harder', notification: 'Burnout lingered and slowed the team.', reputationDelta: -2, bugDelta: 2),
    ],
  ),
  GameEventDefinition(
    id: 'conference',
    title: 'Tech Conference',
    description: 'A major industry conference invites your company.',
    choices: <GameEventChoice>[
      GameEventChoice(label: 'Sponsor a booth', notification: 'The booth generated new leads.', cashDelta: -1000, usersDelta: 350, marketingDelta: 3),
      GameEventChoice(label: 'Send the founder', notification: 'The founder made valuable connections.', reputationDelta: 2, researchDelta: 18),
    ],
  ),
];
