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

    // Simpan data ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);

    // Simpan daftar email terdaftar (sederhana)
    final savedEmails = prefs.getStringList('registered_emails') ?? [];
    if (!savedEmails.contains(email)) {
      savedEmails.add(email);
      await prefs.setStringList('registered_emails', savedEmails);
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrasi berhasil! Silakan login.")),
    );

    // Navigasi ke halaman login setelah 1 detik
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Menggunakan StackFit.expand
        children: [
          // Background Image
          Image.asset(
            "assets/images/background.png",
            fit: BoxFit.cover,
          ),
          Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                margin:
                    EdgeInsets.symmetric(horizontal: 10.w), // Unit responsif
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5.w), // Unit responsif
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        // Dihapus const
                        "Buat Akun Baru",
                        style: TextStyle(
                          // Dihapus const
                          fontSize: 16.sp, // Unit responsif
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3.h), // Unit responsif
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Nama",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h), // Unit responsif
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h), // Unit responsif
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h), // Unit responsif
                      TextField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Konfirmasi Password",
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h), // Unit responsif
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 200, 200, 200),
                            padding: EdgeInsets.symmetric(
                                vertical: 1.8.h), // Unit responsif
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: _register,
                          child: Text(
                            // Dihapus const
                            "Daftar",
                            style: TextStyle(
                              // Dihapus const
                              fontSize: 12.sp, // Unit responsif
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.login);
                        },
                        child: const Text("Sudah punya akun? Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
