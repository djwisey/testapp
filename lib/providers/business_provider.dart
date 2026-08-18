import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/workflow_models.dart';
import '../services/timesheet_service.dart';

class BusinessProvider extends ChangeNotifier {
  BusinessProvider({Uuid? uuid, TimesheetService? timesheetService})
      : _uuid = uuid ?? const Uuid(),
        _timesheetService = timesheetService ?? TimesheetService(uuid: uuid ?? const Uuid());

  final Uuid _uuid;
  final TimesheetService _timesheetService;

  Future<void> initialize() async {
    notifyListeners();
  }

  int selectedTabIndex = 0;
  bool isAuthenticated = false;

  final List<Role> roles = <Role>[
    const Role(
      id: 'employee',
      name: 'Employee',
      permissions: <Permission>{
        Permission.viewJobs,
        Permission.viewBilling,
      },
    ),
    const Role(
      id: 'manager',
      name: 'Manager',
      permissions: <Permission>{
        Permission.viewJobs,
        Permission.editJobs,
        Permission.approveTimesheets,
        Permission.viewBilling,
        Permission.manageEmployees,
      },
    ),
  ];

  User currentUser = const User(
    id: '',
    name: 'Guest',
    email: '',
    roleId: 'employee',
    permissions: <Permission>{Permission.viewJobs},
  );

  final List<Customer> customers = <Customer>[
    const Customer(
      id: 'cust-1',
      name: 'Perth City Council',
      contactName: 'Rachel Moore',
      phone: '0400 200 300',
      email: 'contracts@perth.wa.gov.au',
      address: '27 St Georges Terrace, Perth',
    ),
  ];

  final List<Employee> employees = <Employee>[
    const Employee(
      id: 'emp-001',
      name: 'Aiden Hart',
      email: 'worker@emnplant.com',
      roleId: 'employee',
      permissions: <Permission>{Permission.viewJobs, Permission.viewBilling},
      employeeNumber: 'EMP-001',
      department: 'Field Services',
      hireDate: null,
    ),
    const Employee(
      id: 'emp-002',
      name: 'Dylan Wiseman',
      email: 'dylan@emnplant.com',
      roleId: 'manager',
      permissions: <Permission>{
        Permission.viewJobs,
        Permission.editJobs,
        Permission.approveTimesheets,
        Permission.viewBilling,
        Permission.manageEmployees,
      },
      employeeNumber: 'EMP-002',
      department: 'Operations',
      hireDate: null,
    ),
  ];

