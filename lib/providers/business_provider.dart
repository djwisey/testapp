import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:uuid/uuid.dart';

import '../models/workflow_models.dart';
import '../services/pocketbase_service.dart';
import '../services/timesheet_service.dart';

class BusinessProvider extends ChangeNotifier {
  BusinessProvider({
    Uuid? uuid,
    TimesheetService? timesheetService,
    PocketBaseService? backend,
  })  : _uuid = uuid ?? const Uuid(),
        _timesheetService = timesheetService ?? TimesheetService(uuid: uuid ?? const Uuid()),
        _backend = backend ?? PocketBaseService();

  final Uuid _uuid;
  final TimesheetService _timesheetService;
  final PocketBaseService _backend;

  int selectedTabIndex = 0;
  bool isAuthenticated = false;
  bool isLoading = false;
  String? lastError;

  User currentUser = const User(
    id: '',
    name: 'Guest',
    email: '',
    roleId: 'employee',
    permissions: <Permission>{Permission.viewJobs},
  );

  List<Employee> employees = <Employee>[];
  List<Job> jobs = <Job>[];
  List<ActiveTimer> activeTimers = <ActiveTimer>[];
  List<TimesheetEntry> timesheetEntries = <TimesheetEntry>[];
  List<BillingEntry> billingEntries = <BillingEntry>[];

  // Retained for the existing timer unit tests. Timers are not persisted and are
  // no longer the primary timesheet workflow in the UI.
  final List<Customer> customers = <Customer>[
    const Customer(
      id: 'local-customer',
      name: 'EMN Plant Customer',
      contactName: '',
      phone: '',
      email: '',
      address: '',
    ),
  ];

  Future<void> initialize() async {
    // A fresh app starts on login. PocketBase auth can be made persistent later
    // without changing the repository/data abstraction introduced here.
    notifyListeners();
  }

  Set<Permission> _permissionsForRole(String role) => role == 'manager'
      ? <Permission>{
          Permission.viewJobs,
          Permission.editJobs,
          Permission.approveTimesheets,
          Permission.viewBilling,
          Permission.manageEmployees,
        }
      : <Permission>{Permission.viewJobs, Permission.viewBilling};

  User _userFromRecord(RecordModel record) {
    final String role = record.getStringValue('role', 'employee');
    return User(
      id: record.id,
      name: record.getStringValue('name', 'User'),
      email: record.getStringValue('email'),
      roleId: role,
      permissions: _permissionsForRole(role),
    );
  }

  Employee _employeeFromRecord(RecordModel record) {
    final String role = record.getStringValue('role', 'employee');
    return Employee(
      id: record.id,
      name: record.getStringValue('name', 'Employee'),
      email: record.getStringValue('email'),
      roleId: role,
      permissions: _permissionsForRole(role),
      jobTitle: record.getStringValue('job_title'),
      active: record.getBoolValue('active', true),
    );
  }

  Job _jobFromRecord(RecordModel record) {
    final DateTime now = DateTime.now();
    final String scheduled = record.getStringValue('scheduled_date');
    return Job(
      id: record.id,
      customerId: '',
      referenceNumber: record.getStringValue('reference'),
      title: record.getStringValue('title'),
      description: record.getStringValue('description'),
      siteAddress: record.getStringValue('site_address'),
      status: record.getStringValue('status', 'New'),
      workflowStage: record.getStringValue('status', 'New'),
      scheduledDate: DateTime.tryParse(scheduled)?.toLocal() ?? now,
      assignedEmployeeIds: record.getListValue<String>('assigned_employees'),
      notes: record.getStringValue('notes'),
      billingStatus: 'Pending',
      createdAt: DateTime.tryParse(record.created)?.toLocal() ?? now,
      updatedAt: DateTime.tryParse(record.updated)?.toLocal() ?? now,
    );
  }

  TimesheetEntry _timesheetFromRecord(RecordModel record) {
    final DateTime now = DateTime.now();
    final DateTime date = DateTime.tryParse(record.getStringValue('date'))?.toLocal() ?? now;
    final double hours = record.getDoubleValue('hours');
    final String approval = record.getStringValue('approval_status', 'pending');
    return TimesheetEntry(
      id: record.id,
      employeeId: record.getStringValue('employee'),
      jobId: record.getStringValue('job'),
      date: date,
      startTime: date,
      endTime: date.add(Duration(minutes: (hours * 60).round())),
      durationMinutes: (hours * 60).round(),
      workType: record.getStringValue('other_job'),
      notes: record.getStringValue('notes'),
      billable: true,
      quantityHours: hours,
      billingRate: 0,
      approvalStatus: approval.isEmpty
          ? 'Pending'
          : '${approval[0].toUpperCase()}${approval.substring(1)}',
      createdAt: DateTime.tryParse(record.created)?.toLocal() ?? now,
      modifiedAt: DateTime.tryParse(record.updated)?.toLocal() ?? now,
      customJobLabel: record.getStringValue('other_job').isEmpty
          ? null
          : record.getStringValue('other_job'),
    );
  }

