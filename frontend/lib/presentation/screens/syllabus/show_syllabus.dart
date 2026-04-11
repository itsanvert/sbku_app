import 'package:flutter/material.dart';
import 'package:sbku_app/model/syllabus_model.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';

class ShowSyllabusScreen extends StatelessWidget {
  final SyllabusModel syllabus;

  const ShowSyllabusScreen({super.key, required this.syllabus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC),
      appBar: AppBarWidget.simple(
        title: "ព័ត៌មានលម្អិតមុខវិជ្ជា",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF334155), const Color(0xFF1E293B)]
                    : [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 35),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    syllabus.subjectName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${syllabus.creditHours} Credits',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            _buildSectionTitle("ព័ត៌មានទូទៅ (General Information)", isDark),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildDetailItem(Icons.business_rounded, "មហាវិទ្យាល័យ", syllabus.facultyName, isDark),
              _buildDetailItem(Icons.school_rounded, "ជំនាញ", syllabus.majorName, isDark),
              _buildDetailItem(Icons.calendar_today_rounded, "ឆ្នាំសិក្សា", syllabus.yearName, isDark),
              _buildDetailItem(Icons.layers_rounded, "ឆមាស", syllabus.semesterName, isDark),
            ], isDark),
            
            const SizedBox(height: 24),
            _buildSectionTitle("ព័ត៌មានសិក្សា (Academic Details)", isDark),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildDetailItem(Icons.person_outline_rounded, "សាស្ត្រាចារ្យ", syllabus.teacherName, isDark),
              _buildDetailItem(Icons.access_time_rounded, "វេនសិក្សា", syllabus.shiftName, isDark),
              _buildDetailItem(Icons.event_note_rounded, "កាលវិភាគ", syllabus.scheduleInfo, isDark),
            ], isDark),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.blue.shade300 : const Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final idx = entry.key;
          final widget = entry.value;
          return Column(
            children: [
              widget,
              if (idx < children.length - 1)
                Divider(
                  height: 1, 
                  indent: 55, 
                  endIndent: 20, 
                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: isDark ? Colors.blue.shade200 : const Color(0xFF475569)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12, 
                    color: isDark ? Colors.grey.shade400 : Colors.blueGrey, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white : const Color(0xFF1E293B)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
