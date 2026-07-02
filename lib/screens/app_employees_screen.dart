import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/game_catalog.dart';
import '../providers/game_provider.dart';
import '../widgets/action_card.dart';
import '../widgets/section_card.dart';

class AppEmployeesScreen extends StatelessWidget {
  const AppEmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        SectionCard(
          title: 'Employees',
          subtitle: 'Hire specialists who improve development, research, and operations.',
          child: Column(
            children: game.employees.isEmpty
                ? <Widget>[const Align(alignment: Alignment.centerLeft, child: Text('No employees yet. Start with a Developer or Intern.'))]
                : game.employees
                    .map(
                      (employee) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.badge_outlined),
                        title: Text(employee.role),
                        subtitle: Text(employee.description),
                        trailing: Text('\$${employee.salary.toStringAsFixed(0)} / sec'),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Hire Talent',
          subtitle: 'Office capacity: ${game.employeeLimit}',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: employeeCatalog
                .map(
                  (EmployeeCatalogEntry entry) => SizedBox(
                    width: 280,
                    child: ActionCard(
                      title: entry.role,
                      subtitle: '\$${(entry.salary * 10).toStringAsFixed(0)} hire cost • ${entry.description}',
                      icon: Icons.person_add,
                      enabled: game.cash >= entry.salary * 10 && game.employees.length < game.employeeLimit,
                      onPressed: () => game.hireEmployee(entry.role),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
