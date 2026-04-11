import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:sbku_app/service/auth_service.dart';

class RequestPermissionScreen extends StatefulWidget {
  const RequestPermissionScreen({super.key});

  @override
  State<RequestPermissionScreen> createState() =>
      _RequestPermissionScreenState();
}

class _RequestPermissionScreenState extends State<RequestPermissionScreen> {
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _imageFile;
  final _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  final AttendanceService _service = AttendanceService();

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _selectDate() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: theme.colorScheme.copyWith(primary: theme.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('សូមបញ្ចូលមូលហេតុនៃការស្នើសុំ')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || user.studentId == null) {
        throw Exception('មិនអាចរកអត្តសញ្ញាណសិស្សឃើញទេ');
      }

      await _service.requestPermission(
        studentId: user.studentId!,
        attendanceDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        reason: _reasonController.text.trim(),
        imagePath: _imageFile?.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ ការស្នើសុំត្រូវបានបញ្ជូនរួចរាល់'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    return Scaffold(
      appBar: AppBarWidget.simple(title: 'ស្នើសុំច្បាប់ (Permission)'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(primary),
            const SizedBox(height: 24),
            _label('កាលបរិច្ឆេទអវត្តមាន', isDark),
            _buildDatePicker(isDark, primary),
            const SizedBox(height: 20),
            _label('មូលហេតុលម្អិត', isDark),
            _buildReasonInput(isDark),
            const SizedBox(height: 20),
            _label('រូបភាពបញ្ជាក់ (លិខិតពេទ្យ ឬឯកសារផ្សេងៗ)', isDark),
            _buildImagePicker(isDark, primary),
            const SizedBox(height: 40),
            _buildSubmitButton(primary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'សិស្សអាចស្នើសុំច្បាប់ទុកជាមុន ឬក៏បន្ទាប់ពីខកខាន។ គ្រូបង្រៀននឹងធ្វើការពិនិត្យ និងអនុម័ត។',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark, Color primary) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    return InkWell(
      onTap: _isSubmitting ? null : _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: primary),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd MMMM yyyy').format(_selectedDate),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down,
                color: isDark ? const Color(0xFF64748B) : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonInput(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: _reasonController,
        maxLines: 5,
        enabled: !_isSubmitting,
        style: TextStyle(
          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'សូមបញ្ជាក់ពីមូលហេតុដែលអ្នកសុំច្បាប់...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF64748B) : Colors.grey,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDark, Color primary) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? primary.withOpacity(0.4)
        : primary.withOpacity(0.3);

    return InkWell(
      onTap: _isSubmitting ? null : _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: _imageFile != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _imageFile = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded,
                      size: 48,
                      color: isDark
                          ? primary.withOpacity(0.4)
                          : primary.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  Text(
                    'ចុចដើម្បីបន្ថែមរូបភាព',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF64748B) : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSubmitButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'បញ្ជូនការស្នើសុំ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
