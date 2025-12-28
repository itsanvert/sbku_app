import 'package:flutter/material.dart';
import '../../model/student.dart';

class StudentItemWidget extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentItemWidget({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          //  Avatar (Circle with first letter)
          CircleAvatar(
            backgroundColor: Colors.purple[50],
            foregroundColor: Colors.purple,
            child: Text(student.avatarLetter),
          ),
          const SizedBox(width: 16),

          //  Name + Major
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(student.major, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          //  Edit / Delete Buttons
          Row(
            children: [
              TextButton(onPressed: onEdit, child: const Text('Edit')),
              TextButton(onPressed: onDelete, child: const Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
