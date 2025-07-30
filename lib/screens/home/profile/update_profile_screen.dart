import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  String? _selectedCategory;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not authenticated")),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'category': _selectedCategory!.toLowerCase(), // Ensure lowercase for consistency
            'profileComplete': true,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // Navigate to appropriate dashboard
      _navigateToDashboard();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToDashboard() {
    switch (_selectedCategory!.toLowerCase()) {
      case 'user':
        Navigator.pushReplacementNamed(context, '/user-dashboard');
        break;
      case 'donor':
        Navigator.pushReplacementNamed(context, '/donor-dashboard');
        break;
      case 'ngo':
        Navigator.pushReplacementNamed(context, '/ngo-dashboard');
        break;
      case 'government':
        Navigator.pushReplacementNamed(context, '/gov-dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/user-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  "Select Your Role",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "This helps us provide you with the right features",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "I am a...",
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'User',
                      child: Text('Regular User'),
                    ),
                    DropdownMenuItem(
                      value: 'Donor',
                      child: Text('Donor/Volunteer'),
                    ),
                    DropdownMenuItem(
                      value: 'NGO',
                      child: Text('NGO Representative'),
                    ),
                    DropdownMenuItem(
                      value: 'Government',
                      child: Text('Government Official'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Continue",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}