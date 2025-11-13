import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../model/model.dart';
import '../service/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _keepLoggedIn = true; // State untuk checkbox

  void _login() async {
    // ... (Logika login tidak diubah) ...
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password wajib diisi")),
      );
      return;
    }
    const String adminEmail = 'admin@admin.com';
    const String adminPassword = 'admin123';
    if (email == adminEmail && password == adminPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('current_user_email', adminEmail);
      if (mounted) {
        context.go(
          AppRoutes.dashboard,
          extra: UserModel(username: 'Admin', email: adminEmail),
        );
      }
      return;
    }
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
      if (mounted) {
        context.go(
          AppRoutes.dashboard,
          extra: UserModel(username: storedName, email: storedEmail),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Email atau password salah. Silakan coba lagi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // --- Bagian Kiri (Form Login) - 40% ---
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

                          // Judul (Teks Anda)
                          const Text(
                            "Selamat Datang!",
                            style: TextStyle(
                              fontSize: 24.0, 
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          
                          // Subjudul (Teks Anda)
                          Text(
                            "Silakan masuk untuk melanjutkan",
                            style: TextStyle(
                              fontSize: 14.0, 
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 3.h),

                          // Garis "Or sign in with email"
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[300])),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1.w),
                                child: Text(
                                  "Or sign in with email",
                                  style: TextStyle(
                                      fontSize: 12.0, 
                                      color: Colors.grey[500]),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey[300])),
                            ],
                          ),
                          SizedBox(height: 3.h),

                          // Input Fields
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined, size: 20),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Checkbox dan Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _keepLoggedIn,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _keepLoggedIn = value ?? false;
                                      });
                                    },
                                  ),
                                  const Text('Keep me logged in',
                                      style: TextStyle(fontSize: 13.0)), 
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(fontSize: 13.0), 
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),

                          // Tombol Login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              child: const Text(
                                "MASUK",
                                style: TextStyle(
                                  fontSize: 14.0, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Link Daftar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ",
                                  style: TextStyle(fontSize: 13.0)), 
                              TextButton(
                                onPressed: () {
                                  context.go(AppRoutes.register);
                                },
                                child: const Text(
                                  "Sign up",
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
                      image: AssetImage('assets/images/bg3.jpg'), // GANTI INI
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