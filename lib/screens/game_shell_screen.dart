import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/workflow_models.dart';
import '../providers/business_provider.dart';

class WorkforceShellScreen extends StatelessWidget {
  const WorkforceShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = context.select<BusinessProvider, int>((BusinessProvider p) => p.selectedTabIndex);
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const <Widget>[
          HomeScreen(),
          JobsScreen(),
          TimesheetScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: context.read<BusinessProvider>().selectTab,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Timesheet'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BusinessProvider provider = context.watch<BusinessProvider>();
    final Job? activeJob = provider.jobs.isNotEmpty ? provider.jobs.first : null;
    final ActiveTimer? runningTimer = provider.activeTimers.isNotEmpty ? provider.activeTimers.first : null;

    return _Frame(
      title: 'Home',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (runningTimer != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Timer running'),
                subtitle: Text('${provider.currentUser.name} • ${_jobName(provider, runningTimer.jobId)}'),
                trailing: FilledButton(
                  onPressed: () => provider.stopTimer(
                    timer: runningTimer,
                    workType: 'Site work',
                    notes: 'Finished onsite task.',
                    billable: true,
                    quantityHours: 0,
                    billingRate: 95,
                  ),
                  child: const Text('Stop'),
                ),
              ),
            )
          else
            const Card(
              child: ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text('Ready to start'),
                subtitle: Text('Open a job and start a timer when you are on site.'),
              ),
            ),
          const SizedBox(height: 12),
          if (activeJob != null)
            Card(
              child: ListTile(
                title: Text(activeJob.title),
                subtitle: Text('${activeJob.siteAddress} • ${activeJob.status}'),
                trailing: TextButton(
                  onPressed: () => provider.startTimer(
                    employeeId: provider.currentUser.id,
                    jobId: activeJob.id,
                    activity: 'General',
                    notes: 'On site',
                  ),
                  child: const Text('Start work'),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text('Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          for (final Job job in provider.jobs)
            Card(
              child: ListTile(
                title: Text(job.title),
                subtitle: Text('${job.workflowStage} • ${DateFormat.MMMd().format(job.scheduledDate)}'),
              ),
            ),
        ],
      ),
    );
  }
}

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  void _showJobForm(BuildContext context, {Job? editJob}) {
    final BusinessProvider provider = context.read<BusinessProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) => ChangeNotifierProvider<BusinessProvider>.value(
        value: provider,
        child: _JobFormSheet(
          editJob: editJob,
          suggestedReference: editJob == null ? provider.nextJobReference() : '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BusinessProvider provider = context.watch<BusinessProvider>();
    final bool isManager = provider.hasPermission(Permission.editJobs);
    return _Frame(
      title: 'Jobs',
      action: isManager
          ? IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 28),
              tooltip: 'Add job',
              onPressed: () => _showJobForm(context),
            )
          : null,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          for (final Job job in provider.jobs)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (isManager)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit job',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showJobForm(context, editJob: job),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.referenceNumber,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    if (job.description.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(job.description),
                    ],
                    const SizedBox(height: 8),
                    Text(job.siteAddress, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        _Pill(job.status),
                        const SizedBox(width: 8),
                        if (job.workflowStage != job.status) _Pill(job.workflowStage),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Assigned: ${job.assignedEmployeeIds.length} crew  •  ${DateFormat('d MMM y').format(job.scheduledDate)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          if (provider.jobs.isEmpty)
            const Card(
              child: ListTile(
                title: Text('No jobs yet'),
                subtitle: Text('Tap + to add the first job.'),
              ),
            ),
        ],
      ),
    );
  }
}

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

enum _TimesheetView { mine, team }

class _TimesheetScreenState extends State<TimesheetScreen> {
  _TimesheetView _view = _TimesheetView.mine;

