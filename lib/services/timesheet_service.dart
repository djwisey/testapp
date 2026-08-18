import 'package:uuid/uuid.dart';

import '../models/workflow_models.dart';

class TimesheetService {
  TimesheetService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  ActiveTimer? startTimer({
    required String employeeId,
    required String jobId,
    String activity = 'General',
    String notes = '',
    List<ActiveTimer> existingTimers = const <ActiveTimer>[],
  }) {
    if (existingTimers.any((ActiveTimer timer) => timer.employeeId == employeeId && timer.jobId == jobId)) {
      return null;
    }

    if (existingTimers.any((ActiveTimer timer) => timer.employeeId == employeeId)) {
      return null;
    }

    return ActiveTimer(
      id: _uuid.v4(),
      employeeId: employeeId,
      jobId: jobId,
      startedAt: DateTime.now(),
      activity: activity,
      notes: notes,
    );
  }

  TimesheetEntry stopTimer({
    required ActiveTimer timer,
    required String employeeId,
    required String jobId,
    required DateTime endTime,
    String workType = 'General',
    String notes = '',
    bool billable = true,
    double quantityHours = 0,
    double billingRate = 0,
  }) {
    final int durationMinutes = endTime.difference(timer.startedAt).inMinutes.clamp(0, 24 * 60);
    final DateTime now = DateTime.now();
    return TimesheetEntry(
      id: _uuid.v4(),
      employeeId: employeeId,
      jobId: jobId,
      date: timer.startedAt,
      startTime: timer.startedAt,
      endTime: endTime,
      durationMinutes: durationMinutes,
      workType: workType,
      notes: notes,
      billable: billable,
      quantityHours: quantityHours > 0 ? quantityHours : durationMinutes / 60,
      billingRate: billingRate,
      approvalStatus: 'Pending',
      createdAt: now,
      modifiedAt: now,
    );
  }

  double calculateDurationHours({required DateTime start, required DateTime end}) {
    return end.difference(start).inMinutes / 60;
  }

  double calculateBillingAmount({required double quantityHours, required double rate}) {
    return quantityHours * rate;
  }

  double totalHoursForEntries(List<TimesheetEntry> entries) {
    return entries.fold<double>(0, (double total, TimesheetEntry entry) => total + entry.quantityHours);
  }

  bool hasDuplicateActiveTimer({required String employeeId, required List<ActiveTimer> activeTimers}) {
    return activeTimers.any((ActiveTimer timer) => timer.employeeId == employeeId);
  }
}
