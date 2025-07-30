import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewRequestsScreen extends StatefulWidget {
  const ViewRequestsScreen({super.key});

  @override
  State<ViewRequestsScreen> createState() => _ViewRequestsScreenState();
}

class _ViewRequestsScreenState extends State<ViewRequestsScreen> {
  String _selectedCategory = 'All';
  String _selectedFilter = 'Recent';
  final TextEditingController _searchController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final List<String> _categories = [
    'All',
    'Food',
    'Shelter',
    'Clothing',
    'Education',
    'Medical',
    'Financial',
    'Other'
  ];

  final List<String> _filters = [
    'Recent',
    'Urgent',
    'Near Me',
    'Unfulfilled'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Aid Requests"),
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => _navigateToMapView(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search requests...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Category Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    underline: const SizedBox(),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value!);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Status Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    underline: const SizedBox(),
                    items: _filters.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedFilter = value!);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Requests List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No requests available right now",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final requests = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final matchesCategory = _selectedCategory == 'All' || 
                      data['category'] == _selectedCategory;
                  final matchesSearch = _searchController.text.isEmpty ||
                      (data['title']?.toString().toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ) ??
                          false) ||
                      (data['description']?.toString().toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ) ??
                          false);
                  
                  // Add additional filter logic here
                  bool matchesFilter = true;
                  if (_selectedFilter == 'Urgent') {
                    matchesFilter = data['isUrgent'] == true;
                  } else if (_selectedFilter == 'Unfulfilled') {
                    matchesFilter = data['status'] != 'Fulfilled';
                  }
                  // Add more filter conditions as needed

                  return matchesCategory && matchesSearch && matchesFilter;
                }).toList();

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final data = requests[index].data() as Map<String, dynamic>;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final formattedDate = timestamp != null
                        ? DateFormat('MMM d, yyyy').format(timestamp.toDate())
                        : '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showRequestDetails(context, data),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (data['isUrgent'] == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        "URGENT",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['description'] ?? 'No description',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(data['category'] ?? 'General'),
                                    backgroundColor: Colors.blue[50],
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (_currentUser?.uid != data['userId'])
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        _respondToRequest(context, data),
                                    child: const Text("HELP WITH THIS"),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                data['title'] ?? 'No Title',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(data['category'] ?? 'General'),
                backgroundColor: Colors.blue[50],
              ),
              const SizedBox(height: 16),
              Text(
                data['description'] ?? 'No description provided',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                "Request Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              _buildDetailRow("Status:", data['status'] ?? 'Pending'),
              _buildDetailRow("Location:", data['location'] ?? 'Not specified'),
              _buildDetailRow("Posted by:", data['userName'] ?? 'Anonymous'),
              _buildDetailRow(
                  "Date Posted:",
                  data['timestamp'] != null
                      ? DateFormat('MMM d, yyyy - hh:mm a')
                          .format((data['timestamp'] as Timestamp).toDate())
                      : 'Unknown'),
              if (data['isUrgent'] == true)
                _buildDetailRow("Urgency:", "High Priority"),
              const SizedBox(height: 24),
              if (_currentUser?.uid != data['userId'])
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _respondToRequest(context, data),
                    child: const Text("Offer Assistance"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _respondToRequest(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Offer Assistance"),
        content: const Text("How would you like to help with this request?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startChatWithRequester(context, request);
            },
            child: const Text("Message"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _fulfillRequest(context, request);
            },
            child: const Text("Fulfill Request"),
          ),
        ],
      ),
    );
  }

  void _startChatWithRequester(
      BuildContext context, Map<String, dynamic> request) {
    // Implement chat initiation
    Navigator.pushNamed(context, '/chat', arguments: {
      'userId': request['userId'],
      'userName': request['userName'],
    });
  }

  void _fulfillRequest(BuildContext context, Map<String, dynamic> request) {
    // Implement request fulfillment
    Navigator.pushNamed(context, '/fulfill-request', arguments: {
      'requestId': request['requestId'],
    });
  }

  void _navigateToMapView(BuildContext context) {
    Navigator.pushNamed(context, '/requests-map');
  }
}