import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/workflow_models.dart';
import '../services/pocketbase_service.dart';

enum AuthenticationState {
  unauthenticated,
  authenticating,
  authenticatedLoading,
  authenticatedReady,
  authenticatedDataError,
}

class BusinessProvider extends ChangeNotifier {
  BusinessProvider({PocketBaseService? backend})
    : _backend = backend ?? PocketBaseService();

  final PocketBaseService _backend;

  int selectedTabIndex = 0;
  bool isAuthenticated = false;
  bool isLoading = false;
  String? lastError;
  AuthenticationState authenticationState = AuthenticationState.unauthenticated;
  final Map<String, String> dataLoadErrors = <String, String>{};

  bool get isInitializing =>
      authenticationState == AuthenticationState.authenticating;
  bool get isDataLoading =>
      authenticationState == AuthenticationState.authenticatedLoading;
  bool get hasDataLoadErrors => dataLoadErrors.isNotEmpty;

  User currentUser = const User(
    id: '',
    name: 'Guest',
    email: '',
    roleId: 'employee',
    permissions: <Permission>{Permission.viewJobs},
  );

  List<Employee> employees = <Employee>[];
  List<Job> jobs = <Job>[];
  List<TimesheetEntry> timesheetEntries = <TimesheetEntry>[];

  Future<void> initialize() async {
    authenticationState = AuthenticationState.authenticating;
    notifyListeners();
    final RecordModel? record = _backend.authenticatedRecord;
    if (!_backend.isAuthenticated ||
        record == null ||
        !record.getBoolValue('active', true)) {
      if (record != null && !record.getBoolValue('active', true)) {
        _backend.signOut();
      }
      isAuthenticated = false;
      authenticationState = AuthenticationState.unauthenticated;
      notifyListeners();
      return;
    }

    currentUser = _userFromRecord(record);
    isAuthenticated = true;
    await refreshAll();
  }

