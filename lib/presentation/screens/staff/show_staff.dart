import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_staff.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import '../../../data/dummy_students.dart';

class ShowStaffScreen extends StatelessWidget {
  final String staffId;
  const ShowStaffScreen({super.key, required this.staffId});

  @override
  Widget build(BuildContext context) {
    final staff = dummyStaffs.firstWhere((s) => s.id == staffId);

    return Scaffold(
      appBar: AppBarWidget(
        title: "ព័ត៌មានសិស្ស",
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person),
            ),
            const SizedBox(height: 20),
            _row('Staff ID', staff.staffid),
            _row('Name', staff.fullName),
            _row('Specialization', staff.specalization),
            _row('Phone', staff.phone),
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
          Expanded(flex: 2, child: Text(value)),
        ],
      ),
    );
  }
}
