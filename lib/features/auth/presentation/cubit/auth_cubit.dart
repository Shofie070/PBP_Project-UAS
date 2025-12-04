import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (isLoggedIn) {
        final email = prefs.getString('current_user_email');
        final name = prefs.getString('user_name') ?? 'User';

        if (email != null) {
          emit(AuthAuthenticated(UserModel(
            username: name,
            email: email,
            password: '', // Password not needed for session
          )));
          return;
        }
      }
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('user_email');
      final storedPassword = prefs.getString('user_password');
      final storedName = prefs.getString('user_name') ?? 'User';

      if (storedEmail == null || storedPassword == null) {
        emit(const AuthFailure(
            'Akun belum terdaftar. Silakan daftar terlebih dahulu.'));
        return;
      }

      if (email == storedEmail && password == storedPassword) {
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('current_user_email', storedEmail);

        emit(AuthAuthenticated(UserModel(
          username: storedName,
          email: storedEmail,
          password: '',
        )));
      } else {
        emit(const AuthFailure('Email atau password salah.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);

      final savedEmails = prefs.getStringList('registered_emails') ?? [];
      if (!savedEmails.contains(email)) {
        savedEmails.add(email);
        await prefs.setStringList('registered_emails', savedEmails);
      }

      emit(AuthRegistered());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('current_user_email');
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
