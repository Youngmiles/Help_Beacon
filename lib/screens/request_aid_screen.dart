import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RequestAidScreen extends StatefulWidget {
  const RequestAidScreen({Key? key}) : super(key: key);

  @override
  State<RequestAidScreen> createState() => _RequestAidScreenState();
}

class _RequestAidScreenState extends State<RequestAidScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _urgencyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();

  bool _loading = false;
  String? _selectedMainCategory;
  String? _selectedSubCategory;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Hierarchical category system
  final Map<String, List<String>> _categories = {
    'Basic Needs': ['Food', 'Water', 'Clothing', 'Hygiene Products'],
    'Shelter': ['Temporary Housing', 'Emergency Shelter', 'Repair Assistance'],
    'Medical': [
      'First Aid',
      'Prescription Medicine',
      'Medical Equipment',
      'Mental Health'
    ],
    'Financial': ['Cash Assistance', 'Bill Payment', 'Debt Relief'],
    'Other': ['Transportation', 'Legal Aid', 'Education', 'Other']
  };

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
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
          SnackBar(content: Text("Failed to pick images: ${e.toString()}")));
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
            'aid_requests/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
    return imageUrls;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please sign in to submit a request")));
      return;
    }

    setState(() => _loading = true);

    try {
      // Upload images first
      List<String> imageUrls = await _uploadImages();

      // Then submit the request with image URLs
      await FirebaseFirestore.instance.collection('aid_requests').add({
        'userId': user.uid,
        'userEmail': user.email,
        'userPhone': _phoneController.text.trim(),
        'mainCategory': _selectedMainCategory,
        'subCategory': _selectedSubCategory,
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'urgency': _urgencyController.text.trim(),
        'additionalInfo': _additionalInfoController.text.trim(),
        'imageUrls': imageUrls,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aid request submitted successfully!")));

      // Clear form after submission
      _formKey.currentState!.reset();
      setState(() {
        _selectedMainCategory = null;
        _selectedSubCategory = null;
        _selectedImages.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit request: ${e.toString()}")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _urgencyController.dispose();
    _phoneController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Aid"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hierarchical Category Selection
              DropdownButtonFormField<String>(
                value: _selectedMainCategory,
                decoration: const InputDecoration(
                  labelText: "Main Category *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedMainCategory = newValue;
                    _selectedSubCategory = null;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a main category' : null,
              ),
              const SizedBox(height: 16),
              
              if (_selectedMainCategory != null)
                DropdownButtonFormField<String>(
                  value: _selectedSubCategory,
                  decoration: const InputDecoration(
                    labelText: "Sub Category *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subdirectory_arrow_right),
                  ),
                  items: _categories[_selectedMainCategory]!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSubCategory = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a sub category' : null,
                ),
              const SizedBox(height: 16),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Location *",
                  border: OutlineInputBorder(),
                  hintText: "Where do you need help?",
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),

              // Contact Information
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number *",
                  border: OutlineInputBorder(),
                  hintText: "Where we can contact you",
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a phone number';
                  if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]+$')
                      .hasMatch(value)) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description *",
                  border: OutlineInputBorder(),
                  hintText: "Describe your needs in detail...",
                  alignLabelWithHint: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),

              // Additional Information
              TextFormField(
                controller: _additionalInfoController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Additional Information",
                  border: OutlineInputBorder(),
                  hintText: "Any other important details...",
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Urgency Field
              TextFormField(
                controller: _urgencyController,
                decoration: const InputDecoration(
                  labelText: "Urgency Level",
                  border: OutlineInputBorder(),
                  hintText: "How urgent is your request?",
                  prefixIcon: Icon(Icons.warning),
                ),
              ),
              const SizedBox(height: 16),

              // Image Upload Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Supporting Documents/Photos",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Upload images that help explain your situation (max 5)",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
              const SizedBox(height: 24),

              // Submit Button
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), // This parenthesis was missing
    ), // Closing parenthesis for styleFrom
    onPressed: _loading ? null : _submitRequest,
    child: _loading
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text(
            "Submit Request",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
  ),
),
const SizedBox(height: 16),
const Text(
  "* indicates required fields",
  style: TextStyle(color: Colors.grey, fontSize: 12),
),
            ],
          ),
        ),
      ),
    );
  }
}