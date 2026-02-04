import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_staff.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/list_item_widget.dart';

import '../../../model/staff_model.dart';
import 'show_staff.dart';

class StaffListViewScreen extends StatefulWidget {
  const StaffListViewScreen({super.key});

  @override
  State<StaffListViewScreen> createState() => _StaffListViewScreenState();
}

class _StaffListViewScreenState extends State<StaffListViewScreen> {
  // ================= DELETE =================
  void _showDeleteDialog(StaffModel staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('លុបបុគ្គលិក'),
        content: Text('តើអ្នកប្រាកដថាចង់លុប ${staff.fullName} ឬទេ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                dummyStaffList.removeWhere((s) => s.id == staff.id);
              });
              Navigator.pop(ctx);
            },
            child: const Text('លុប'),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(
        title: 'បញ្ជីបុគ្គលិក',
      ),
      body: dummyStaffList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: dummyStaffList.length,
              itemBuilder: (context, index) {
                final staff = dummyStaffList[index];

                return ListItemWidget<StaffModel>(
                  item: staff,
                  title: staff.fullName,
                  subtitle: staff.specalization,
                  avatarText: staff.fullName[0],
                  avatarBackgroundColor: Colors.orange[50],
                  avatarTextColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShowStaffScreen(staffId: staff.id),
                      ),
                    );
                  },
                  actions: [
                    ItemAction.text(
                      label: 'លុប',
                      color: Colors.red,
                      onPressed: () => _showDeleteDialog(staff),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'មិនមានបុគ្គលិក',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
