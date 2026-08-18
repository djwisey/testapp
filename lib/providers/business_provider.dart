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
    id: 'emp-001',
    name: 'Aiden Hart',
    email: 'aiden@northline.local',
    roleId: 'employee',
    permissions: <Permission>{
      Permission.viewJobs,
      Permission.viewBilling,
    },
  );

  final List<Customer> customers = <Customer>[
    const Customer(
      id: 'cust-1',
      name: 'Northline Builders',
      contactName: 'Mina Ross',
      phone: '0400 111 222',
      email: 'mina@northline.com.au',
      address: '21 Riverside Ave, Perth',
    ),
  ];

  final List<Employee> employees = <Employee>[
    const Employee(
      id: 'emp-001',
      name: 'Aiden Hart',
      email: 'aiden@northline.local',
      roleId: 'employee',
      permissions: <Permission>{Permission.viewJobs, Permission.viewBilling},
      employeeNumber: 'EMP-001',
      department: 'Field Services',
      hireDate: null,
    ),
    const Employee(
      id: 'emp-002',
      name: 'Jordan Lee',
      email: 'jordan@northline.local',
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
      referenceNumber: 'JOB-101',
      title: 'Boiler service & check',
      description: 'Routine maintenance and efficiency inspection.',
      siteAddress: '21 Riverside Ave, Perth',
      status: 'Scheduled',
      workflowStage: 'Scheduled',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      assignedEmployeeIds: <String>['emp-001'],
      notes: 'Customer requires a morning service visit.',
      billingStatus: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    Job(
      id: 'job-102',
      customerId: 'cust-1',
      referenceNumber: 'JOB-102',
      title: 'Water pump replacement',
      description: 'Replace failed pump and verify system pressure.',
      siteAddress: '9 Tower Lane, Perth',
      status: 'In Progress',
      workflowStage: 'In Progress',
      scheduledDate: DateTime.now(),
      assignedEmployeeIds: <String>['emp-001', 'emp-002'],
      notes: 'Follow-up required after pressure test.',
      billingStatus: 'Ready for review',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
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
