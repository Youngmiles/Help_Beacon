import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String category = "user";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
        
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        firstNameController.text = data['firstName'] ?? '';
        lastNameController.text = data['lastName'] ?? '';
        phoneController.text = data['phone'] ?? '';
        locationController.text = data['location'] ?? '';
        category = data['category'] ?? 'user';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || user == null) return;

    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'location': locationController.text.trim(),
        'category': category,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: ${e.toString()}")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter first name" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter last name" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) {
                  if (v!.isEmpty) return "Enter phone number";
                  if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]+$')
                      .hasMatch(v)) {
                    return "Enter valid phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v!.isEmpty ? "Enter location" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "user", child: Text("User")),
                  DropdownMenuItem(value: "donor", child: Text("Donor")),
                  DropdownMenuItem(value: "ngo", child: Text("NGO")),
                  DropdownMenuItem(value: "gov", child: Text("Government")),
                ],
                onChanged: (val) => setState(() => category = val!),
              ),
              const SizedBox(height: 24),

              SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: loading ? null : _updateProfile,
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ), // Added missing parenthesis here
    ), // Added missing parenthesis here
    child: loading
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text("UPDATE PROFILE"),
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}