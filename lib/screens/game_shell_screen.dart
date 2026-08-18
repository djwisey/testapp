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

  @override
  Widget build(BuildContext context) {
    final BusinessProvider provider = context.watch<BusinessProvider>();
    return _Frame(
      title: 'Jobs',
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
                    Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(job.referenceNumber),
                    const SizedBox(height: 8),
                    Text(job.description),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        _Pill(job.status),
                        const SizedBox(width: 8),
                        _Pill(job.workflowStage),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Assigned: ${job.assignedEmployeeIds.length} crew members'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TimesheetScreen extends StatelessWidget {
  const TimesheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BusinessProvider provider = context.watch<BusinessProvider>();
    final double hours = provider.totalHoursForEmployee(provider.currentUser.id);
    return _Frame(
      title: 'Timesheet',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('This week'),
              trailing: Text('${hours.toStringAsFixed(1)} hrs'),
            ),
          ),
          const SizedBox(height: 12),
          for (final TimesheetEntry entry in provider.timesheetEntries)
            Card(
              child: ListTile(
                title: Text('${_jobName(provider, entry.jobId)} • ${entry.workType}'),
                subtitle: Text('${DateFormat.MMMd().format(entry.date)} • ${entry.durationMinutes} mins'),
                trailing: Text(entry.approvalStatus),
              ),
            ),
          if (provider.timesheetEntries.isEmpty)
            const Card(
              child: ListTile(
                title: Text('No timesheet entries yet'),
                subtitle: Text('Start work against a job to record time.'),
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
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(provider.currentUser.name),
              subtitle: Text(provider.currentUser.email),
            ),
          ),
          const SizedBox(height: 12),
          if (provider.canViewBilling())
            const Card(
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet),
                title: Text('Billing access'),
                subtitle: Text('Rates and billing summaries are visible for this user.'),
              ),
            )
          else
            const Card(
              child: ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Billing restricted'),
                subtitle: Text('No billing visibility for this role.'),
              ),
            ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              title: Text('Permissions'),
              subtitle: Text('Simple role-based access to support future roles and workflows.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
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

String _jobName(BusinessProvider provider, String jobId) {
  for (final Job job in provider.jobs) {
    if (job.id == jobId) {
      return job.title;
    }
  }
  return 'Unknown job';
}

