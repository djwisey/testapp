import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/section_card.dart';

class AppFinanceScreen extends StatelessWidget {
  const AppFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        SectionCard(
          title: 'Finance',
          subtitle: 'Track the health of the company with live revenue and cash history.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Profit / second: \$${game.profitPerSecond.toStringAsFixed(1)}'),
              Text('Revenue / second: \$${game.totalRevenuePerSecond.toStringAsFixed(1)}'),
              Text('Expenses / second: \$${game.totalExpensePerSecond.toStringAsFixed(1)}'),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: CustomPaint(
                  painter: _FinanceChartPainter(game.revenueHistory, game.cashHistory),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinanceChartPainter extends CustomPainter {
  const _FinanceChartPainter(this.revenueHistory, this.cashHistory);

  final List<double> revenueHistory;
  final List<double> cashHistory;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = const Color(0x22334155)
      ..strokeWidth = 1;
    final Paint revenuePaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final Paint cashPaint = Paint()
      ..color = const Color(0xFF60A5FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < 4; index++) {
      final double y = size.height * (index / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    _drawSeries(canvas, size, revenueHistory, revenuePaint);
    _drawSeries(canvas, size, cashHistory, cashPaint);
  }

  void _drawSeries(Canvas canvas, Size size, List<double> values, Paint paint) {
    if (values.length < 2) {
      return;
    }

    final double maxValue = values.reduce((double a, double b) => a > b ? a : b);
    final double minValue = values.reduce((double a, double b) => a < b ? a : b);
    final double span = (maxValue - minValue).abs() < 0.01 ? 1 : maxValue - minValue;

    final Path path = Path();
    for (int index = 0; index < values.length; index++) {
      final double x = size.width * (index / (values.length - 1));
      final double normalized = (values[index] - minValue) / span;
      final double y = size.height - (normalized * size.height);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FinanceChartPainter oldDelegate) {
    return oldDelegate.revenueHistory != revenueHistory || oldDelegate.cashHistory != cashHistory;
  }
}
