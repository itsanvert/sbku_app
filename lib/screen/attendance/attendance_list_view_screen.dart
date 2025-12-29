// widget/attendance/attendance_item.dart
import 'package:flutter/material.dart';
import 'package:sbku_app/widget/list_item_widget.dart';
import '../../model/attendance.dart';

class AttendanceItemWidget extends StatelessWidget {
  final AttendanceModel attendance;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final Color? avatarBackgroundColor;
  final Color? avatarTextColor;
  final Color? actionColor;

  const AttendanceItemWidget({
    super.key,
    required this.attendance,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.avatarBackgroundColor,
    this.avatarTextColor,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <ItemAction>[];

    if (onEdit != null) {
      actions.add(
        ItemAction.text(
          label: 'Edit',
          onPressed: onEdit!,
          color: actionColor ?? Colors.orange,
        ),
      );
    }

    if (onDelete != null) {
      actions.add(
        ItemAction.text(
          label: 'Delete',
          onPressed: onDelete!,
          color: actionColor ?? Colors.orange,
        ),
      );
    }

    return ListItemWidget<AttendanceModel>(
      item: attendance,
      title: attendance.studentName,
      subtitle: '${attendance.formattedDate} • ${attendance.timeRange}',
      avatarText: attendance.avatarLetter,
      avatarBackgroundColor:
          avatarBackgroundColor ?? attendance.statusColor.withOpacity(0.1),
      avatarTextColor: avatarTextColor ?? attendance.statusColor,
      onTap: onTap,
      actions: actions,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: attendance.statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: attendance.statusColor),
        ),
        child: Text(
          attendance.statusLabel,
          style: TextStyle(
            color: attendance.statusColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