  Future<bool> signInWithCredentials(String email, String password) async {
    isLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final RecordModel record = await _backend.signIn(email, password);
      currentUser = _userFromRecord(record);
      isAuthenticated = true;
      selectedTabIndex = 0;
      await refreshAll();
      return true;
    } on ClientException catch (error) {
      lastError = error.response['message']?.toString() ?? 'Invalid email or password.';
      isAuthenticated = false;
      return false;
    } catch (_) {
      lastError = 'Unable to connect to the EMN server. Check your internet connection.';
      isAuthenticated = false;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    if (!isAuthenticated) return;
    final List<Future<void>> tasks = <Future<void>>[
      refreshJobs(),
      refreshTimesheets(),
      if (hasPermission(Permission.manageEmployees)) refreshEmployees(),
    ];
    await Future.wait(tasks);
  }

  Future<void> refreshEmployees() async {
    if (!hasPermission(Permission.manageEmployees)) return;
    final records = await _backend.getUsers();
    employees = records.map(_employeeFromRecord).toList();
    notifyListeners();
  }

  Future<void> refreshJobs() async {
    final records = await _backend.getJobs();
    jobs = records.map(_jobFromRecord).toList();
    notifyListeners();
  }

  Future<void> refreshTimesheets() async {
    final records = await _backend.getTimesheets();
    timesheetEntries = records.map(_timesheetFromRecord).toList();
    notifyListeners();
  }

  void signOut() {
    _backend.signOut();
    isAuthenticated = false;
    selectedTabIndex = 0;
    currentUser = const User(
      id: '',
      name: 'Guest',
      email: '',
      roleId: 'employee',
      permissions: <Permission>{Permission.viewJobs},
    );
    employees = <Employee>[];
    jobs = <Job>[];
    timesheetEntries = <TimesheetEntry>[];
    activeTimers = <ActiveTimer>[];
    billingEntries = <BillingEntry>[];
    notifyListeners();
  }

  void selectTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> addManualEntry({
    required double hours,
    required DateTime date,
    required String jobId,
    String? customJobLabel,
    String notes = '',
  }) async {
    final RecordModel record = await _backend.createTimesheet(<String, dynamic>{
      'employee': currentUser.id,
      'job': jobId == 'other' ? '' : jobId,
      'other_job': customJobLabel?.trim() ?? '',
      'date': date.toUtc().toIso8601String(),
      'hours': hours,
      'notes': notes.trim(),
      'approval_status': 'pending',
    });
    timesheetEntries = <TimesheetEntry>[_timesheetFromRecord(record), ...timesheetEntries];
    notifyListeners();
  }

  String nextJobReference() {
    int max = 100;
    for (final Job job in jobs) {
      final int? num = int.tryParse(job.referenceNumber.replaceAll(RegExp(r'[^0-9]'), ''));
      if (num != null && num > max) max = num;
    }
    return 'EMN-${max + 1}';
  }

  Future<void> addJob({
    required String title,
    required String referenceNumber,
    required String siteAddress,
    String description = '',
    required DateTime scheduledDate,
    String status = 'New',
    String notes = '',
    List<String> assignedEmployeeIds = const <String>[],
  }) async {
    final record = await _backend.createJob(<String, dynamic>{
      'reference': referenceNumber.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'site_address': siteAddress.trim(),
      'status': status,
      'scheduled_date': scheduledDate.toUtc().toIso8601String(),
      'notes': notes.trim(),
      'active': true,
      'assigned_employees': assignedEmployeeIds,
      'created_by': currentUser.id,
    });
    jobs = <Job>[...jobs, _jobFromRecord(record)];
    notifyListeners();
  }

  Future<void> updateJob(Job updatedJob) async {
    final record = await _backend.updateJob(updatedJob.id, <String, dynamic>{
      'reference': updatedJob.referenceNumber,
      'title': updatedJob.title,
      'description': updatedJob.description,
      'site_address': updatedJob.siteAddress,
      'status': updatedJob.status,
      'scheduled_date': updatedJob.scheduledDate.toUtc().toIso8601String(),
      'notes': updatedJob.notes,
      'assigned_employees': updatedJob.assignedEmployeeIds,
    });
    final int index = jobs.indexWhere((Job job) => job.id == updatedJob.id);
    if (index >= 0) jobs[index] = _jobFromRecord(record);
    notifyListeners();
  }

  Future<void> deleteJob(String id) async {
    await _backend.deleteJob(id);
    jobs.removeWhere((Job job) => job.id == id);
    notifyListeners();
  }

