import 'package:flutter/material.dart';


class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  String? _selectedDepartment;
  String? _selectedShift;
  String? _selectedPosition;

  // Filtered list
  List<StaffModel> get filteredStaffs {
    var result = dummyStaffs;

    if (_selectedDepartment != null) {
      result = result.where((s) => s.department == _selectedDepartment).toList();
    }

    if (_selectedShift != null) {
      result = result.where((s) => s.shift == _selectedShift).toList();
    }

    if (_selectedPosition != null) {
      result = result.where((s) => s.position == _selectedPosition).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff List / Page'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddStaffScreen(),
                ),
              ).then((_) => setState(() {})); // Refresh after return
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🎯 FILTERS ROW
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Department Filter
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      isExpanded: true,
                      hint: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.filter_alt, color: Colors.orange, size: 18),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Department',
                              style: TextStyle(color: Colors.orange),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: [
                        for (final dept in Set<String>.from(
                          dummyStaffs.map((s) => s.department),
                        ))
                          DropdownMenuItem(
                            value: dept,
                            child: Text(
                              dept,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedDepartment = value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Shift Filter
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedShift,
                      isExpanded: true,
                      hint: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.filter_alt, color: Colors.orange, size: 18),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Shift',
                              style: TextStyle(color: Colors.orange),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: [
                        for (final shift in Set<String>.from(
                          dummyStaffs.map((s) => s.shift),
                        ))
                          DropdownMenuItem(
                            value: shift,
                            child: Text(
                              shift,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) => setState(() => _selectedShift = value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Position Filter
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      isExpanded: true,
                      hint: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.filter_alt, color: Colors.orange, size: 18),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Position',
                              style: TextStyle(color: Colors.orange),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: [
                        for (final pos in Set<String>.from(
                          dummyStaffs.map((s) => s.position),
                        ))
                          DropdownMenuItem(
                            value: pos,
                            child: Text(
                              pos,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) => setState(() => _selectedPosition = value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Staff List
          Expanded(
            child: ListView.builder(
              itemCount: filteredStaffs.length,
              itemBuilder: (context, index) {
                final staff = filteredStaffs[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      // Avatar Circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange[50],
                        ),
                        child: Center(
                          child: Text(
                            staff.name.isNotEmpty ? staff.name[0] : '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name + Department
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              staff.department,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit / Delete Buttons
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddStaffScreen(staff: staff),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete?'),
                                  content: const Text(
                                    'Are you sure want to delete this staff?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        dummyStaffs.removeWhere((s) => s.id == staff.id);
                                        setState(() {}); // Refresh UI
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Show staff details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ShowStaffScreen(staffId: staff.id),
                                ),
                              );
                            },
                            child: const Text(
                              'Details',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
