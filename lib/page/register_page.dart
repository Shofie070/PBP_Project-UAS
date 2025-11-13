import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../service/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  Future<void> _register() async {
    // ... (Logika register tidak diubah) ...
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirm = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wajib diisi")),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak sama")),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    final savedEmails = prefs.getStringList('registered_emails') ?? [];
    if (!savedEmails.contains(email)) {
      savedEmails.add(email);
      await prefs.setStringList('registered_emails', savedEmails);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrasi berhasil! Silakan login.")),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // --- Bagian Kiri (Form Register) - 40% ---
              Container(
                width: constraints.maxWidth * 0.4, // Lebar 40%
                height: constraints.maxHeight, // Tinggi penuh
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo Teks "UrbanWear"
                          Text(
                            "UrbanWear", 
                            style: TextStyle(
                              fontSize: 26.0, 
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Judul "Buat Akun Baru"
                          const Text(
                            "Buat Akun Baru",
                            style: TextStyle(
                              fontSize: 24.0, 
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 3.h),

                          // Input Fields
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: "Nama",
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: "Email",
                              prefixIcon: Icon(Icons.email_outlined, size: 20),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Password",
                              prefixIcon: Icon(Icons.lock_outline, size: 20),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Konfirmasi Password",
                              prefixIcon: Icon(Icons.lock_outline, size: 20),
                            ),
                          ),
                          SizedBox(height: 3.h),

                          // Tombol Daftar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _register,
                              child: const Text(
                                "Daftar",
                                style: TextStyle(
                                  fontSize: 14.0, 
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Link Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sudah punya akun? ",
                                  style: TextStyle(fontSize: 13.0)), 
                              TextButton(
                                onPressed: () {
                                  context.go(AppRoutes.login);
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(fontSize: 13.0), 
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // --- Bagian Kanan (Dekoratif) - 60% ---
              Expanded(
                child: Container(
                  height: constraints.maxHeight, // Tinggi penuh
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      // --- GANTI PATH INI DENGAN GAMBAR ANDA ---
                      image: AssetImage('assets/images/bg2.jpg'), // GANTI INI
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}