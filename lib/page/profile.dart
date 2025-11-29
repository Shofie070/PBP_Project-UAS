import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/model.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('profile_image');
    setState(() => _base64Image = data);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final b64 = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', b64);
      setState(() => _base64Image = b64);
    } catch (e) {
      if (kDebugMode) print('Image pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memilih foto')));
    }
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image');
    setState(() => _base64Image = null);
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (_base64Image != null) {
      final bytes = base64Decode(_base64Image!);
      avatar = CircleAvatar(radius: 48, backgroundImage: MemoryImage(bytes));
    } else {
      avatar = const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Center(child: avatar),
            const SizedBox(height: 12),
            Text(widget.user.username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.user.email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Foto'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _base64Image == null ? null : _removeImage,
              icon: const Icon(Icons.delete),
              label: const Text('Hapus Foto'),
            ),
          ],
        ),
      ),
    );
  }
}
