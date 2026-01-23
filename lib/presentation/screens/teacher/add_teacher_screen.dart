import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sbku_app/model/teacher_model.dart';


class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({Key? key}) : super(key: key);

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _teacheridController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();

  String? _selectedGender;
  String? _selectedSpecialization;
  String? _selectedYear;
  String? _selectedSchedule;

  final TextEditingController _useridController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> genders = ['Male', 'Female'];
  final List<String> specializations = [
    'Information Technology',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Engineering',
  ];
  final List<String> years = ['year 1', 'year 2', 'year 3', 'year 4'];
  final List<String> schedules = ['morning', 'afternoon', 'evening'];

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFFF5722),
                ),
                title: const Text('ជ្រើសរើសពីវិចិត្រសាល'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _imageFile = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Color(0xFFFF5722),
                ),
                title: const Text('ថតរូប'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() {
                      _imageFile = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveTeacher() {
    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _selectedSpecialization != null &&
        _selectedYear != null &&
        _selectedSchedule != null) {
      final teacher = TeacherModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teacherid: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _fullNameController.text,
        gender: _selectedGender!,
        specialization: _selectedSpecialization!,
        year: _selectedYear!,
        schedule: _selectedSchedule!,
        phone: _phoneController.text,
        email: _emailController.text,
        userid: "U001", // example
        facultyid: "IT01", // example
        imagePath: _imageFile?.path,
      );

      Navigator.pop(context, teacher);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('សូមបំពេញព័ត៌មានទាំងអស់'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _teacheridController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _useridController.dispose();
    _facultyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5722),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'បន្ថែមគ្រូបង្រៀន',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _teacheridController,
              label: 'អត្តលេខ :',
              hint: '',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _fullNameController,
              label: 'បំពេញឈ្មោះ :',
              hint: '',
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'ភេទ :',
              value: _selectedGender,
              items: genders,
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'ជំនាញ :',
              value: _selectedSpecialization,
              items: specializations,
              onChanged: (value) =>
                  setState(() => _selectedSpecialization = value),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'ឆ្មាំទី :',
              value: _selectedYear,
              items: years,
              onChanged: (value) => setState(() => _selectedYear = value),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'វេន :',
              value: _selectedSchedule,
              items: schedules,
              onChanged: (value) => setState(() => _selectedSchedule = value),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'លេខទូរសព្ទ :',
              hint: '',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'អ៊ីមែល :',
              hint: '',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _useridController,
              label: 'លេខTeacher ID :',
              hint: '',
            ),

            const SizedBox(height: 24),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5722),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5722).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _imageFile != null
                            ? 'រូបភាពបានជ្រើសរើស'
                            : 'បញ្ចូលរូបភាព',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTeacher,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'រក្សាទុក',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'សូមបំពេញព័ត៌មាននេះ';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF5722)),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null) {
                return 'សូមជ្រើសរើសជម្រើសមួយ';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