  void _showAddEntry(BuildContext context) {
    final BusinessProvider provider = context.read<BusinessProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) => ChangeNotifierProvider<BusinessProvider>.value(
        value: provider,
        child: const _AddEntrySheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BusinessProvider provider = context.watch<BusinessProvider>();
    final bool isManager = provider.hasPermission(Permission.approveTimesheets);

    final List<TimesheetEntry> entries = _view == _TimesheetView.mine
        ? provider.timesheetEntries
            .where((TimesheetEntry e) => e.employeeId == provider.currentUser.id)
            .toList()
        : provider.timesheetEntries;

    final double hours = entries.fold<double>(
      0,
      (double t, TimesheetEntry e) => t + e.quantityHours,
    );

    return _Frame(
      title: 'Timesheet',
      action: IconButton(
        icon: const Icon(Icons.add_circle_outline, size: 28),
        tooltip: 'Add hours',
        onPressed: () => _showAddEntry(context),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (isManager)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SegmentedButton<_TimesheetView>(
                segments: const <ButtonSegment<_TimesheetView>>[
                  ButtonSegment<_TimesheetView>(
                    value: _TimesheetView.mine,
                    label: Text('My Hours'),
                    icon: Icon(Icons.person_outline),
                  ),
                  ButtonSegment<_TimesheetView>(
                    value: _TimesheetView.team,
                    label: Text('Team Hours'),
                    icon: Icon(Icons.group_outlined),
                  ),
                ],
                selected: <_TimesheetView>{_view},
                onSelectionChanged: (Set<_TimesheetView> v) =>
                    setState(() => _view = v.first),
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                _view == _TimesheetView.mine ? 'Total hours logged' : 'Team total',
              ),
              trailing: Text(
                '${hours.toStringAsFixed(1)} hrs',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final TimesheetEntry entry in entries)
            _TimesheetEntryCard(
              entry: entry,
              provider: provider,
              showEmployee: _view == _TimesheetView.team,
              isManager: isManager,
            ),
          if (entries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.schedule, size: 48, color: Colors.black26),
                    const SizedBox(height: 12),
                    const Text(
                      'No entries yet',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add your hours'),
                      onPressed: () => _showAddEntry(context),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BusinessProvider provider = context.watch<BusinessProvider>();
    return _Frame(
      title: 'Profile',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0D1B4E),
                child: Text(
                  provider.currentUser.name.isNotEmpty
                      ? provider.currentUser.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              title: Text(
                provider.currentUser.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(provider.currentUser.email),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(
                provider.currentUser.roleId == 'manager' ? 'Manager' : 'Employee',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Your role'),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () => provider.signOut(),
          ),
        ],
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
                ),
                ?action,
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

String _employeeName(BusinessProvider provider, String employeeId) {
  for (final Employee emp in provider.employees) {
    if (emp.id == employeeId) return emp.name;
  }
  return 'Unknown';
}

String _entryJobLabel(BusinessProvider provider, TimesheetEntry entry) {
  if (entry.jobId == 'other') {
    return entry.customJobLabel ?? entry.workType;
  }
  for (final Job job in provider.jobs) {
    if (job.id == entry.jobId) return job.title;
  }
  return entry.workType.isNotEmpty ? entry.workType : 'Unknown job';
}

String _jobName(BusinessProvider provider, String jobId) {
  for (final Job job in provider.jobs) {
    if (job.id == jobId) {
      return job.title;
    }
  }
  return 'Unknown job';
}

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet();

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  String? _jobId;
  final TextEditingController _customJobCtrl = TextEditingController();
  final TextEditingController _hoursCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _customJobCtrl.dispose();
    _hoursCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final double? hours = double.tryParse(_hoursCtrl.text.trim());
    if (_jobId == null) {
      setState(() => _error = 'Select a job first.');
      return;
    }
    if (_jobId == 'other' && _customJobCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Describe the job.');
      return;
    }
    if (hours == null || hours <= 0) {
      setState(() => _error = 'Enter valid hours (e.g. 7.5).');
      return;
    }
    context.read<BusinessProvider>().addManualEntry(
      hours: hours,
      date: _date,
      jobId: _jobId!,
      customJobLabel: _jobId == 'other' ? _customJobCtrl.text.trim() : null,
      notes: _notesCtrl.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final List<Job> jobs = context.watch<BusinessProvider>().jobs;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Add Hours',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(DateFormat('EEE d MMM y').format(_date)),
            style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: _pickDate,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _jobId,
            hint: const Text('Select job'),
            decoration: InputDecoration(
              labelText: 'Job',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: <DropdownMenuItem<String>>[
              ...jobs.map(
                (Job j) => DropdownMenuItem<String>(value: j.id, child: Text(j.title)),
              ),
              const DropdownMenuItem<String>(
                value: 'other',
                child: Text('Other \u2013 describe below'),
              ),
            ],
            onChanged: (String? v) => setState(() {
              _jobId = v;
              _error = null;
            }),
          ),
          if (_jobId == 'other') ...<Widget>[
            const SizedBox(height: 12),
            TextField(
              controller: _customJobCtrl,
              decoration: InputDecoration(
                labelText: 'Describe job',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _hoursCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Hours worked (e.g. 7.5)',
              prefixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Add Entry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimesheetEntryCard extends StatelessWidget {
  const _TimesheetEntryCard({
    required this.entry,
    required this.provider,
    required this.showEmployee,
    required this.isManager,
  });

  final TimesheetEntry entry;
  final BusinessProvider provider;
  final bool showEmployee;
  final bool isManager;

  @override
  Widget build(BuildContext context) {
    final String subtitle = <String>[
      if (showEmployee) _employeeName(provider, entry.employeeId),
      DateFormat('EEE d MMM').format(entry.date),
      '${entry.quantityHours.toStringAsFixed(1)} hrs',
    ].join('  \u2022  ');

    final Widget trailing;
    if (entry.approvalStatus == 'Approved') {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Approved',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green.shade800),
        ),
      );
    } else if (isManager) {
      trailing = FilledButton.tonal(
        style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
        onPressed: () => provider.approveEntry(entry.id),
        child: const Text('Approve', style: TextStyle(fontSize: 12)),
      );
    } else {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Pending',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orange.shade800),
        ),
      );
    }

    return Card(
      child: ListTile(
        title: Text(
          _entryJobLabel(provider, entry),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}

class _JobFormSheet extends StatefulWidget {
  const _JobFormSheet({this.editJob, this.suggestedReference = ''});

  final Job? editJob;
  final String suggestedReference;

  @override
  State<_JobFormSheet> createState() => _JobFormSheetState();
}

class _JobFormSheetState extends State<_JobFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _refCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _scheduledDate;
  late String _status;
  String? _error;

  static const List<String> _statusOptions = <String>[
    'New',
    'Scheduled',
    'In Progress',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    final Job? job = widget.editJob;
    _titleCtrl = TextEditingController(text: job?.title ?? '');
    _refCtrl = TextEditingController(text: job?.referenceNumber ?? widget.suggestedReference);
    _addressCtrl = TextEditingController(text: job?.siteAddress ?? '');
    _descCtrl = TextEditingController(text: job?.description ?? '');
    _notesCtrl = TextEditingController(text: job?.notes ?? '');
    _scheduledDate = job?.scheduledDate ?? DateTime.now().add(const Duration(days: 1));
    _status = job?.status ?? 'New';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _refCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Job title is required.');
      return;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Site address is required.');
      return;
    }
    final BusinessProvider provider = context.read<BusinessProvider>();
    if (widget.editJob != null) {
      provider.updateJob(Job(
        id: widget.editJob!.id,
        customerId: widget.editJob!.customerId,
        referenceNumber: _refCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        siteAddress: _addressCtrl.text.trim(),
        status: _status,
        workflowStage: _status,
        scheduledDate: _scheduledDate,
        assignedEmployeeIds: widget.editJob!.assignedEmployeeIds,
        notes: _notesCtrl.text.trim(),
        billingStatus: widget.editJob!.billingStatus,
        createdAt: widget.editJob!.createdAt,
        updatedAt: DateTime.now(),
      ));
    } else {
      provider.addJob(
        title: _titleCtrl.text.trim(),
        referenceNumber: _refCtrl.text.trim(),
        siteAddress: _addressCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        scheduledDate: _scheduledDate,
        status: _status,
        notes: _notesCtrl.text.trim(),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.editJob != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Job' : 'New Job',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _decor('Job title *'),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _refCtrl,
                    decoration: _decor('Reference #'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: _decor('Status'),
                    items: _statusOptions
                        .map((String s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (String? v) => setState(() => _status = v ?? _status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              decoration: _decor('Site address *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: _decor('Description (optional)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Scheduled: ${DateFormat('EEE d MMM y').format(_scheduledDate)}'),
              style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: _decor('Notes (optional)'),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  isEdit ? 'Save Changes' : 'Create Job',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decor(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );
}

