enum Permission {
  viewJobs,
  editJobs,
  approveTimesheets,
  viewBilling,
  manageEmployees,
}

class Role {
  const Role({
    required this.id,
    required this.name,
    required this.permissions,
  });

  final String id;
  final String name;
  final Set<Permission> permissions;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'permissions': permissions.map((Permission p) => p.name).toList(),
      };

  factory Role.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawPermissions = map['permissions'] as List<dynamic>? ?? const <dynamic>[];
    return Role(
      id: map['id']?.toString() ?? 'role',
      name: map['name']?.toString() ?? 'Role',
      permissions: rawPermissions
          .map((dynamic value) => Permission.values.firstWhere(
                (Permission permission) => permission.name == value.toString(),
                orElse: () => Permission.viewJobs,
              ))
          .toSet(),
    );
  }
}

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
    final List<dynamic> rawPermissions = map['permissions'] as List<dynamic>? ?? const <dynamic>[];
    return User(
      id: map['id']?.toString() ?? 'user',
      name: map['name']?.toString() ?? 'User',
      email: map['email']?.toString() ?? '',
      roleId: map['roleId']?.toString() ?? '',
      permissions: rawPermissions
          .map((dynamic value) => Permission.values.firstWhere(
                (Permission permission) => permission.name == value.toString(),
                orElse: () => Permission.viewJobs,
              ))
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
    required this.employeeNumber,
    required this.department,
    this.hireDate,
  });

  final String employeeNumber;
  final String department;
  final DateTime? hireDate;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'roleId': roleId,
        'permissions': permissions.map((Permission p) => p.name).toList(),
        'employeeNumber': employeeNumber,
        'department': department,
        'hireDate': hireDate?.toIso8601String(),
      };

  factory Employee.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawPermissions = map['permissions'] as List<dynamic>? ?? const <dynamic>[];
    return Employee(
      id: map['id']?.toString() ?? 'employee',
      name: map['name']?.toString() ?? 'Employee',
      email: map['email']?.toString() ?? '',
      roleId: map['roleId']?.toString() ?? '',
      permissions: rawPermissions
          .map((dynamic value) => Permission.values.firstWhere(
                (Permission permission) => permission.name == value.toString(),
                orElse: () => Permission.viewJobs,
              ))
          .toSet(),
      employeeNumber: map['employeeNumber']?.toString() ?? 'EMP-000',
      department: map['department']?.toString() ?? 'Operations',
      hireDate: DateTime.tryParse(map['hireDate']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.address,
  });

  final String id;
  final String name;
  final String contactName;
  final String phone;
  final String email;
  final String address;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'contactName': contactName,
        'phone': phone,
        'email': email,
        'address': address,
      };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id']?.toString() ?? 'customer',
        name: map['name']?.toString() ?? 'Customer',
        contactName: map['contactName']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        address: map['address']?.toString() ?? '',
      );
}

class JobAssignment {
  const JobAssignment({
    required this.id,
    required this.jobId,
    required this.employeeId,
    required this.assignedAt,
  });

