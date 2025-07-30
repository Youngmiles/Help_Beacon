import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class MakeDonationScreen extends StatefulWidget {
  const MakeDonationScreen({super.key});

  @override
  State<MakeDonationScreen> createState() => _MakeDonationScreenState();
}

class _MakeDonationScreenState extends State<MakeDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  String _selectedCategory = 'Food';
  String _selectedCondition = 'New';
  DateTime? _expiryDate;
  List<File> _selectedImages = [];
  bool _loading = false;
  bool _isAnonymous = false;

  final List<String> _categories = [
    'Food',
    'Shelter',
    'Clothing',
    'Education',
    'Medical',
    'Financial',
    'Other'
  ];

  final List<String> _conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Poor'
  ];

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await ImagePicker().pickMultiImage(
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick images: ${e.toString()}")),
      );
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    final storage = FirebaseStorage.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || _selectedImages.isEmpty) return imageUrls;

    try {
      for (var image in _selectedImages) {
        final ref = storage.ref().child(
            'donations/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
    return imageUrls;
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _expiryController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      List<String> imageUrls = await _uploadImages();

      await FirebaseFirestore.instance.collection('donations').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'quantity': _quantityController.text.trim(),
        'location': _locationController.text.trim(),
        'expiryDate': _expiryDate?.toIso8601String(),
        'imageUrls': imageUrls,
        'donorId': _isAnonymous ? null : user?.uid,
        'donorEmail': _isAnonymous ? null : user?.email,
        'donorName': _isAnonymous ? null : user?.displayName,
        'isAnonymous': _isAnonymous,
        'status': 'Available',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation posted successfully!")),
      );

      // Clear form after successful submission
      _formKey.currentState!.reset();
      setState(() {
        _selectedCategory = 'Food';
        _selectedCondition = 'New';
        _expiryDate = null;
        _selectedImages.clear();
        _isAnonymous = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make a Donation"),
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donation Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Donation Title *",
                  border: OutlineInputBorder(),
                  hintText: "e.g., Canned Goods, Winter Clothes",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter a title" : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description *",
                  border: OutlineInputBorder(),
                  hintText: "Describe what you're donating in detail",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter a description" : null,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category *",
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
                validator: (value) =>
                    value == null ? "Please select a category" : null,
              ),
              const SizedBox(height: 16),

              // Condition Dropdown (for physical items)
              if (_selectedCategory != 'Financial' &&
                  _selectedCategory != 'Education')
                DropdownButtonFormField<String>(
                  value: _selectedCondition,
                  decoration: const InputDecoration(
                    labelText: "Condition",
                    border: OutlineInputBorder(),
                  ),
                  items: _conditions.map((condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(condition),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCondition = value!);
                  },
                ),
              if (_selectedCategory != 'Financial' &&
                  _selectedCategory != 'Education')
                const SizedBox(height: 16),

              // Quantity
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity *",
                  border: OutlineInputBorder(),
                  hintText: "e.g., 5 boxes, 10 kg",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter quantity" : null,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Location *",
                  border: OutlineInputBorder(),
                  hintText: "Where is this donation available?",
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter location" : null,
              ),
              const SizedBox(height: 16),

              // Expiry Date (for perishable items)
              if (_selectedCategory == 'Food' || _selectedCategory == 'Medical')
                TextFormField(
                  controller: _expiryController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Expiry Date",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectExpiryDate,
                    ),
                  ),
                  onTap: _selectExpiryDate,
                ),
              if (_selectedCategory == 'Food' || _selectedCategory == 'Medical')
                const SizedBox(height: 16),

              // Image Upload
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Upload Photos (Max 5)",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedImages.map((image) => Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => setState(() {
                                    _selectedImages.remove(image);
                                  }),
                                ),
                              ),
                            ],
                          )),
                      if (_selectedImages.length < 5)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo,
                                color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Anonymous Donation Toggle
              SwitchListTile(
                title: const Text("Make this donation anonymously"),
                value: _isAnonymous,
                onChanged: (value) => setState(() => _isAnonymous = value),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "POST DONATION",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}