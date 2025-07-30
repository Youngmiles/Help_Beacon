import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/app_theme.dart';
import 'firebase_options.dart';

// Import all your screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/password_reset_screen.dart';
import 'screens/profile/update_profile_screen.dart';
import 'screens/home/user_dashboard.dart';
import 'screens/home/donor_dashboard.dart';
import 'screens/home/ngo_dashboard.dart';
import 'screens/home/gov_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HelpBeaconApp());
}

class HelpBeaconApp extends StatelessWidget {
  const HelpBeaconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelpBeacon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify-email': (context) => const EmailVerificationScreen(),
        '/reset-password': (context) => const PasswordResetScreen(),
        '/update-profile': (context) => const UpdateProfileScreen(),
        '/user-dashboard': (context) => const UserDashboard(),
        '/donor-dashboard': (context) => const DonorDashboard(),
        '/ngo-dashboard': (context) => const NgoDashboard(),
        '/gov-dashboard': (context) => const GovDashboard(),
        // Add this as a fallback for any legacy '/home' references
        '/home': (context) => const UserDashboard(), 
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Route ${settings.name} not found')),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _navigated = false;

  Future<String?> _getUserCategory(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return doc.data()?['category'] as String?;
    } catch (e) {
      debugPrint('Error getting user category: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        
        if (user == null) {
          return const LoginScreen();
        }

        if (!user.emailVerified && 
            user.providerData.any((p) => p.providerId == 'password')) {
          return const EmailVerificationScreen();
        }

        return FutureBuilder<String?>(
          future: _getUserCategory(user.uid),
          builder: (context, categorySnapshot) {
            if (categorySnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!_navigated) {
              _navigated = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final category = categorySnapshot.data;
                if (category == null) {
                  Navigator.pushReplacementNamed(context, '/update-profile');
                } else {
                  switch (category) {
                    case 'user':
                      Navigator.pushReplacementNamed(context, '/user-dashboard');
                      break;
                    case 'donor':
                      Navigator.pushReplacementNamed(context, '/donor-dashboard');
                      break;
                    case 'ngo':
                      Navigator.pushReplacementNamed(context, '/ngo-dashboard');
                      break;
                    case 'gov':
                      Navigator.pushReplacementNamed(context, '/gov-dashboard');
                      break;
                    default:
                      Navigator.pushReplacementNamed(context, '/update-profile');
                  }
                }
              });
            }

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }
}