  final String id;
  final String jobId;
  final String employeeId;
  final DateTime assignedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'jobId': jobId,
        'employeeId': employeeId,
        'assignedAt': assignedAt.toIso8601String(),
      };

  factory JobAssignment.fromMap(Map<String, dynamic> map) => JobAssignment(
        id: map['id']?.toString() ?? 'assignment',
        jobId: map['jobId']?.toString() ?? '',
        employeeId: map['employeeId']?.toString() ?? '',
        assignedAt: DateTime.tryParse(map['assignedAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

class Job {
  const Job({
    required this.id,
    required this.customerId,
    required this.referenceNumber,
    required this.title,
    required this.description,
    required this.siteAddress,
    required this.status,
    required this.workflowStage,
    required this.scheduledDate,
    required this.assignedEmployeeIds,
    required this.notes,
    required this.billingStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String referenceNumber;
  final String title;
  final String description;
  final String siteAddress;
  final String status;
  final String workflowStage;
  final DateTime scheduledDate;
  final List<String> assignedEmployeeIds;
  final String notes;
  final String billingStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'customerId': customerId,
        'referenceNumber': referenceNumber,
        'title': title,
        'description': description,
        'siteAddress': siteAddress,
        'status': status,
        'workflowStage': workflowStage,
        'scheduledDate': scheduledDate.toIso8601String(),
        'assignedEmployeeIds': assignedEmployeeIds,
        'notes': notes,
        'billingStatus': billingStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Job.fromMap(Map<String, dynamic> map) => Job(
        id: map['id']?.toString() ?? 'job',
        customerId: map['customerId']?.toString() ?? '',
        referenceNumber: map['referenceNumber']?.toString() ?? 'JOB-000',
        title: map['title']?.toString() ?? 'New Job',
        description: map['description']?.toString() ?? '',
        siteAddress: map['siteAddress']?.toString() ?? '',
        status: map['status']?.toString() ?? 'New',
        workflowStage: map['workflowStage']?.toString() ?? 'New',
        scheduledDate: DateTime.tryParse(map['scheduledDate']?.toString() ?? '') ?? DateTime.now(),
        assignedEmployeeIds: ((map['assignedEmployeeIds'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic value) => value.toString())
            .toList(),
        notes: map['notes']?.toString() ?? '',
        billingStatus: map['billingStatus']?.toString() ?? 'Pending',
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

class TimesheetEntry {
  const TimesheetEntry({
    required this.id,
    required this.employeeId,
    required this.jobId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.workType,
    required this.notes,
    required this.billable,
    required this.quantityHours,
    required this.billingRate,
    required this.approvalStatus,
    required this.createdAt,
    required this.modifiedAt,
  });

  final String id;
  final String employeeId;
  final String jobId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String workType;
  final String notes;
  final bool billable;
  final double quantityHours;
  final double billingRate;
  final String approvalStatus;
  final DateTime createdAt;
  final DateTime modifiedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'employeeId': employeeId,
        'jobId': jobId,
        'date': date.toIso8601String(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'workType': workType,
        'notes': notes,
        'billable': billable,
        'quantityHours': quantityHours,
        'billingRate': billingRate,
        'approvalStatus': approvalStatus,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  factory TimesheetEntry.fromMap(Map<String, dynamic> map) => TimesheetEntry(
        id: map['id']?.toString() ?? 'entry',
        employeeId: map['employeeId']?.toString() ?? '',
        jobId: map['jobId']?.toString() ?? '',
        date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
        startTime: DateTime.tryParse(map['startTime']?.toString() ?? '') ?? DateTime.now(),
        endTime: DateTime.tryParse(map['endTime']?.toString() ?? '') ?? DateTime.now(),
        durationMinutes: int.tryParse(map['durationMinutes']?.toString() ?? '') ?? 0,
        workType: map['workType']?.toString() ?? 'General',
        notes: map['notes']?.toString() ?? '',
        billable: map['billable'] as bool? ?? false,
        quantityHours: double.tryParse(map['quantityHours']?.toString() ?? '0') ?? 0,
        billingRate: double.tryParse(map['billingRate']?.toString() ?? '0') ?? 0,
        approvalStatus: map['approvalStatus']?.toString() ?? 'Pending',
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
        modifiedAt: DateTime.tryParse(map['modifiedAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

class ActiveTimer {
  const ActiveTimer({
    required this.id,
    required this.employeeId,
    required this.jobId,
    required this.startedAt,
    required this.activity,
    required this.notes,
  });

  final String id;
  final String employeeId;
  final String jobId;
  final DateTime startedAt;
  final String activity;
  final String notes;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'employeeId': employeeId,
        'jobId': jobId,
        'startedAt': startedAt.toIso8601String(),
        'activity': activity,
        'notes': notes,
      };

  factory ActiveTimer.fromMap(Map<String, dynamic> map) => ActiveTimer(
        id: map['id']?.toString() ?? 'timer',
        employeeId: map['employeeId']?.toString() ?? '',
        jobId: map['jobId']?.toString() ?? '',
        startedAt: DateTime.tryParse(map['startedAt']?.toString() ?? '') ?? DateTime.now(),
        activity: map['activity']?.toString() ?? 'General',
        notes: map['notes']?.toString() ?? '',
      );
}

class BillingEntry {
  const BillingEntry({
    required this.id,
    required this.jobId,
    required this.employeeId,
    required this.label,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.isBillable,
    required this.notes,
  });

  final String id;
  final String jobId;
  final String employeeId;
  final String label;
  final double quantity;
  final double rate;
  final double amount;
  final bool isBillable;
  final String notes;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'jobId': jobId,
        'employeeId': employeeId,
        'label': label,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
        'isBillable': isBillable,
        'notes': notes,
      };

  factory BillingEntry.fromMap(Map<String, dynamic> map) => BillingEntry(
        id: map['id']?.toString() ?? 'billing',
        jobId: map['jobId']?.toString() ?? '',
        employeeId: map['employeeId']?.toString() ?? '',
        label: map['label']?.toString() ?? 'Labour',
        quantity: double.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
        rate: double.tryParse(map['rate']?.toString() ?? '0') ?? 0,
        amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0,
        isBillable: map['isBillable'] as bool? ?? false,
        notes: map['notes']?.toString() ?? '',
      );
}