  Future<void> approveEntry(String entryId) async {
    final record = await _backend.updateTimesheet(entryId, <String, dynamic>{
      'approval_status': 'approved',
      'approved_by': currentUser.id,
      'approved_at': DateTime.now().toUtc().toIso8601String(),
    });
    final int index = timesheetEntries.indexWhere((entry) => entry.id == entryId);
    if (index >= 0) timesheetEntries[index] = _timesheetFromRecord(record);
    notifyListeners();
  }

  Future<void> createWorker({
    required String name,
    required String email,
    required String password,
    String jobTitle = '',
  }) async {
    final record = await _backend.createWorker(
      name: name,
      email: email,
      password: password,
      jobTitle: jobTitle,
    );
    employees = <Employee>[...employees, _employeeFromRecord(record)]
      ..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> updateWorker(Employee employee) async {
    final record = await _backend.updateWorker(
      id: employee.id,
      name: employee.name,
      email: employee.email,
      active: employee.active,
      jobTitle: employee.jobTitle,
    );
    final int index = employees.indexWhere((item) => item.id == employee.id);
    if (index >= 0) employees[index] = _employeeFromRecord(record);
    notifyListeners();
  }

  Future<void> resetWorkerPassword(String employeeId, String password) =>
      _backend.resetWorkerPassword(employeeId, password);

  Future<void> deleteWorker(String employeeId) async {
    if (employeeId == currentUser.id) {
      throw StateError('You cannot delete your own account.');
    }
    if (timesheetEntries.any((entry) => entry.employeeId == employeeId)) {
      throw StateError('This worker has timesheet history. Disable the account instead of deleting it.');
    }
    await _backend.deleteWorker(employeeId);
    employees.removeWhere((employee) => employee.id == employeeId);
    notifyListeners();
  }

  bool hasPermission(Permission permission) => currentUser.permissions.contains(permission);

  String _jobTitle(String jobId) {
    for (final Job job in jobs) {
      if (job.id == jobId) return job.title;
    }
    return 'General';
  }

  bool canStartTimerForEmployee(String employeeId) =>
      activeTimers.every((ActiveTimer timer) => timer.employeeId != employeeId);

  void signIn(User user) {
    currentUser = user;
    notifyListeners();
  }

  void assignEmployeeToJob(String jobId, String employeeId) {
    final int index = jobs.indexWhere((Job job) => job.id == jobId);
    if (index < 0) return;
    final Job job = jobs[index];
    if (job.assignedEmployeeIds.contains(employeeId)) return;
    updateJob(Job(
      id: job.id,
      customerId: job.customerId,
      referenceNumber: job.referenceNumber,
      title: job.title,
      description: job.description,
      siteAddress: job.siteAddress,
      status: job.status,
      workflowStage: job.workflowStage,
      scheduledDate: job.scheduledDate,
      assignedEmployeeIds: <String>[...job.assignedEmployeeIds, employeeId],
      notes: job.notes,
      billingStatus: job.billingStatus,
      createdAt: job.createdAt,
      updatedAt: DateTime.now(),
    ));
  }

  ActiveTimer? startTimer({
    required String employeeId,
    required String jobId,
    String activity = 'General',
    String notes = '',
  }) {
    final ActiveTimer? timer = _timesheetService.startTimer(
      employeeId: employeeId,
      jobId: jobId,
      activity: activity,
      notes: notes,
      existingTimers: activeTimers,
    );
    if (timer != null) {
      activeTimers = <ActiveTimer>[...activeTimers, timer];
      notifyListeners();
    }
    return timer;
  }

  TimesheetEntry? stopTimer({
    required ActiveTimer timer,
    String workType = 'General',
    String notes = '',
    bool billable = true,
    double quantityHours = 0,
    double billingRate = 0,
  }) {
    final entry = _timesheetService.stopTimer(
      timer: timer,
      employeeId: timer.employeeId,
      jobId: timer.jobId,
      endTime: DateTime.now(),
      workType: workType,
      notes: notes,
      billable: billable,
      quantityHours: quantityHours,
      billingRate: billingRate,
    );
    activeTimers = activeTimers.where((active) => active.id != timer.id).toList();
    timesheetEntries = <TimesheetEntry>[entry, ...timesheetEntries];
    notifyListeners();
    return entry;
  }

  double totalHoursForEmployee(String employeeId) => timesheetEntries
      .where((entry) => entry.employeeId == employeeId)
      .fold<double>(0, (total, entry) => total + entry.quantityHours);

  List<TimesheetEntry> entriesForJob(String jobId) =>
      timesheetEntries.where((entry) => entry.jobId == jobId).toList();

  bool canViewBilling() => hasPermission(Permission.viewBilling);
  bool canApproveTimesheets() => hasPermission(Permission.approveTimesheets);
}
