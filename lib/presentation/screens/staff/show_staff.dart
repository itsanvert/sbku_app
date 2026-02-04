import 'package:flutter/material.dart';
import '../../../data/dummy_staff.dart';
import '../../../model/staff_model.dart';

class ShowStaffScreen extends StatelessWidget {
  final String staffId;
  const ShowStaffScreen({super.key, required this.staffId});

  @override
  Widget build(BuildContext context) {
    final StaffModel staff =
        dummyStaffList.firstWhere((s) => s.id == staffId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Staff Details'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
            ),
            const SizedBox(height: 24),
            _row('Staff ID', staff.staffid),
            _row('Full Name', staff.fullName),
            _row('Specialization', staff.specalization),
            _row('Phone', staff.phone),
            _row('Email', staff.email),
            _row('User ID', staff.userid),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(flex: 2, child: Text(value)),
        ],
      ),
    );
  }
}
