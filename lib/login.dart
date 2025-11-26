import 'dart:ui'; // PENTING: Import ini untuk efek Blur (ImageFilter)
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DashboardPage.dart';
import 'model/model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Tombol Login: Putih Solid agar kontras dengan kaca transparan
  Widget getLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: GFButton(
        onPressed: _login,
        text: "MASUK",
        shape: GFButtonShape.standard,
        color: Colors.white, // Tombol Putih
        size: GFSize.LARGE,
        fullWidthButton: true,
        icon: const Icon(Icons.login, color: Colors.black),
        textStyle: const TextStyle(
            fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password wajib diisi")),
      );
      return;
    }

    // Admin
    const String adminEmail = 'adm';
    const String adminPassword = 'adm';

    if (email == adminEmail && password == adminPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('current_user_email', adminEmail);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            user: UserModel(username: 'Admin', email: adminEmail),
          ),
        ),
      );
      return;
    }

    // User
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('user_email');
    final storedPassword = prefs.getString('user_password');
    final storedName = prefs.getString('user_name') ?? 'User';

    if (storedEmail == null || storedPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Akun belum terdaftar. Silakan daftar terlebih dahulu.")),
      );
      return;
    }

    if (email == storedEmail && password == storedPassword) {
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('current_user_email', storedEmail);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            user: UserModel(username: storedName, email: storedEmail),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Email atau password salah. Silakan coba lagi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Style Input Field agar cocok di atas kaca
    InputDecoration glassInputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        // Background input lebih gelap sedikit agar teks terbaca jelas
        fillColor: Colors.black.withOpacity(0.2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            "assets/images/background.png",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.black),
          ),

          // 2. Overlay Gelap (Sedikit lebih terang agar efek kaca terlihat)
          Container(color: Colors.black.withOpacity(0.5)),

          // 3. Konten Login (Glassmorphism)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  // EFEK BLUR (KACA)
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        // WARNA SEMI PUTIH TRANSPARAN
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white
                                .withOpacity(0.2), // Border putih tipis
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Judul
                        const Text(
                          "Selamat Datang!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Silakan masuk untuk melanjutkan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Input Email
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              glassInputDecoration('Email', Icons.email),
                        ),
                        const SizedBox(height: 16),

                        // Input Password
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              glassInputDecoration('Password', Icons.lock)
                                  .copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Tombol Login
                        getLoginButton(),

                        const SizedBox(height: 20),

                        // Link Daftar
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            "Belum punya akun? Daftar",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
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
