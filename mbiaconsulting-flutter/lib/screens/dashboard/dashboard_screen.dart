import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tableau de bord Client'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text( 'Bienvenue, M. Mbia'.tr(),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Messages'.tr(),
                    count: "12",
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Demandes'.tr(),
                    count: "5",
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Agenda'.tr(),
                    count: "3",
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text( 'Prochains Rendez-vous'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('JD'.tr())),
                title: Text('Jean Dupont - BTP'.tr()),
                subtitle: Text('04 Fév, 14:00 - Google Meet'.tr()),
                trailing: Chip(label: Text('Payé'.tr())),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('AK'.tr())),
                title: Text('Académique Foot K.'.tr()),
                subtitle: Text('05 Fév, 10:00 - Yaoundé'.tr()),
                trailing: Chip(label: Text('En attente'.tr())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final MaterialColor color;
  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[100]!),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color[800],
            ),
          ),
          Text(title, style: TextStyle(color: color[800])),
        ],
      ),
    );
  }
}