  final List<Job> jobs = <Job>[
    Job(
      id: 'job-101',
      customerId: 'cust-1',
      referenceNumber: 'EMN-101',
      title: 'Excavation – Miller St',
      description: 'Site excavation for residential foundations.',
      siteAddress: '14 Miller St, Perth',
      status: 'In Progress',
      workflowStage: 'In Progress',
      scheduledDate: DateTime.now(),
      assignedEmployeeIds: <String>['emp-001', 'emp-002'],
      notes: '',
      billingStatus: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
    Job(
      id: 'job-102',
      customerId: 'cust-1',
      referenceNumber: 'EMN-102',
      title: 'Site Clearing – Eastern Ave',
      description: 'Clear and level site for new commercial development.',
      siteAddress: '88 Eastern Ave, Perth',
      status: 'Scheduled',
      workflowStage: 'Scheduled',
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
      assignedEmployeeIds: <String>['emp-001'],
      notes: '',
      billingStatus: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    Job(
      id: 'job-103',
      customerId: 'cust-1',
      referenceNumber: 'EMN-103',
      title: 'Trench Work – Riverside Dr',
      description: 'Trench excavation for stormwater drainage.',
      siteAddress: '33 Riverside Dr, Perth',
      status: 'Scheduled',
      workflowStage: 'New',
      scheduledDate: DateTime.now().add(const Duration(days: 5)),
      assignedEmployeeIds: <String>[],
      notes: 'Requires safety officer on site.',
      billingStatus: 'Pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Job(
      id: 'job-104',
      customerId: 'cust-1',
      referenceNumber: 'EMN-104',
      title: 'Machine Servicing – Workshop',
      description: 'Routine service and inspection for plant fleet.',
      siteAddress: 'EMN Workshop, Malaga',
      status: 'In Progress',
      workflowStage: 'In Progress',
      scheduledDate: DateTime.now(),
      assignedEmployeeIds: <String>['emp-002'],
      notes: '',
      billingStatus: 'Ready for review',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
    ),
  ];

  List<ActiveTimer> activeTimers = <ActiveTimer>[];
  List<TimesheetEntry> timesheetEntries = <TimesheetEntry>[];
  List<BillingEntry> billingEntries = <BillingEntry>[];

  void selectTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  bool signInWithCredentials(String email, String password) {
    const Map<String, List<String>> accounts = <String, List<String>>{
      'dylan@emnplant.com': <String>['EMNManager1', 'emp-002', 'Dylan Wiseman', 'manager'],
      'worker@emnplant.com': <String>['EMNWorker1', 'emp-001', 'Aiden Hart', 'employee'],
    };
    final List<String>? creds = accounts[email.toLowerCase().trim()];
    if (creds == null || creds[0] != password) return false;
    currentUser = User(
      id: creds[1],
      name: creds[2],
      email: email.toLowerCase().trim(),
      roleId: creds[3],
      permissions: creds[3] == 'manager'
          ? <Permission>{
              Permission.viewJobs,
              Permission.editJobs,
              Permission.approveTimesheets,
              Permission.viewBilling,
              Permission.manageEmployees,
            }
          : <Permission>{Permission.viewJobs, Permission.viewBilling},
    );
    isAuthenticated = true;
    selectedTabIndex = 0;
    notifyListeners();
    return true;
  }

  void signOut() {
    isAuthenticated = false;
    selectedTabIndex = 0;
    currentUser = const User(
      id: '',
      name: 'Guest',
      email: '',
      roleId: 'employee',
      permissions: <Permission>{Permission.viewJobs},
    );
    timesheetEntries = <TimesheetEntry>[];
    activeTimers = <ActiveTimer>[];
    billingEntries = <BillingEntry>[];
    notifyListeners();
  }

  void addManualEntry({
    required double hours,
    required DateTime date,
    required String jobId,
    String? customJobLabel,
    String notes = '',
  }) {
    final DateTime now = DateTime.now();
    final TimesheetEntry entry = TimesheetEntry(
      id: _uuid.v4(),
      employeeId: currentUser.id,
      jobId: jobId,
      date: date,
      startTime: date,
      endTime: date.add(Duration(minutes: (hours * 60).round())),
      durationMinutes: (hours * 60).round(),
      workType: customJobLabel ?? _jobTitle(jobId),
      notes: notes,
      billable: true,
      quantityHours: hours,
      billingRate: 0,
      approvalStatus: 'Pending',
      createdAt: now,
      modifiedAt: now,
      customJobLabel: customJobLabel,
    );
    timesheetEntries = <TimesheetEntry>[entry, ...timesheetEntries];
    notifyListeners();
  }

  String _jobTitle(String jobId) {
    for (final Job job in jobs) {
      if (job.id == jobId) return job.title;
    }
    return 'General';
  }

  bool hasPermission(Permission permission) {
    return currentUser.permissions.contains(permission);
  }

  bool canStartTimerForEmployee(String employeeId) {
    return activeTimers.every((ActiveTimer timer) => timer.employeeId != employeeId);
  }

  void signIn(User user) {
    currentUser = user;
    notifyListeners();
  }

  void assignEmployeeToJob(String jobId, String employeeId) {
    final int index = jobs.indexWhere((Job job) => job.id == jobId);
    if (index == -1) {
      return;
    }

    final Job job = jobs[index];
    final List<String> assigned = <String>[...job.assignedEmployeeIds];
    if (!assigned.contains(employeeId)) {
      assigned.add(employeeId);
      jobs[index] = Job(
        id: job.id,
        customerId: job.customerId,
        referenceNumber: job.referenceNumber,
        title: job.title,
        description: job.description,
        siteAddress: job.siteAddress,
        status: job.status,
        workflowStage: job.workflowStage,
        scheduledDate: job.scheduledDate,
        assignedEmployeeIds: assigned,
        notes: job.notes,
        billingStatus: job.billingStatus,
        createdAt: job.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
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

    if (timer == null) {
      return null;
    }

    activeTimers = <ActiveTimer>[...activeTimers, timer];
    notifyListeners();
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
    final DateTime endTime = DateTime.now();
    final TimesheetEntry entry = _timesheetService.stopTimer(
      timer: timer,
      employeeId: timer.employeeId,
      jobId: timer.jobId,
      endTime: endTime,
      workType: workType,
      notes: notes,
      billable: billable,
      quantityHours: quantityHours,
      billingRate: billingRate,
    );

    activeTimers = activeTimers.where((ActiveTimer active) => active.id != timer.id).toList();
    timesheetEntries = <TimesheetEntry>[entry, ...timesheetEntries];
    if (billable && billingRate > 0) {
      billingEntries = <BillingEntry>[
        BillingEntry(
          id: _uuid.v4(),
          jobId: timer.jobId,
          employeeId: timer.employeeId,
          label: workType,
          quantity: entry.quantityHours,
          rate: billingRate,
          amount: entry.quantityHours * billingRate,
          isBillable: true,
          notes: notes,
        ),
        ...billingEntries,
      ];
    }
    notifyListeners();
    return entry;
  }

  double totalHoursForEmployee(String employeeId) {
    return timesheetEntries
        .where((TimesheetEntry entry) => entry.employeeId == employeeId)
        .fold<double>(0, (double total, TimesheetEntry entry) => total + entry.quantityHours);
  }

  List<TimesheetEntry> entriesForJob(String jobId) {
    return timesheetEntries.where((TimesheetEntry entry) => entry.jobId == jobId).toList();
  }

  bool canViewBilling() => hasPermission(Permission.viewBilling);

  bool canApproveTimesheets() => hasPermission(Permission.approveTimesheets);
}
