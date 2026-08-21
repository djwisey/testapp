import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:new_test_app/models/workflow_models.dart';
import 'package:new_test_app/providers/business_provider.dart';
import 'package:new_test_app/screens/game_shell_screen.dart';
import 'package:new_test_app/services/timesheet_service.dart';

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

  test('starting and stopping a timer creates a valid timesheet entry', () {
    final BusinessProvider provider = BusinessProvider();
    final ActiveTimer? started = provider.startTimer(
      employeeId: 'emp-001',
      jobId: 'job-101',
      activity: 'Service',
    );

    expect(started, isNotNull);
    expect(provider.activeTimers, hasLength(1));

    final TimesheetEntry? stopped = provider.stopTimer(
      timer: started!,
      workType: 'Service',
      notes: 'Installed replacement part',
      billable: true,
      quantityHours: 1.5,
      billingRate: 95,
    );

    expect(stopped, isNotNull);
    expect(stopped!.employeeId, 'emp-001');
    expect(stopped.jobId, 'job-101');
    expect(stopped.durationMinutes, greaterThanOrEqualTo(0));
    expect(provider.timesheetEntries, hasLength(1));
  });

  test('duplicate active timers are prevented for the same employee', () {
    final TimesheetService service = TimesheetService();
    final List<ActiveTimer> timers = <ActiveTimer>[
      ActiveTimer(
        id: 'timer-1',
        employeeId: 'emp-001',
        jobId: 'job-101',
        startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        activity: 'General',
        notes: '',
      ),
    ];

    final ActiveTimer? nextTimer = service.startTimer(
      employeeId: 'emp-001',
      jobId: 'job-102',
      existingTimers: timers,
    );

    expect(nextTimer, isNull);
  });

  test('billing calculations follow quantity and rate', () {
    final TimesheetService service = TimesheetService();
    final double amount = service.calculateBillingAmount(
      quantityHours: 2.5,
      rate: 110,
    );
    expect(amount, 275);
  });
}
