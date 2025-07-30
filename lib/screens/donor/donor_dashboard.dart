import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _navigateToNotifications(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1️⃣ Quick Stats Header
            _buildStatsHeader(context),
            const SizedBox(height: 20),

            // 2️⃣ Main Action Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _DashboardCard(
                    icon: Icons.add_circle,
                    title: "Make a Donation",
                    color: Colors.green,
                    onTap: () => _navigateToDonate(context),
                  ),
                  _DashboardCard(
                    icon: Icons.search,
                    title: "View Requests",
                    color: Colors.blue,
                    onTap: () => _navigateToRequests(context),
                  ),
                  _DashboardCard(
                    icon: Icons.history,
                    title: "Donation History",
                    color: Colors.orange,
                    onTap: () => _navigateToHistory(context),
                  ),
                  _DashboardCard(
                    icon: Icons.chat,
                    title: "Community Chat",
                    color: Colors.purple,
                    onTap: () => _navigateToChat(context),
                  ),
                  _DashboardCard(
                    icon: Icons.person,
                    title: "Profile & Settings",
                    color: Colors.teal,
                    onTap: () => _navigateToProfile(context),
                  ),
                  _DashboardCard(
                    icon: Icons.analytics,
                    title: "Impact Report",
                    color: Colors.red,
                    onTap: () => _navigateToImpact(context),
                  ),
                ],
              ),
            ),

            // 3️⃣ Urgent Needs Banner
            _buildUrgentNeedsBanner(),
          ],
        ),
      ),
    );
  }

  // ➡️ Widget: Stats Header
  Widget _buildStatsHeader(BuildContext context) {
    final donor = Provider.of<DonorProfile>(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Welcome, ${donor.name}!",
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  value: "12",
                  label: "Donations Made",
                  icon: Icons.favorite,
                ),
                _StatItem(
                  value: "24",
                  label: "People Helped",
                  icon: Icons.people,
                ),
                _StatItem(
                  value: "5★",
                  label: "Donor Rating",
                  icon: Icons.star,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ➡️ Widget: Urgent Needs Banner
  Widget _buildUrgentNeedsBanner() {
    return InkWell(
      onTap: () => _navigateToUrgentRequests(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "3 URGENT REQUESTS NEAR YOU",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    "Food and shelter needed within 5km",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToDonate(BuildContext context) => 
    Navigator.pushNamed(context, '/donate');

  void _navigateToRequests(BuildContext context) => 
    Navigator.pushNamed(context, '/requests');

  void _navigateToHistory(BuildContext context) => 
    Navigator.pushNamed(context, '/donation-history');

  void _navigateToChat(BuildContext context) => 
    Navigator.pushNamed(context, '/donor-chat');

  void _navigateToProfile(BuildContext context) => 
    Navigator.pushNamed(context, '/donor-profile');

  void _navigateToImpact(BuildContext context) => 
    Navigator.pushNamed(context, '/impact-report');

  void _navigateToUrgentRequests() => 
    Navigator.pushNamed(context, '/urgent-requests');
}

// -------------------
// Supporting Widgets
// -------------------

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// Example Provider
class DonorProfile extends ChangeNotifier {
  String name = "Alex Johnson";
  // Add other donor-specific properties
}