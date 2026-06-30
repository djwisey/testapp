import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const StartupIdleApp());
}

class StartupIdleApp extends StatelessWidget {
  const StartupIdleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Software Company Idle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F8A70)),
        scaffoldBackgroundColor: const Color(0xFFF2F5F7),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  final List<double> _revenueHistory = <double>[];

  Timer? _timer;

  double _cash = 5000;
  int _developers = 2;
  int _users = 120;
  int _activeApps = 1;
  int _bugs = 6;
  int _researchLevel = 0;
  int _serverLevel = 1;
  int _officeLevel = 1;

  double _reputation = 55;
  double _productProgress = 20;
  double _researchProgress = 0;
  bool _isResearching = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _maxDevelopers => 4 + (_officeLevel * 4);

  int get _serverCapacity => 800 + (_serverLevel * 1200) + (_officeLevel * 300);

  double get _hireCost => 1000 * pow(1.32, _developers - 1).toDouble();

  double get _researchCost => 3200 * pow(1.28, _researchLevel).toDouble();

  double get _serverUpgradeCost => 3800 * pow(1.45, _serverLevel - 1).toDouble();

  double get _officeUpgradeCost => 6000 * pow(1.55, _officeLevel - 1).toDouble();

  void _tick() {
    final double overload = max(0, _users - _serverCapacity) / _serverCapacity;

    final double devOutput = _developers * (1 + (_researchLevel * 0.08));
    final double bugPenalty = (_bugs * 0.006).clamp(0.0, 0.55);
    _productProgress += devOutput * (1 - bugPenalty) * 1.9;
    _productProgress = _productProgress.clamp(0, 100);

    if (_isResearching) {
      _researchProgress += 2.8 + (_developers * 0.2);
      if (_researchProgress >= 100) {
        _researchProgress = 0;
        _isResearching = false;
        _researchLevel += 1;
        _reputation = (_reputation + 2.0).clamp(0, 100);
      }
    }

    final double revenuePerUser = 0.08 + (_activeApps * 0.01);
    final int servedUsers = min(_users, _serverCapacity);
    final double qualityMultiplier = 1 + (_researchLevel * 0.04);
    final double bugRevenuePenalty = 1 - (_bugs * 0.003).clamp(0.0, 0.35);
    final double revenue = servedUsers * revenuePerUser * qualityMultiplier * bugRevenuePenalty;

    final int organicGrowth =
        ((4 + (_activeApps * 2) + (_reputation * 0.08) + (_researchLevel * 1.5)).round());
    final int churn = (_users * ((_bugs * 0.00065) + (overload * 0.015))).round();

    _users = max(0, _users + organicGrowth - churn);
    _cash += revenue;

    if (_activeApps > 0) {
      _bugs += (_activeApps * 0.12 + overload * 1.3).floor();
    }
    _bugs = _bugs.clamp(0, 9999);

    if (overload > 0) {
      _reputation -= overload * 1.3;
    } else {
      _reputation += 0.1;
    }
    _reputation = _reputation.clamp(5, 100);

    _revenueHistory.add(revenue);
    if (_revenueHistory.length > 36) {
      _revenueHistory.removeAt(0);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _hireDeveloper() {
    final double price = _hireCost;
    if (_cash < price || _developers >= _maxDevelopers) {
      return;
    }
    setState(() {
      _cash -= price;
      _developers += 1;
    });
  }

  void _startResearch() {
    final double price = _researchCost;
    if (_cash < price || _isResearching) {
      return;
    }
    setState(() {
      _cash -= price;
      _isResearching = true;
      _researchProgress = 0;
    });
  }

  void _releaseApp() {
    if (_productProgress < 100) {
      return;
    }

    final double qualityScore = (40 +
            (_researchLevel * 7) +
            (_developers * 2.2) +
            (_serverLevel * 3.5) +
            (_reputation * 0.25) -
            (_bugs * 0.35))
        .clamp(8, 160);

    final int gainedUsers = (qualityScore * 14 + _random.nextInt(350)).round();
    final int launchBugs = max(1, (24 - qualityScore * 0.1 + _random.nextInt(12)).round());

    setState(() {
      _activeApps += 1;
      _users += gainedUsers;
      _bugs += launchBugs;
      _cash += 1000 + (qualityScore * 16);
      _reputation = (_reputation + (qualityScore > 85 ? 2.4 : 0.6)).clamp(0, 100);
      _productProgress = 0;
    });
  }

  void _fixBugs() {
    if (_bugs == 0 || _cash < 450) {
      return;
    }

    final int fixes = (2 + (_developers * 0.8) + (_researchLevel * 0.7)).round();
    setState(() {
      _cash -= 450;
      _bugs = max(0, _bugs - fixes);
      _reputation = (_reputation + 0.8).clamp(0, 100);
    });
  }

  void _upgradeServers() {
    final double price = _serverUpgradeCost;
    if (_cash < price) {
      return;
    }
    setState(() {
      _cash -= price;
      _serverLevel += 1;
    });
  }

  void _buyOffice() {
    final double price = _officeUpgradeCost;
    if (_cash < price) {
      return;
    }
    setState(() {
      _cash -= price;
      _officeLevel += 1;
      _reputation = (_reputation + 1.6).clamp(0, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canHire = _cash >= _hireCost && _developers < _maxDevelopers;
    final bool canResearch = _cash >= _researchCost && !_isResearching;
    final bool canRelease = _productProgress >= 100;
    final bool canFix = _cash >= 450 && _bugs > 0;
    final bool canServer = _cash >= _serverUpgradeCost;
    final bool canOffice = _cash >= _officeUpgradeCost;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFEAF4F3), Color(0xFFF7FAFC), Color(0xFFE6EEF5)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 850;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildTopBanner(),
                        const SizedBox(height: 12),
                        _buildKeyMetrics(),
                        const SizedBox(height: 12),
                        if (compact) ...<Widget>[
                          _buildActionsCard(
                            canHire: canHire,
                            canResearch: canResearch,
                            canRelease: canRelease,
                            canFix: canFix,
                            canServer: canServer,
                            canOffice: canOffice,
                          ),
                          const SizedBox(height: 12),
                          _buildProductionCard(),
                          const SizedBox(height: 12),
                          _buildRevenueChartCard(),
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: _buildActionsCard(
                                  canHire: canHire,
                                  canResearch: canResearch,
                                  canRelease: canRelease,
                                  canFix: canFix,
                                  canServer: canServer,
                                  canOffice: canOffice,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: <Widget>[
                                    _buildProductionCard(),
                                    const SizedBox(height: 12),
                                    _buildRevenueChartCard(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return _panel(
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1F8A70),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.corporate_fare, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Software Company Idle',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Run dashboards, ship apps, grow your startup empire.',
                  style: TextStyle(color: Colors.blueGrey.shade700),
                ),
              ],
            ),
          ),
          Text(
            'Office L$_officeLevel',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        _metricTile('Cash', '\$${_cash.toStringAsFixed(0)}', Icons.account_balance_wallet),
        _metricTile('Users', _users.toString(), Icons.people),
        _metricTile('Developers', '$_developers / $_maxDevelopers', Icons.code),
        _metricTile('Live Apps', _activeApps.toString(), Icons.apps),
        _metricTile('Open Bugs', _bugs.toString(), Icons.bug_report),
        _metricTile('Server Cap', _serverCapacity.toString(), Icons.dns),
      ],
    );
  }

  Widget _metricTile(String label, String value, IconData icon) {
    return SizedBox(
      width: 182,
      child: _panel(
        child: Row(
          children: <Widget>[
            Icon(icon, color: const Color(0xFF1F8A70)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700)),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard({
    required bool canHire,
    required bool canResearch,
    required bool canRelease,
    required bool canFix,
    required bool canServer,
    required bool canOffice,
  }) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Company Actions', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _actionButton(
            icon: Icons.person_add,
            label: 'Hire Developer',
            subtitle: 'Cost: \$${_hireCost.toStringAsFixed(0)}',
            enabled: canHire,
            onPressed: _hireDeveloper,
          ),
          _actionButton(
            icon: Icons.science,
            label: _isResearching ? 'Researching...' : 'Research Technologies',
            subtitle: _isResearching
                ? 'Progress: ${_researchProgress.toStringAsFixed(0)}%'
                : 'Cost: \$${_researchCost.toStringAsFixed(0)}',
            enabled: canResearch,
            onPressed: _startResearch,
          ),
          _actionButton(
            icon: Icons.rocket_launch,
            label: 'Release App',
            subtitle: 'Requires 100% product readiness',
            enabled: canRelease,
            onPressed: _releaseApp,
          ),
          _actionButton(
            icon: Icons.build,
            label: 'Fix Bugs',
            subtitle: 'Cost: \$450 and engineering time',
            enabled: canFix,
            onPressed: _fixBugs,
          ),
          _actionButton(
            icon: Icons.storage,
            label: 'Upgrade Servers',
            subtitle: 'Cost: \$${_serverUpgradeCost.toStringAsFixed(0)}',
            enabled: canServer,
            onPressed: _upgradeServers,
          ),
          _actionButton(
            icon: Icons.business,
            label: 'Buy Office',
            subtitle: 'Cost: \$${_officeUpgradeCost.toStringAsFixed(0)}',
            enabled: canOffice,
            onPressed: _buyOffice,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FilledButton.tonalIcon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon),
        label: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductionCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Pipeline Dashboard', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _progressLine('Product Readiness', _productProgress / 100, Colors.teal),
          const SizedBox(height: 10),
          _progressLine(
            'Research Level $_researchLevel',
            _isResearching ? _researchProgress / 100 : 0,
            Colors.indigo,
          ),
          const SizedBox(height: 10),
          _progressLine('Reputation', _reputation / 100, Colors.orange),
          const SizedBox(height: 10),
          _progressLine(
            'Infrastructure Load',
            (_users / _serverCapacity).clamp(0, 1),
            Colors.red,
          ),
          const SizedBox(height: 8),
          Text(
            'Server level: $_serverLevel, office level: $_officeLevel',
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _progressLine(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 10,
            color: color,
            backgroundColor: color.withAlpha(35),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChartCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Revenue Trend (per second)',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: _MiniChartPainter(_revenueHistory),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCEDAE3), width: 1),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  _MiniChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axisPaint = Paint()
      ..color = const Color(0xFFD4DEE6)
      ..strokeWidth = 1;

    final Paint linePaint = Paint()
      ..color = const Color(0xFF1F8A70)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0x661F8A70), Color(0x001F8A70)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint);

    if (values.length < 2) {
      return;
    }

    final double maxValue = values.reduce(max);
    final double minValue = values.reduce(min);
    final double span = (maxValue - minValue).abs() < 0.01 ? 1 : (maxValue - minValue);

    final Path linePath = Path();
    final Path fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final double x = size.width * (i / (values.length - 1));
      final double normalized = (values[i] - minValue) / span;
      final double y = size.height - ((normalized * (size.height - 8)) + 4);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
