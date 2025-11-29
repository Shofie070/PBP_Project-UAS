import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../model/model.dart';
import '../../service/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _keepLoggedIn = true;

  void _login() async {
    // ... (Logika login tetap sama) ...
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
          bool isDesktop = constraints.maxWidth > 900;

          // --- FUNGSI STANDARD UKURAN (Login & Register pakai ini) ---
          double responsiveSize(double mobileSp, double desktopPx) {
            return isDesktop ? desktopPx : mobileSp.sp;
          }

          return Row(
            children: [
              // --- KIRI: FORM ---
              Expanded(
                flex: isDesktop ? 4 : 10,
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 6.w),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo
                            Text(
                              "UrbanWear",
                              style: TextStyle(
                                fontSize: responsiveSize(22, 32), // DISAMAKAN
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: responsiveSize(1.h, 20)),

                            // Judul
                            Text(
                              "Selamat Datang!",
                              style: TextStyle(
                                fontSize: responsiveSize(18, 24), // DISAMAKAN
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: responsiveSize(0.5.h, 8)),
                            
                            // Subjudul
                            Text(
                              "Silakan masuk untuk melanjutkan",
                              style: TextStyle(
                                fontSize: responsiveSize(10, 14), // DISAMAKAN
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: responsiveSize(3.h, 40)),

                            // Input Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: responsiveSize(11, 14)), // DISAMAKAN
                              decoration: InputDecoration(
                                hintText: 'Email',
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                prefixIcon: Icon(Icons.email_outlined, size: responsiveSize(16, 20)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20), // DISAMAKAN
                              ),
                            ),
                            SizedBox(height: responsiveSize(2.h, 20)),

                            // Input Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              style: TextStyle(fontSize: responsiveSize(11, 14)), // DISAMAKAN
                              decoration: InputDecoration(
                                hintText: 'Password',
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                prefixIcon: Icon(Icons.lock_outline, size: responsiveSize(16, 20)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: responsiveSize(16, 20),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20), // DISAMAKAN
                              ),
                            ),
                            SizedBox(height: responsiveSize(1.h, 10)),

                            // Checkbox & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale: isDesktop ? 1.0 : 0.8, // Kecilkan checkbox di HP
                                      child: Checkbox(
                                        value: _keepLoggedIn,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _keepLoggedIn = value ?? false;
                                          });
                                        },
                                        activeColor: Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4)),
                                      ),
                                    ),
                                    Text('Keep me logged in',
                                        style: TextStyle(fontSize: responsiveSize(9, 13))),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                        fontSize: responsiveSize(9, 13),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: responsiveSize(2.h, 30)),

                            // Tombol Masuk
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16), // DISAMAKAN
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  "MASUK",
                                  style: TextStyle(
                                    fontSize: responsiveSize(12, 14), // DISAMAKAN
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: responsiveSize(2.h, 20)),

                            // Link Register
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? ",
                                    style: TextStyle(
                                        fontSize: responsiveSize(9, 13),
                                        color: Colors.grey[600])),
                                TextButton(
                                  onPressed: () {
                                    context.go(AppRoutes.register);
                                  },
                                  child: Text(
                                    "Sign up",
                                    style: TextStyle(
                                        fontSize: responsiveSize(9, 13),
                                        fontWeight: FontWeight.bold),
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
              ),

              // --- KANAN: GAMBAR (Desktop Only) ---
              if (isDesktop)
                Expanded(
                  flex: 6,
                  child: Container(
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg3.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
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