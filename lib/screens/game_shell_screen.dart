import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/workflow_models.dart';
import '../providers/business_provider.dart';

class WorkforceShellScreen extends StatelessWidget {
  const WorkforceShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = context.select<BusinessProvider, int>(
      (BusinessProvider p) => p.selectedTabIndex,
    );
    return Scaffold(
      body: Column(
        children: <Widget>[
          const _DataStatusBanner(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: const <Widget>[
                HomeScreen(),
                JobsScreen(),
                TimesheetScreen(),
                ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: context.read<BusinessProvider>().selectTab,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Timesheet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DataStatusBanner extends StatelessWidget {
  const _DataStatusBanner();

  @override
  Widget build(BuildContext context) {
    final BusinessProvider provider = context.watch<BusinessProvider>();
    if (provider.isDataLoading) {
      return const SafeArea(
        bottom: false,
        child: LinearProgressIndicator(minHeight: 3),
      );
    }
    if (!provider.hasDataLoadErrors) return const SizedBox.shrink();
    return SafeArea(
      bottom: false,
      child: MaterialBanner(
        content: Text(provider.dataLoadErrors.values.join(' ')),
        leading: const Icon(Icons.cloud_off_outlined),
        actions: <Widget>[
          TextButton(
            onPressed: provider.refreshAll,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _selectedDate = DateUtils.dateOnly(picked));
    }
  }

  void _moveDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
  }

  @override
  Widget build(BuildContext context) {
    final BusinessProvider provider = context.watch<BusinessProvider>();
    final bool isManager = provider.hasPermission(Permission.editJobs);
    final List<Job> visibleJobs = provider.jobs.where((Job job) {
      return isManager ||
          job.assignedEmployeeIds.contains(provider.currentUser.id);
    }).toList();
    final List<Job> selectedJobs = visibleJobs.where((Job job) {
      return DateUtils.isSameDay(job.scheduledDate, _selectedDate);
    }).toList()..sort((Job a, Job b) => a.title.compareTo(b.title));
    final bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return _Frame(
      title: 'Diary',
      child: RefreshIndicator(
        onRefresh: provider.refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Previous day',
                      onPressed: () => _moveDate(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickDate,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: <Widget>[
                              Text(
                                isToday
                                    ? 'TODAY'
                                    : DateFormat(
                                        'EEEE',
                                      ).format(_selectedDate).toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                DateFormat('d MMMM y').format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next day',
                      onPressed: () => _moveDate(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    selectedJobs.isEmpty
                        ? 'No jobs scheduled'
                        : '${selectedJobs.length} ${selectedJobs.length == 1 ? 'job' : 'jobs'} scheduled',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isToday)
                  TextButton(
                    onPressed: () => setState(
                      () => _selectedDate = DateUtils.dateOnly(DateTime.now()),
                    ),
                    child: const Text('Today'),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (final Job job in selectedJobs)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.work_outline)),
                  title: Text(
                    job.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    <String>[
                      if (job.siteAddress.isNotEmpty) job.siteAddress,
                      job.referenceNumber,
                    ].join('\n'),
                  ),
                  isThreeLine: job.siteAddress.isNotEmpty,
                  trailing: _Pill(job.status),
                ),
              ),
            if (selectedJobs.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.event_available,
                        size: 44,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isManager
                            ? 'There are no jobs in the diary for this date.'
                            : 'You have no assigned jobs for this date.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
      builder: (BuildContext sheetContext) =>
          ChangeNotifierProvider<BusinessProvider>.value(
            value: provider,
            child: _JobFormSheet(
              editJob: editJob,
              suggestedReference: editJob == null
                  ? provider.nextJobReference()
                  : '',
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
      child: RefreshIndicator(
        onRefresh: provider.refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isManager)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Edit job',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  _showJobForm(context, editJob: job),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.referenceNumber,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (job.description.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(job.description),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        job.siteAddress,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          _Pill(job.status),
                          const SizedBox(width: 8),
                          if (job.workflowStage != job.status)
                            _Pill(job.workflowStage),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Assigned: ${job.assignedEmployeeIds.length} crew  •  ${DateFormat('d MMM y').format(job.scheduledDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
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
      builder: (BuildContext sheetContext) =>
          ChangeNotifierProvider<BusinessProvider>.value(
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
              .where(
                (TimesheetEntry e) => e.employeeId == provider.currentUser.id,
              )
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
      child: RefreshIndicator(
        onRefresh: provider.refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  _view == _TimesheetView.mine
                      ? 'Total hours logged'
                      : 'Team total',
                ),
                trailing: Text(
                  '${hours.toStringAsFixed(1)} hrs',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
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
                      const Icon(
                        Icons.schedule,
                        size: 48,
                        color: Colors.black26,
                      ),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
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
                provider.currentUser.roleId == 'manager'
                    ? 'Manager'
                    : 'Employee',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Your role'),
            ),
          ),
          if (provider.hasPermission(Permission.manageEmployees)) ...<Widget>[
            const SizedBox(height: 12),
            const _ManagerWorkersCard(),
          ],
          const SizedBox(height: 32),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
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
    final Color color = switch (label) {
      'Completed' || 'Approved' => Colors.green,
      'Cancelled' || 'Rejected' => Colors.red,
      'In Progress' => Colors.blue,
      'On Hold' => Colors.orange,
      'Scheduled' => Colors.purple,
      _ => Theme.of(context).colorScheme.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
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
  bool _busy = false;

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

  Future<void> _submit() async {
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
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<BusinessProvider>().addManualEntry(
        hours: hours,
        date: _date,
        jobId: _jobId!,
        customJobLabel: _jobId == 'other' ? _customJobCtrl.text.trim() : null,
        notes: _notesCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'Unable to save hours. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Job> jobs = context.watch<BusinessProvider>().jobs;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: <DropdownMenuItem<String>>[
              ...jobs.map(
                (Job j) =>
                    DropdownMenuItem<String>(value: j.id, child: Text(j.title)),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: _busy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Add Entry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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
    if (entry.approvalStatus == 'Approved' ||
        entry.approvalStatus == 'Rejected') {
      final bool approved = entry.approvalStatus == 'Approved';
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: approved ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          entry.approvalStatus,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: approved ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ),
      );
    } else if (isManager) {
      trailing = PopupMenuButton<String>(
        tooltip: 'Review timesheet',
        onSelected: (String action) => action == 'approve'
            ? provider.approveEntry(entry.id)
            : provider.rejectEntry(entry.id),
        itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
          PopupMenuItem<String>(value: 'approve', child: Text('Approve')),
          PopupMenuItem<String>(value: 'reject', child: Text('Reject')),
        ],
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
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.orange.shade800,
          ),
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
  late List<String> _assignedEmployeeIds;
  String? _error;
  bool _busy = false;

  static const List<String> _statusOptions = <String>[
    'New',
    'Scheduled',
    'In Progress',
    'On Hold',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    final Job? job = widget.editJob;
    _titleCtrl = TextEditingController(text: job?.title ?? '');
    _refCtrl = TextEditingController(
      text: job?.referenceNumber ?? widget.suggestedReference,
    );
    _addressCtrl = TextEditingController(text: job?.siteAddress ?? '');
    _descCtrl = TextEditingController(text: job?.description ?? '');
    _notesCtrl = TextEditingController(text: job?.notes ?? '');
    _scheduledDate =
        job?.scheduledDate ?? DateTime.now().add(const Duration(days: 1));
    _status = job?.status ?? 'New';
    _assignedEmployeeIds = <String>[...?job?.assignedEmployeeIds];
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

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Job title is required.');
      return;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Site address is required.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final BusinessProvider provider = context.read<BusinessProvider>();
    try {
      if (widget.editJob != null) {
        await provider.updateJob(
          Job(
            id: widget.editJob!.id,
            customerId: widget.editJob!.customerId,
            referenceNumber: _refCtrl.text.trim(),
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            siteAddress: _addressCtrl.text.trim(),
            status: _status,
            workflowStage: _status,
            scheduledDate: _scheduledDate,
            assignedEmployeeIds: _assignedEmployeeIds,
            notes: _notesCtrl.text.trim(),
            billingStatus: widget.editJob!.billingStatus,
            createdAt: widget.editJob!.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await provider.addJob(
          title: _titleCtrl.text.trim(),
          referenceNumber: _refCtrl.text.trim(),
          siteAddress: _addressCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          scheduledDate: _scheduledDate,
          status: _status,
          notes: _notesCtrl.text.trim(),
          assignedEmployeeIds: _assignedEmployeeIds,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Unable to save this job. Check the details and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.editJob != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
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
                        .map(
                          (String s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) =>
                        setState(() => _status = v ?? _status),
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
              label: Text(
                'Scheduled: ${DateFormat('EEE d MMM y').format(_scheduledDate)}',
              ),
              style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (BuildContext context) {
                final List<Employee> workers = context
                    .watch<BusinessProvider>()
                    .employees
                    .where(
                      (Employee employee) =>
                          employee.roleId == 'employee' && employee.active,
                    )
                    .toList();
                if (workers.isEmpty) return const SizedBox.shrink();
                return InputDecorator(
                  decoration: _decor('Assigned workers'),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: workers.map((Employee worker) {
                      final bool selected = _assignedEmployeeIds.contains(
                        worker.id,
                      );
                      return FilterChip(
                        label: Text(worker.name),
                        selected: selected,
                        onSelected: (bool value) => setState(() {
                          if (value) {
                            _assignedEmployeeIds.add(worker.id);
                          } else {
                            _assignedEmployeeIds.remove(worker.id);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: _decor('Notes (optional)'),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEdit ? 'Save Changes' : 'Create Job',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            if (isEdit) ...<Widget>[
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Job'),
                onPressed: () async {
                  final BusinessProvider provider = context
                      .read<BusinessProvider>();
                  final NavigatorState navigator = Navigator.of(context);
                  final bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Delete job?'),
                      content: const Text(
                        'Existing timesheets will retain their recorded hours, but the job will no longer be selectable.',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    await provider.deleteJob(widget.editJob!.id);
                    if (mounted) navigator.pop();
                  }
                },
              ),
            ],
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

class _ManagerWorkersCard extends StatelessWidget {
  const _ManagerWorkersCard();

  Future<void> _openWorkerDialog(
    BuildContext context, {
    Employee? employee,
  }) async {
    final BusinessProvider provider = context.read<BusinessProvider>();
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) =>
          ChangeNotifierProvider<BusinessProvider>.value(
            value: provider,
            child: _WorkerDialog(employee: employee),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BusinessProvider provider = context.watch<BusinessProvider>();
    final List<Employee> workers = provider.employees
        .where((Employee employee) => employee.roleId == 'employee')
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Workers',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh workers',
                  onPressed: provider.refreshEmployees,
                  icon: const Icon(Icons.refresh),
                ),
                FilledButton.icon(
                  onPressed: () => _openWorkerDialog(context),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (workers.isEmpty)
              const Text('No worker accounts yet.')
            else
              for (final Employee worker in workers)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(
                      worker.name.isEmpty ? '?' : worker.name[0].toUpperCase(),
                    ),
                  ),
                  title: Text(worker.name),
                  subtitle: Text(
                    <String>[
                      if (worker.jobTitle.isNotEmpty) worker.jobTitle,
                      worker.email,
                      if (!worker.active) 'Disabled',
                    ].join(' • '),
                  ),
                  trailing: IconButton(
                    tooltip: 'Manage worker',
                    icon: const Icon(Icons.manage_accounts_outlined),
                    onPressed: () =>
                        _openWorkerDialog(context, employee: worker),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _WorkerDialog extends StatefulWidget {
  const _WorkerDialog({this.employee});
  final Employee? employee;

  @override
  State<_WorkerDialog> createState() => _WorkerDialogState();
}

class _WorkerDialogState extends State<_WorkerDialog> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _jobTitle;
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  bool _active = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final Employee? employee = widget.employee;
    _name = TextEditingController(text: employee?.name ?? '');
    _email = TextEditingController(text: employee?.email ?? '');
    _jobTitle = TextEditingController(text: employee?.jobTitle ?? '');
    _active = employee?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _jobTitle.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      setState(() => _error = 'Name and email are required.');
      return;
    }
    if (widget.employee == null && _password.text.length < 8) {
      setState(
        () => _error = 'New workers need a password of at least 8 characters.',
      );
      return;
    }
    if (widget.employee == null && _password.text != _passwordConfirm.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final BusinessProvider provider = context.read<BusinessProvider>();
      if (widget.employee == null) {
        await provider.createWorker(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          jobTitle: _jobTitle.text,
        );
      } else {
        final Employee old = widget.employee!;
        await provider.updateWorker(
          Employee(
            id: old.id,
            name: _name.text.trim(),
            email: _email.text.trim(),
            roleId: old.roleId,
            permissions: old.permissions,
            jobTitle: _jobTitle.text.trim(),
            active: _active,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_password.text.length < 8) {
      setState(
        () => _error = 'Enter a new password of at least 8 characters first.',
      );
      return;
    }
    if (_password.text != _passwordConfirm.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<BusinessProvider>().resetWorkerPassword(
        widget.employee!.id,
        _password.text,
      );
      if (mounted) {
        _password.clear();
        _passwordConfirm.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Worker password reset.')));
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete worker?'),
        content: const Text(
          'This removes the worker account. Historical timesheets should be reviewed before deletion.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<BusinessProvider>().deleteWorker(widget.employee!.id);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool editing = widget.employee != null;
    return AlertDialog(
      title: Text(editing ? 'Manage Worker' : 'Add Worker'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _jobTitle,
                decoration: const InputDecoration(labelText: 'Job title'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: editing
                      ? 'New password (only to reset)'
                      : 'Temporary password',
                ),
              ),
              TextField(
                controller: _passwordConfirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: editing
                      ? 'Confirm new password'
                      : 'Confirm temporary password',
                ),
              ),
              if (editing)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Account active'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        if (editing)
          TextButton(
            onPressed: _busy ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        if (editing)
          TextButton(
            onPressed: _busy ? null : _resetPassword,
            child: const Text('Reset Password'),
          ),
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(editing ? 'Save' : 'Create Worker'),
        ),
      ],
    );
  }
}
