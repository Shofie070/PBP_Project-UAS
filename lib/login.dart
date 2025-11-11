import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'model/model.dart';
import 'app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Fungsi untuk mendapatkan widget tombol login dengan GFButton
  Widget getLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: GFButton(
        // Menggunakan GFButton dari GetWidget
        onPressed: _login,
        text: "MASUK",
        shape: GFButtonShape.standard, // Bentuk tombol standar
        color: GFColors.PRIMARY, // Warna biru default GetWidget
        size: GFSize.LARGE, // Ukuran tombol yang lebih besar
        fullWidthButton: true, // Membuat tombol full width
        icon: const Icon(
          Icons.login,
          color: Colors.white,
        ),
        textStyle: TextStyle(
            // Dihapus 'const'
            fontSize: 12.sp, // Menggunakan sp
            color: Colors.white,
            fontWeight: FontWeight.bold),
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

    // Admin credentials (allowed anytime)
    const String adminEmail = 'admin@admin.com';
    const String adminPassword = 'admin123';

    if (email == adminEmail && password == adminPassword) {
      // Login as admin
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

    // Normal user: check SharedPreferences (must have registered earlier)
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            "assets/images/background.png",
            fit: BoxFit.cover,
          ),
          Center(
            child: SingleChildScrollView(
              child: Card(
                color: const Color(0xFFF8BBD0), // Pink pastel
                elevation: 8,
                margin: EdgeInsets.symmetric(horizontal: 10.w), // Menggunakan w
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5.w), // Menggunakan w
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        // Dihapus 'const'
                        "Selamat Datang!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // Dihapus 'const'
                          fontSize: 18.sp, // Menggunakan sp
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE573B4), // Pink lucu
                        ),
                      ),
                      SizedBox(height: 1.h), // Menggunakan h
                      Text(
                        // Dihapus 'const'
                        "Silakan masuk untuk melanjutkan",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // Dihapus 'const'
                          fontSize: 12.sp, // Menggunakan sp
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 5.h), // Menggunakan h
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      SizedBox(height: 2.h), // Menggunakan h
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h), // Menggunakan h
                      getLoginButton(),
                      SizedBox(height: 2.h), // Menggunakan h
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.register);
                        },
                        child: const Text("Belum punya akun? Daftar"),
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
