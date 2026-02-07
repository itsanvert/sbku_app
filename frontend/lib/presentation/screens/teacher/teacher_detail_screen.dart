import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sbku_app/model/teacher_model.dart';


class TeacherDetailScreen extends StatefulWidget {
  final TeacherModel teacher;
  const TeacherDetailScreen({super.key, required this.teacher});

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.teacher.imagePath;
  }

  Future<void> _pick(ImageSource source) async {
    Navigator.pop(context);
    final XFile? img = await _picker.pickImage(source: source);
    if (img != null) {
      setState(() {
        _image = File(img.path);
        _imagePath = null;
      });
      _snack('រូបភាពបានផ្លាស់ប្តូរ');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pickItem(Icons.photo_library, 'វិចិត្រសាល', ImageSource.gallery),
          _pickItem(Icons.camera_alt, 'ថតរូប', ImageSource.camera),
        ],
      ),
    );
  }

  ListTile _pickItem(IconData icon, String text, ImageSource src) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF5722)),
      title: Text(text),
      onTap: () => _pick(src),
    );
  }

  ImageProvider? get _avatar {
    if (_image != null) return FileImage(_image!);
    if (_imagePath != null) return FileImage(File(_imagePath!));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5722),
        title: const Text('Show Teacher'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [_avatarSection(), _infoCard()]),
      ),
    );
  }

  Widget _avatarSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _avatar,
            child: _avatar == null
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _showPicker,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    final t = widget.teacher;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        children: [
          _info(Icons.person, 'អត្តលេខ', t.teacherid),
          _info(Icons.badge, 'ឈ្មោះ', t.fullName),
          _info(Icons.wc, 'ភេទ', t.gender == 'Male' ? 'Male' : 'Female'),
          _info(Icons.school, 'ឯកទេស', t.specialization),
          _info(Icons.phone, 'ទូរសព្ទ', t.phone),
          _info(Icons.email, 'អ៊ីមែល', t.email),
          _info(Icons.account_circle, 'User ID', t.userid),
          _info(Icons.apartment, 'Faculty ID', t.facultyid, last: true),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label, String value, {bool last = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: const Color(0xFFFF5722)),
          title: Text(label, style: const TextStyle(fontSize: 12)),
          subtitle: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        if (!last) Divider(color: Colors.grey.shade200),
      ],
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
    ],
  );
}
