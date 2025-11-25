// lib/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/model.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_${widget.user.email}');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() => _profileImage = File(imagePath));
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin akses galeri ditolak!")),
      );
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'profile_image_${widget.user.email}', pickedFile.path);
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profil Saya"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pengaturan segera hadir!")),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // BACKGROUND + GRADIENT BIAR KONTRAS BANGET
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.65), // biar tulisan kontras
          ),

          // KONTEN PROFIL
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // FOTO PROFIL + GANTI FOTO
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Text(
                                  widget.user.username[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pinkAccent,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.pinkAccent,
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    widget.user.username,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.user.email,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _chip("Member Gold", Icons.star, Colors.amber),
                      const SizedBox(width: 16),
                      _chip("Level 10", Icons.emoji_events, Colors.purple),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // MENU DENGAN ICON WARNA TDK TENGGELAM
                  _menuItem(Icons.shopping_bag, "Pesanan Saya", Colors.orange),
                  _menuItem(
                      Icons.location_on, "Alamat Pengiriman", Colors.green),
                  _menuItem(Icons.local_offer, "Voucher Saya", Colors.purple),
                  _menuItem(Icons.favorite, "Wishlist", Colors.red),
                  _menuItem(Icons.history, "Riwayat Transaksi", Colors.blue),
                  if (widget.user.email == 'admin@admin.com')
                    _menuItem(Icons.admin_panel_settings, "Menu Admin",
                        Colors.deepPurple),

                  const SizedBox(height: 50),

                  // LOGOUT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, size: 28),
                      label: const Text("Keluar Akun",
                          style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Text(
                    "Urban Wear App • v1.0 • Made with ❤️ by us",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: Colors.white.withOpacity(0.9),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("$title segera hadir!"), backgroundColor: color),
          );
        },
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
