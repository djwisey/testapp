import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:emn_plant/providers/business_provider.dart';
import 'package:emn_plant/screens/workforce_shell_screen.dart';

void main() {
  testWidgets('workforce shell renders diary and job tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<BusinessProvider>(
        create: (_) => BusinessProvider(),
        child: const MaterialApp(home: WorkforceShellScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Diary'), findsWidgets);
    expect(find.text('Jobs'), findsWidgets);
    expect(find.text('Timesheet'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
