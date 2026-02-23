// import 'package:flutter/material.dart';
// import '../../../model/student_model.dart';
// import '../../../data/dummy_students.dart';

// class AddStudentScreen extends StatefulWidget {
//   final StudentModel? student;

//   const AddStudentScreen({super.key, this.student});

//   @override
//   State<AddStudentScreen> createState() => _AddStudentScreenState();
// }

// class _AddStudentScreenState extends State<AddStudentScreen> {
//   late final TextEditingController _nameController;
//   late final TextEditingController _facultyController;
//   late final TextEditingController _majorController;
//   late final TextEditingController _generationController;
//   late final TextEditingController _yearController;
//   late final TextEditingController _emailController;
//   late String _selectedGender;
//   late String _selectedShift;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.student != null) {
//       final s = widget.student!;
//       _nameController = TextEditingController(text: s.name);
//       _facultyController = TextEditingController(text: s.faculty);
//       _majorController = TextEditingController(text: s.major);
//       _generationController = TextEditingController(text: s.generation);
//       _yearController = TextEditingController(text: s.year);
//       _emailController = TextEditingController(text: s.email);
//       _selectedGender = s.gender;
//       _selectedShift = s.shift;
//     } else {
//       _nameController = TextEditingController();
//       _facultyController = TextEditingController();
//       _majorController = TextEditingController();
//       _generationController = TextEditingController();
//       _yearController = TextEditingController();
//       _emailController = TextEditingController();
//       _selectedGender = 'M';
//       _selectedShift = 'Morning';
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _facultyController.dispose();
//     _majorController.dispose();
//     _generationController.dispose();
//     _yearController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.student != null;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.orange,
//         title: Text(isEditing ? 'Edit Student' : 'Add Student'),
//         actions: [
//           IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
//           IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildTextField(
//                 'Student ID',
//                 _nameController,
//               ), // or use name if you prefer
//               _buildTextField('Faculty', _facultyController),
//               _buildDropdown(
//                 'Gender',
//                 _selectedGender,
//                 ['M', 'F'],
//                 (v) => setState(() => _selectedGender = v!),
//                 (v) => v == 'M' ? 'Male' : 'Female',
//               ),
//               _buildTextField('Major', _majorController),
//               _buildDropdown(
//                 'Shift',
//                 _selectedShift,
//                 ['Morning', 'Evening'],
//                 (v) => setState(() => _selectedShift = v!),
//                 (v) => v,
//               ),
//               _buildTextField('Generation', _generationController),
//               _buildTextField('Year', _yearController),
//               _buildTextField('Email', _emailController),

//               const SizedBox(height: 24),

//               // // Upload Button (optional)
//               // ElevatedButton.icon(
//               //   onPressed: () {},
//               //   icon: const Icon(Icons.upload, color: Colors.white),
//               //   label: const Text(
//               //     'Upload Photo',
//               //     style: TextStyle(color: Colors.white),
//               //   ),
//               //   style: ElevatedButton.styleFrom(
//               //     backgroundColor: Colors.orange,
//               //     padding: const EdgeInsets.symmetric(
//               //       horizontal: 32,
//               //       vertical: 12,
//               //     ),
//               //     shape: RoundedRectangleBorder(
//               //       borderRadius: BorderRadius.circular(8),
//               //     ),
//               //   ),
//               // ),

//               // const SizedBox(height: 16),

//               // Save Button
//               ElevatedButton(
//                 onPressed: () {
//                   final name = _nameController.text.trim();
//                   final faculty = _facultyController.text.trim();
//                   final major = _majorController.text.trim();
//                   final generation = _generationController.text.trim();
//                   final year = _yearController.text.trim();
//                   final email = _emailController.text.trim();

//                   if (name.isEmpty ||
//                       faculty.isEmpty ||
//                       major.isEmpty ||
//                       generation.isEmpty ||
//                       year.isEmpty ||
//                       email.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please fill all fields')),
//                     );
//                     return;
//                   }

//                   if (isEditing) {
//                     final updated = StudentModel(
//                       id: widget.student!.id,
//                       name: name,
//                       gender: _selectedGender,
//                       faculty: faculty,
//                       major: major,
//                       shift: _selectedShift,
//                       generation: generation,
//                       year: year,
//                       email: email,
//                     );
//                     final index = dummyStudents.indexWhere(
//                       (s) => s.id == updated.id,
//                     );
//                     if (index != -1) dummyStudents[index] = updated;
//                   } else {
//                     final newStudent = StudentModel(
//                       id: 'SBKU${DateTime.now().millisecondsSinceEpoch}',
//                       name: name,
//                       gender: _selectedGender,
//                       faculty: faculty,
//                       major: major,
//                       shift: _selectedShift,
//                       generation: generation,
//                       year: year,
//                       email: email,
//                     );
//                     dummyStudents.add(newStudent);
//                   }

//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE65100),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 48,
//                     vertical: 16,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   isEditing ? 'Update' : 'Save',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           TextField(
//             controller: controller,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.orange),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.orange, width: 2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDropdown<T>(
//     String label,
//     T value,
//     List<T> items,
//     void Function(T?) onChanged,
//     String Function(T) displayText,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           DropdownButtonFormField<T>(
//             value: value,
//             items: items
//                 .map(
//                   (e) =>
//                       DropdownMenuItem(value: e, child: Text(displayText(e))),
//                 )
//                 .toList(),
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.orange),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.orange, width: 2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