  Set<Permission> _permissionsForRole(String role) => role == 'manager'
      ? <Permission>{
          Permission.viewJobs,
          Permission.editJobs,
          Permission.approveTimesheets,
          Permission.manageEmployees,
        }
      : <Permission>{Permission.viewJobs};

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
      referenceNumber: record.getStringValue('reference'),
      title: record.getStringValue('title'),
      description: record.getStringValue('description'),
      siteAddress: record.getStringValue('site_address'),
      status: record.getStringValue('status', 'New'),
      scheduledDate: DateTime.tryParse(scheduled)?.toLocal() ?? now,
      assignedEmployeeIds: record.getListValue<String>('assigned_employees'),
      notes: record.getStringValue('notes'),
      createdAt:
          DateTime.tryParse(record.get<String>('created'))?.toLocal() ?? now,
      updatedAt:
          DateTime.tryParse(record.get<String>('updated'))?.toLocal() ?? now,
    );
  }

  TimesheetEntry _timesheetFromRecord(RecordModel record) {
    final DateTime now = DateTime.now();
    final DateTime date =
        DateTime.tryParse(record.getStringValue('date'))?.toLocal() ?? now;
    final double hours = record.getDoubleValue('hours');
    final DateTime? startTime = DateTime.tryParse(
      record.getStringValue('start_time'),
    )?.toLocal();
    final DateTime? endTime = DateTime.tryParse(
      record.getStringValue('end_time'),
    )?.toLocal();
    final String approval = record.getStringValue('approval_status', 'pending');
    return TimesheetEntry(
      id: record.id,
      employeeId: record.getStringValue('employee'),
      jobId: record.getStringValue('job'),
      date: date,
      workType: record.getStringValue('other_job'),
      notes: record.getStringValue('notes'),
      quantityHours: hours,
      approvalStatus: approval.isEmpty
          ? 'Pending'
          : '${approval[0].toUpperCase()}${approval.substring(1)}',
      createdAt:
          DateTime.tryParse(record.get<String>('created'))?.toLocal() ?? now,
      modifiedAt:
          DateTime.tryParse(record.get<String>('updated'))?.toLocal() ?? now,
      startTime: startTime,
      endTime: endTime,
      breakHours: record.getDoubleValue('break_hours'),
      customJobLabel: record.getStringValue('other_job').isEmpty
          ? null
          : record.getStringValue('other_job'),
    );
  }

  Future<bool> signInWithCredentials(String email, String password) async {
    isLoading = true;
    lastError = null;
    dataLoadErrors.clear();
    authenticationState = AuthenticationState.authenticating;
    notifyListeners();
    try {
      final RecordModel record = await _backend.signIn(email, password);
      currentUser = _userFromRecord(record);
      isAuthenticated = true;
      selectedTabIndex = 0;
      authenticationState = AuthenticationState.authenticatedLoading;
      notifyListeners();
      await refreshAll();
      return true;
    } on ClientException catch (error) {
      debugPrint(
        'PocketBase users auth failed (${error.statusCode}): ${error.response['message']}',
      );
      lastError = error.statusCode == 400
          ? 'Incorrect email or password.'
          : 'Unable to connect to the EMN server.';
      isAuthenticated = false;
      authenticationState = AuthenticationState.unauthenticated;
      return false;
    } on StateError catch (error) {
      lastError = error.message.toString();
      isAuthenticated = false;
      authenticationState = AuthenticationState.unauthenticated;
      return false;
    } catch (error) {
      debugPrint('PocketBase users auth failed: ${error.runtimeType}');
      lastError = 'Unable to connect to the EMN server.';
      isAuthenticated = false;
      authenticationState = AuthenticationState.unauthenticated;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    if (!isAuthenticated) return;
    authenticationState = AuthenticationState.authenticatedLoading;
    dataLoadErrors.clear();
    notifyListeners();
    final List<Future<void>> tasks = <Future<void>>[
      _refreshSafely('jobs', refreshJobs),
      _refreshSafely('timesheets', refreshTimesheets),
      if (hasPermission(Permission.manageEmployees))
        _refreshSafely('workers', refreshEmployees),
    ];
    await Future.wait(tasks);
    authenticationState = dataLoadErrors.isEmpty
        ? AuthenticationState.authenticatedReady
        : AuthenticationState.authenticatedDataError;
    notifyListeners();
  }

  Future<void> _refreshSafely(
    String collection,
    Future<void> Function() load,
  ) async {
    try {
      await load();
    } on ClientException catch (error) {
      debugPrint(
        'PocketBase $collection list failed (${error.statusCode}): ${error.response['message']}',
      );
      dataLoadErrors[collection] = switch (error.statusCode) {
        400 =>
          'Unable to load $collection because the server collection configuration does not match the app.',
        401 ||
        403 => 'Your account does not have permission to load $collection.',
        _ => 'Unable to load $collection. Check your connection and try again.',
      };
    } catch (error) {
      debugPrint('PocketBase $collection list failed: ${error.runtimeType}');
      dataLoadErrors[collection] = 'Unable to load $collection.';
    }
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
    timesheetEntries = records.map(_timesheetFromRecord).toList()
      ..sort((TimesheetEntry a, TimesheetEntry b) {
        final int byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
      });
    notifyListeners();
  }

  void signOut() {
    _backend.signOut();
    isAuthenticated = false;
    isLoading = false;
    lastError = null;
    dataLoadErrors.clear();
    authenticationState = AuthenticationState.unauthenticated;
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
    notifyListeners();
  }

  void selectTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> addManualEntry({
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required double breakHours,
    required String jobId,
    String? customJobLabel,
    String notes = '',
  }) async {
    final double elapsedHours = endTime.difference(startTime).inMinutes / 60;
    if (elapsedHours <= 0) {
      throw ArgumentError('End time must be after start time.');
    }
    if (breakHours < 0 || breakHours >= elapsedHours) {
      throw ArgumentError('Break must be shorter than the shift.');
    }
    final double hours = elapsedHours - breakHours;
    final RecordModel record = await _backend.createTimesheet(<String, dynamic>{
      'employee': currentUser.id,
      'job': jobId == 'other' ? '' : jobId,
      'other_job': customJobLabel?.trim() ?? '',
      'date': date.toUtc().toIso8601String(),
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'break_hours': breakHours,
      'hours': hours,
      'notes': notes.trim(),
      'approval_status': 'pending',
    });
    timesheetEntries = <TimesheetEntry>[
      _timesheetFromRecord(record),
      ...timesheetEntries,
    ];
    notifyListeners();
  }

  String nextJobReference() {
    int max = 100;
    for (final Job job in jobs) {
      final int? num = int.tryParse(
        job.referenceNumber.replaceAll(RegExp(r'[^0-9]'), ''),
      );
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
    await reviewEntry(entryId, 'approved');
  }

  Future<void> rejectEntry(String entryId) async {
    await reviewEntry(entryId, 'rejected');
  }

  Future<void> reviewEntry(String entryId, String status) async {
    if (status != 'approved' && status != 'rejected') {
      throw ArgumentError.value(
        status,
        'status',
        'Must be approved or rejected.',
      );
    }
    final record = await _backend.updateTimesheet(entryId, <String, dynamic>{
      'approval_status': status,
      'approved_by': currentUser.id,
      'approved_at': DateTime.now().toUtc().toIso8601String(),
    });
    final int index = timesheetEntries.indexWhere(
      (entry) => entry.id == entryId,
    );
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
      throw StateError(
        'This worker has timesheet history. Disable the account instead of deleting it.',
      );
    }
    await _backend.deleteWorker(employeeId);
    employees.removeWhere((employee) => employee.id == employeeId);
    notifyListeners();
  }

  bool hasPermission(Permission permission) =>
      currentUser.permissions.contains(permission);
}
