import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Completed', 'Canceled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Donation History"),
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          _buildSummaryCards(),
          
          // Donations List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donations')
                  .where('donorId', isEqualTo: _user?.uid)
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "You haven't made any donations yet",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _navigateToDonate(context),
                          child: const Text("Make your first donation"),
                        ),
                      ],
                    ),
                  );
                }

                final donations = snapshot.data!.docs.where((doc) {
                  if (_selectedFilter == 'All') return true;
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == _selectedFilter;
                }).toList();

                return ListView.builder(
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final data = donations[index].data() as Map<String, dynamic>;
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
                        onTap: () => _showDonationDetails(context, data),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(data['status']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      data['status'] ?? 'Pending',
                                      style: const TextStyle(
                                        color: Colors.white,
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
                              if (data['status'] == 'Active')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        _manageDonation(context, data),
                                    child: const Text("MANAGE"),
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

  Widget _buildSummaryCards() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        children: [
          _SummaryCard(
            icon: Icons.favorite,
            value: "24",
            label: "Total Donations",
            color: Colors.red[100]!,
          ),
          _SummaryCard(
            icon: Icons.people,
            value: "15",
            label: "People Helped",
            color: Colors.blue[100]!,
          ),
          _SummaryCard(
            icon: Icons.star,
            value: "4.8",
            label: "Donor Rating",
            color: Colors.amber[100]!,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Active':
        return Colors.blue;
      case 'Canceled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  void _showDonationDetails(BuildContext context, Map<String, dynamic> data) {
    final timestamp = data['timestamp'] as Timestamp?;
    final formattedDate = timestamp != null
        ? DateFormat('MMM d, yyyy - hh:mm a').format(timestamp.toDate())
        : 'Unknown';

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
              Row(
                children: [
                  Chip(
                    label: Text(data['category'] ?? 'General'),
                    backgroundColor: Colors.blue[50],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data['status'] ?? 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                data['description'] ?? 'No description provided',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                "Donation Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              _buildDetailRow("Quantity:", data['quantity'] ?? 'Not specified'),
              _buildDetailRow("Location:", data['location'] ?? 'Not specified'),
              _buildDetailRow("Date Posted:", formattedDate),
              if (data['expiryDate'] != null)
                _buildDetailRow(
                  "Expiry Date:",
                  DateFormat('MMM d, yyyy')
                      .format(DateTime.parse(data['expiryDate'])),
                ),
              if (data['recipientName'] != null)
                _buildDetailRow("Helped:", data['recipientName']),
              const SizedBox(height: 24),
              if (data['status'] == 'Active')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _manageDonation(context, data),
                    child: const Text("Manage Donation"),
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

  void _manageDonation(BuildContext context, Map<String, dynamic> donation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Manage Donation"),
        content: const Text("What would you like to do with this donation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editDonation(context, donation);
            },
            child: const Text("Edit"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelDonation(context, donation);
            },
            child: const Text(
              "Cancel Donation",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _editDonation(BuildContext context, Map<String, dynamic> donation) {
    Navigator.pushNamed(
      context,
      '/edit-donation',
      arguments: {'donationId': donation['donationId']},
    );
  }

  void _cancelDonation(BuildContext context, Map<String, dynamic> donation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Cancellation"),
        content: const Text(
            "Are you sure you want to cancel this donation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('donations')
                  .doc(donation['donationId'])
                  .update({'status': 'Canceled'});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Donation canceled")),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Filter Donations"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters
              .map((filter) => RadioListTile(
                    title: Text(filter),
                    value: filter,
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() => _selectedFilter = value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _navigateToDonate(BuildContext context) {
    Navigator.pushNamed(context, '/make-donation');
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}