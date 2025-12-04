import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';
import '../../../../features/shared/routes/app_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

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

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password wajib diisi")),
      );
      return;
    }

    context.read<AuthCubit>().login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.dashboard, extra: state.user);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 900;
              double responsiveSize(double mobileSp, double desktopPx) {
                return isDesktop ? desktopPx : mobileSp.sp;
              }

              return Row(
                children: [
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
                                Text(
                                  "UrbanWear",
                                  style: TextStyle(
                                    fontSize: responsiveSize(22, 32),
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox(height: responsiveSize(1.h, 20)),
                                Text(
                                  "Selamat Datang!",
                                  style: TextStyle(
                                    fontSize: responsiveSize(18, 24),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: responsiveSize(0.5.h, 8)),
                                Text(
                                  "Silakan masuk untuk melanjutkan",
                                  style: TextStyle(
                                    fontSize: responsiveSize(10, 14),
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: responsiveSize(3.h, 40)),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                      fontSize: responsiveSize(11, 14)),
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    filled: true,
                                    fillColor: const Color(0xFFF3F4F6),
                                    prefixIcon: Icon(Icons.email_outlined,
                                        size: responsiveSize(16, 20)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                                  ),
                                ),
                                SizedBox(height: responsiveSize(2.h, 20)),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscureText,
                                  style: TextStyle(
                                      fontSize: responsiveSize(11, 14)),
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    filled: true,
                                    fillColor: const Color(0xFFF3F4F6),
                                    prefixIcon: Icon(Icons.lock_outline,
                                        size: responsiveSize(16, 20)),
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
                                        vertical: 16, horizontal: 20),
                                  ),
                                ),
                                SizedBox(height: responsiveSize(1.h, 10)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: isDesktop ? 1.0 : 0.8,
                                          child: Checkbox(
                                            value: _keepLoggedIn,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _keepLoggedIn = value ?? false;
                                              });
                                            },
                                            activeColor:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                          ),
                                        ),
                                        Text('Keep me logged in',
                                            style: TextStyle(
                                                fontSize:
                                                    responsiveSize(9, 13))),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: responsiveSize(2.h, 30)),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        state is AuthLoading ? null : _login,
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
                                    child: state is AuthLoading
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
                                            "MASUK",
                                            style: TextStyle(
                                              fontSize: responsiveSize(12, 14),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: responsiveSize(2.h, 20)),
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
                        child: Stack(
                          children: [
                            Container(
                              color: Colors.black.withOpacity(0.3),
                            ),
                            Center(
                              child: Transform.flip(
                                flipX: true,
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
}
