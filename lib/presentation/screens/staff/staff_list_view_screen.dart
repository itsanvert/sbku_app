import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_staff.dart'; // assuming this exports List<StaffModel> dummyStaffs
import 'package:sbku_app/model/staff_model.dart';
import 'package:sbku_app/presentation/screens/staff/add_staff.dart';
import 'package:sbku_app/presentation/screens/staff/show_staff.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/filter_row_widget.dart';
import 'package:sbku_app/presentation/widgets/list_item_widget.dart';

class StaffListViewScreen extends StatefulWidget {
  const StaffListViewScreen({super.key});

  @override
  State<StaffListViewScreen> createState() => _StaffListViewScreenState();
}

class _StaffListViewScreenState extends State<StaffListViewScreen> {
  // Filter values
  String? _selectedSpecialization;
  String? _selectedDepartment; // optional – add if your model has department

  // Get filtered list (you can add more filters later)
  List<StaffModel> get filteredStaffs {
    return dummyStaffs.where((staff) {
      final matchSpec = _selectedSpecialization == null ||
          staff.specalization == _selectedSpecialization;
      // final matchDept = _selectedDepartment == null ||
      //     staff.department == _selectedDepartment;   // ← uncomment if you add department

      return matchSpec; // && matchDept
    }).toList();
  }

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
            onPressed: () {
              setState(() {
                dummyStaffs.removeWhere((s) => s.id == staff.id);
              });
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${staff.fullName} ត្រូវបានលុបដោយជោគជ័យ'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('លុប'),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(StaffModel staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddStaffScreen(staff: staff), // ← rename screen if needed
      ),
    ).then((_) => setState(() {})); // refresh after edit
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddStaffScreen(),
      ),
    ).then((_) => setState(() {})); // refresh after add
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter =
        _selectedSpecialization != null; // || _selectedDepartment != null

    return Scaffold(
      appBar: AppBarWidget.simple(
        title: 'បញ្ជីបុគ្គលិក',
        actions: [
          IconButton(
            onPressed: () {
              // TODO: implement share / export functionality
            },
            icon: const Icon(Icons.share, color: Colors.white),
          ),
          IconButton(
            onPressed: _navigateToAdd,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Row – customize according to your needs
          FilterRowWidget(
            filters: [
              FilterConfig(
                value: _selectedSpecialization,
                hint: 'ជំនាញ',
                items: Set<String>.from(
                  dummyStaffs.map((s) => s.specalization),
                ).toList(),
                onChanged: (value) {
                  setState(() => _selectedSpecialization = value);
                },
              ),
              // Add more filters if your StaffModel has more filterable fields
              // FilterConfig(
              //   value: _selectedDepartment,
              //   hint: 'នាយកដ្ឋាន',
              //   items: Set<String>.from(dummyStaffs.map((s) => s.department ?? '')).toList(),
              //   onChanged: (value) => setState(() => _selectedDepartment = value),
              // ),
            ],
          ),

          // Staff List
          Expanded(
            child: filteredStaffs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hasFilter ? 'រកមិនឃើញបុគ្គលិក' : 'មិនទាន់មានបុគ្គលិក',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (hasFilter) ...[
                          const SizedBox(height: 8),
                          Text(
                            'សូមកែប្រែការតម្រង',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredStaffs.length,
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    itemBuilder: (context, index) {
                      final staff = filteredStaffs[index];

                      return ListItemWidget<StaffModel>(
                        item: staff,
                        title: staff.fullName,
                        subtitle: staff.specalization,
                        // trailingSubtitle: staff.phone,           // optional
                        avatarBackgroundColor: Colors.deepOrange,
                        avatarTextColor: Colors.white,
                        // showAvatarImage: staff has image url → can be extended later
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShowStaffScreen(staffId: staff.id),
                            ),
                          );
                        },
                        actions: [
                          ItemAction.text(
                            label: 'កែ',
                            onPressed: () => _navigateToEdit(staff),
                            color: Colors.green,
                          ),
                          ItemAction.text(
                            label: 'លុប',
                            onPressed: () => _showDeleteDialog(staff),
                            color: Colors.red,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
