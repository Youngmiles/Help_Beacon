import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey servicesKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();
  final GlobalKey donateKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    try {
      final context = key.currentContext;
      if (context != null && mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      debugPrint("Scroll error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: isMobile ? _buildMobileAppBar() : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            if (!isMobile) _buildDesktopAppBar(),
            
            // Hero Section
            _buildHeroSection(theme),
            
            // About Section
            _buildSection(
              key: aboutKey,
              title: "About Us",
              content: "HelpBeacon is a platform that bridges the gap between those in need and those who can help. Our mission is to make aid distribution faster, transparent and effective.",
            ).animate().fadeIn(duration: 500.ms),
            
            // Services Section
            _buildSection(
              key: servicesKey,
              title: "Our Services",
              content: "• Aid distribution coordination\n• Donation tracking\n• NGO and Government integration\n• Emergency alerts and response",
            ).animate().slideX(duration: 500.ms),
            
            // Contact Section
            _buildSection(
              key: contactKey,
              title: "Contact Us",
              content: "📍 Nairobi, Kenya\n📧 support@helpbeacon.org\n📞 +254 700 123 456",
            ).animate().fadeIn(duration: 500.ms),
            
            // Donate Section
            _buildDonationSection(theme),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A73E8),
      title: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 30),
          const SizedBox(width: 8),
          const Text("HelpBeacon", style: TextStyle(color: Colors.white)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _showMobileMenu(context),
        ),
      ],
    );
  }

  Widget _buildDesktopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: const Color(0xFF1A73E8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/images/logo.png', height: 40),
              const SizedBox(width: 8),
              const Text(
                "HelpBeacon",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _navButton("Home", () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut)),
              _navButton("About", () => _scrollTo(aboutKey)),
              _navButton("Services", () => _scrollTo(servicesKey)),
              _navButton("Contact", () => _scrollTo(contactKey)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A73E8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () => _scrollTo(donateKey),
                child: const Text("Donate"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      color: const Color(0xFFE8F0FE),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            "Connecting Help with Those in Need",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "HelpBeacon connects donors, NGOs, government agencies and users to deliver aid efficiently during emergencies.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: () => _scrollTo(donateKey),
            child: const Text("Get Started"),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationSection(ThemeData theme) {
    return Padding(
      key: donateKey,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Text(
            "Donate",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your donations help us reach more people in need. Together, we can make a difference.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _donationOption("1000"),
              _donationOption("2000"),
              _donationOption("5000"),
              _donationOption("Custom"),
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: 100, duration: 500.ms);
  }

  Widget _buildSection({required String title, required String content, Key? key}) {
    final theme = Theme.of(context);
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF1A73E8),
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: const Center(
        child: Text(
          "© 2025 HelpBeacon. All Rights Reserved.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _navButton(String title, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Semantics(
        button: true,
        label: "Navigate to $title section",
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _donationOption(String amount) {
    return ElevatedButton(
      onPressed: () => _handleDonation(amount),
      child: Text(amount == "Custom" ? amount : "KSh $amount"),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _mobileNavItem("Home", Icons.home, () {
            Navigator.pop(ctx);
            _scrollController.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
          }),
          _mobileNavItem("About", Icons.info, () {
            Navigator.pop(ctx);
            _scrollTo(aboutKey);
          }),
          _mobileNavItem("Services", Icons.work, () {
            Navigator.pop(ctx);
            _scrollTo(servicesKey);
          }),
          _mobileNavItem("Contact", Icons.contact_mail, () {
            Navigator.pop(ctx);
            _scrollTo(contactKey);
          }),
          _mobileNavItem("Donate", Icons.volunteer_activism, () {
            Navigator.pop(ctx);
            _scrollTo(donateKey);
          }),
        ],
      ),
    );
  }

  Widget _mobileNavItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _handleDonation(String amount) {
    // Implement donation logic
    debugPrint("Donation selected: $amount");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thank you for your donation of KSh $amount")),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}