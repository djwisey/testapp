enum Permission { viewJobs, editJobs, approveTimesheets, manageEmployees }

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    required this.permissions,
  });

  final String id;
  final String name;
  final String email;
  final String roleId;
  final Set<Permission> permissions;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'email': email,
    'roleId': roleId,
    'permissions': permissions.map((Permission p) => p.name).toList(),
  };

  factory User.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawPermissions =
        map['permissions'] as List<dynamic>? ?? const <dynamic>[];
    return User(
      id: map['id']?.toString() ?? 'user',
      name: map['name']?.toString() ?? 'User',
      email: map['email']?.toString() ?? '',
      roleId: map['roleId']?.toString() ?? '',
      permissions: rawPermissions
          .map(
            (dynamic value) => Permission.values.firstWhere(
              (Permission permission) => permission.name == value.toString(),
              orElse: () => Permission.viewJobs,
            ),
          )
          .toSet(),
    );
  }
}

class Employee extends User {
  const Employee({
    required super.id,
    required super.name,
    required super.email,
    required super.roleId,
    required super.permissions,
    required this.jobTitle,
    this.active = true,
  });

  final String jobTitle;
  final bool active;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'email': email,
    'roleId': roleId,
    'permissions': permissions.map((Permission p) => p.name).toList(),
    'jobTitle': jobTitle,
    'active': active,
  };

  factory Employee.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawPermissions =
        map['permissions'] as List<dynamic>? ?? const <dynamic>[];
    return Employee(
      id: map['id']?.toString() ?? 'employee',
      name: map['name']?.toString() ?? 'Employee',
      email: map['email']?.toString() ?? '',
      roleId: map['roleId']?.toString() ?? '',
      permissions: rawPermissions
          .map(
            (dynamic value) => Permission.values.firstWhere(
              (Permission permission) => permission.name == value.toString(),
              orElse: () => Permission.viewJobs,
            ),
          )
          .toSet(),
      jobTitle: map['jobTitle']?.toString() ?? '',
      active: map['active'] as bool? ?? true,
    );
  }
}

class Job {
  const Job({
    required this.id,
    required this.referenceNumber,
    required this.title,
    required this.description,
    required this.siteAddress,
    required this.status,
    required this.scheduledDate,
    required this.assignedEmployeeIds,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String referenceNumber;
  final String title;
  final String description;
  final String siteAddress;
  final String status;
  final DateTime scheduledDate;
  final List<String> assignedEmployeeIds;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'referenceNumber': referenceNumber,
    'title': title,
    'description': description,
    'siteAddress': siteAddress,
    'status': status,
    'scheduledDate': scheduledDate.toIso8601String(),
    'assignedEmployeeIds': assignedEmployeeIds,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Job.fromMap(Map<String, dynamic> map) => Job(
    id: map['id']?.toString() ?? 'job',
    referenceNumber: map['referenceNumber']?.toString() ?? 'JOB-000',
    title: map['title']?.toString() ?? 'New Job',
    description: map['description']?.toString() ?? '',
    siteAddress: map['siteAddress']?.toString() ?? '',
    status: map['status']?.toString() ?? 'New',
    scheduledDate:
        DateTime.tryParse(map['scheduledDate']?.toString() ?? '') ??
        DateTime.now(),
    assignedEmployeeIds:
        ((map['assignedEmployeeIds'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic value) => value.toString())
            .toList(),
    notes: map['notes']?.toString() ?? '',
    createdAt:
        DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

class TimesheetEntry {
  const TimesheetEntry({
    required this.id,
    required this.employeeId,
    required this.jobId,
    required this.date,
    required this.workType,
    required this.notes,
    required this.quantityHours,
    required this.approvalStatus,
    required this.createdAt,
    required this.modifiedAt,
    this.startTime,
    this.endTime,
    this.breakHours = 0,
    this.customJobLabel,
  });

  final String id;
  final String employeeId;
  final String jobId;
  final DateTime date;
  final String workType;
  final String notes;
  final double quantityHours;
  final String approvalStatus;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final double breakHours;
  final String? customJobLabel;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'employeeId': employeeId,
    'jobId': jobId,
    'date': date.toIso8601String(),
    'workType': workType,
    'notes': notes,
    'quantityHours': quantityHours,
    'approvalStatus': approvalStatus,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'breakHours': breakHours,
    'customJobLabel': customJobLabel,
  };

  factory TimesheetEntry.fromMap(Map<String, dynamic> map) => TimesheetEntry(
    id: map['id']?.toString() ?? 'entry',
    employeeId: map['employeeId']?.toString() ?? '',
    jobId: map['jobId']?.toString() ?? '',
    date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
    workType: map['workType']?.toString() ?? 'General',
    notes: map['notes']?.toString() ?? '',
    quantityHours:
        double.tryParse(map['quantityHours']?.toString() ?? '0') ?? 0,
    approvalStatus: map['approvalStatus']?.toString() ?? 'Pending',
    createdAt:
        DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    modifiedAt:
        DateTime.tryParse(map['modifiedAt']?.toString() ?? '') ??
        DateTime.now(),
    startTime: DateTime.tryParse(map['startTime']?.toString() ?? ''),
    endTime: DateTime.tryParse(map['endTime']?.toString() ?? ''),
    breakHours: double.tryParse(map['breakHours']?.toString() ?? '0') ?? 0,
  );
}
