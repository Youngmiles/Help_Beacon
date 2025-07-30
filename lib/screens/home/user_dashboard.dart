import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final List<String> _announcements = [
    "System maintenance on Aug 5th, 10PM-12AM",
    "New donation drive available in your area!",
    "Emergency contacts updated in your region"
  ];

  @override
  void initState() {
    super.initState();
    _precacheImages();
  }

  void _precacheImages() {
    precacheImage(const AssetImage('assets/images/logo.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A73E8),
        title: const Text("HelpBeacon - User Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Logo & Welcome
              _buildWelcomeSection(),
              const SizedBox(height: 20),

              // ✅ Quick Stats - Now clickable
              _buildStatsSection(),
              const SizedBox(height: 20),

              // ✅ Announcements
              _buildAnnouncementsSection(),
              const SizedBox(height: 20),

              // ✅ Services - Already clickable
              _buildServicesSection(),

              // ✅ New Quick Access Section
              _buildQuickAccessSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A73E8),
        onPressed: () => _navigateToRequestAid(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<UserProfile>(
      builder: (context, profile, child) {
        return Column(
          children: [
            CachedNetworkImage(
              imageUrl: 'https://example.com/logo.png',
              placeholder: (context, url) => Image.asset(
                'assets/images/logo_placeholder.png',
                height: 100,
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
              height: 100,
            ),
            const SizedBox(height: 8),
            Text(
              "Welcome back, ${profile.username ?? 'User'}!",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Clickable My Requests card
        InkWell(
          onTap: () => _navigateToMyRequests(context),
          borderRadius: BorderRadius.circular(12),
          child: const _DashboardCard(
            icon: Icons.request_page,
            title: "My Requests",
            value: "5",
            color: Colors.blue,
          ),
        ),
        // Clickable Donations Received card
        InkWell(
          onTap: () => _navigateToReceivedDonations(context),
          borderRadius: BorderRadius.circular(12),
          child: const _DashboardCard(
            icon: Icons.favorite,
            title: "Donations Received",
            value: "2",
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📢 Announcements",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._announcements.map((msg) => InkWell(
          onTap: () => _navigateToAnnouncements(context),
          child: _AnnouncementCard(message: msg),
        )).toList(),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📦 Available Services",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _ServiceButton(
          title: "Request Aid",
          icon: Icons.help,
          color: Colors.blue,
          onTap: () => _navigateToRequestAid(context),
        ),
        _ServiceButton(
          title: "View Donations",
          icon: Icons.card_giftcard,
          color: Colors.green,
          onTap: () => _navigateToDonations(context),
        ),
        _ServiceButton(
          title: "Contact Support",
          icon: Icons.support_agent,
          color: Colors.orange,
          onTap: () => _navigateToSupport(context),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "⚡ Quick Access",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _QuickAccessButton(
              icon: Icons.history,
              label: "History",
              color: Colors.purple,
              onTap: () => _navigateToHistory(context),
            ),
            _QuickAccessButton(
              icon: Icons.chat,
              label: "Community Chat",
              color: Colors.teal,
              onTap: () => _navigateToChat(context),
            ),
            _QuickAccessButton(
              icon: Icons.map,
              label: "Nearby Help",
              color: Colors.blueGrey,
              onTap: () => _navigateToMap(context),
            ),
            _QuickAccessButton(
              icon: Icons.settings,
              label: "Settings",
              color: Colors.grey,
              onTap: () => _navigateToSettings(context),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    // Implement data refresh logic
    await Future.delayed(const Duration(seconds: 1));
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToRequestAid(BuildContext context) {
    Navigator.pushNamed(context, '/request-aid');
  }

  void _navigateToDonations(BuildContext context) {
    Navigator.pushNamed(context, '/donations');
  }

  void _navigateToSupport(BuildContext context) {
    Navigator.pushNamed(context, '/support');
  }

  void _navigateToMyRequests(BuildContext context) {
    Navigator.pushNamed(context, '/my-requests');
  }

  void _navigateToReceivedDonations(BuildContext context) {
    Navigator.pushNamed(context, '/received-donations');
  }

  void _navigateToAnnouncements(BuildContext context) {
    Navigator.pushNamed(context, '/announcements');
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.pushNamed(context, '/history');
  }

  void _navigateToChat(BuildContext context) {
    Navigator.pushNamed(context, '/chat');
  }

  void _navigateToMap(BuildContext context) {
    Navigator.pushNamed(context, '/map');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150,
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String message;

  const _AnnouncementCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.campaign, color: Colors.blue),
        title: Text(message),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ServiceButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: color,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfile extends ChangeNotifier {
  String? username;

  void updateUsername(String newName) {
    username = newName;
    notifyListeners();
  }
}