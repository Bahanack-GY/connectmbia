import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tableau de bord Client")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenue, M. Mbia",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: "Messages",
                    count: "12",
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: "Demandes",
                    count: "5",
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: "Agenda",
                    count: "3",
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              "Prochains Rendez-vous",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Card(
              child: ListTile(
                leading: CircleAvatar(child: Text("JD")),
                title: Text("Jean Dupont - BTP"),
                subtitle: Text("04 Fév, 14:00 - Google Meet"),
                trailing: Chip(label: Text("Payé")),
              ),
            ),
            const Card(
              child: ListTile(
                leading: CircleAvatar(child: Text("AK")),
                title: Text("Académique Foot K."),
                subtitle: Text("05 Fév, 10:00 - Yaoundé"),
                trailing: Chip(label: Text("En attente")),
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
