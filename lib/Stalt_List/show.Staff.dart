import 'package:flutter/material.dart';
import '../../data/dummy_staffs.dart';

class ShowStaffScreen extends StatelessWidget {
  final String staffId;
  const ShowStaffScreen({super.key, required this.staffId});

  @override
  Widget build(BuildContext context) {
    final staff = dummyStaffs.firstWhere((s) => s.id == staffId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Staff Details'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person),
            ),
            const SizedBox(height: 20),
            _row('Staff ID', staff.id),
            _row('Name', staff.name),
            _row('Gender', staff.gender == 'M' ? 'Male' : 'Female'),
            _row('Department', staff.department),
            _row('Position', staff.position),
            _row('Shift', staff.shift),
            _row('Email', staff.email),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
