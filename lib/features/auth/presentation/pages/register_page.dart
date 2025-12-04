import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';
import '../../../../features/shared/routes/app_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

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

  void _register() {
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

    context.read<AuthCubit>().register(name, email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Registrasi berhasil! Silakan login.")),
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                context.go(AppRoutes.login);
              }
            });
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 900;

              // --- FUNGSI STANDARD UKURAN ---
              double responsiveSize(double mobileSp, double desktopPx) {
                return isDesktop ? desktopPx : mobileSp.sp;
              }

              return Row(
                children: [
                  // =========================================
                  // BAGIAN KIRI: FORM REGISTER
                  // =========================================
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
                                    fontSize: responsiveSize(22, 32),
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox(height: responsiveSize(1.h, 20)),

                                // Judul
                                Text(
                                  "Buat Akun Baru",
                                  style: TextStyle(
                                    fontSize: responsiveSize(18, 24),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: responsiveSize(3.h, 40)),

                                // --- INPUT FIELDS (Helper Method) ---
                                _buildBubbleInput(
                                    context,
                                    _nameController,
                                    "Nama",
                                    Icons.person_outline,
                                    responsiveSize),
                                SizedBox(height: responsiveSize(2.h, 20)),

                                _buildBubbleInput(
                                    context,
                                    _emailController,
                                    "Email",
                                    Icons.email_outlined,
                                    responsiveSize),
                                SizedBox(height: responsiveSize(2.h, 20)),

                                _buildBubbleInput(
                                    context,
                                    _passwordController,
                                    "Password",
                                    Icons.lock_outline,
                                    responsiveSize,
                                    isPassword: true),
                                SizedBox(height: responsiveSize(2.h, 20)),

                                _buildBubbleInput(
                                    context,
                                    _confirmController,
                                    "Konfirmasi Password",
                                    Icons.lock_outline,
                                    responsiveSize,
                                    isPassword: true),

                                SizedBox(height: responsiveSize(3.h, 30)),

                                // Tombol Daftar
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            height: responsiveSize(12, 14),
                                            width: responsiveSize(12, 14),
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            "Daftar",
                                            style: TextStyle(
                                              fontSize: responsiveSize(12, 14),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: responsiveSize(2.h, 20)),

                                // Link Login
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Sudah punya akun? ",
                                        style: TextStyle(
                                            fontSize: responsiveSize(9, 13))),
                                    TextButton(
                                      onPressed: () {
                                        context.go(AppRoutes.login);
                                      },
                                      child: Text(
                                        "Login",
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

                  // =========================================
                  // BAGIAN KANAN: GAMBAR & LOTTIE (Desktop Only)
                  // =========================================
                  if (isDesktop)
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/bg3.jpg'), // Background Image
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Layer 1: Overlay Gelap Transparan
                            Container(
                              color: Colors.black.withOpacity(0.3),
                            ),

                            // Layer 2: Animasi Lottie (Dibalik Horizontal/Mirror)
                            Center(
                              child: Transform.flip(
                                flipX: true, // MEMBALIK ARAH MENGHADAP KIRI
                                child: Lottie.asset(
                                  'assets/json/person1.json',
                                  width: 600,
                                  height: 600,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Helper untuk input yang konsisten
  Widget _buildBubbleInput(
      BuildContext context,
      TextEditingController controller,
      String hint,
      IconData icon,
      Function responsiveSize,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(fontSize: responsiveSize(11.0, 14.0)),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        prefixIcon: Icon(icon, size: responsiveSize(16.0, 20.0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}
