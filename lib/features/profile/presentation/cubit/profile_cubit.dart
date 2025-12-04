import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../model/model.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  Future<void> loadProfile(UserModel user) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('profile_image');
      final savedName = prefs.getString('user_name');
      final savedPhone = prefs.getString('user_phone');
      final savedDob = prefs.getString('user_dob');
      final savedCountry = prefs.getString('user_country');

      emit(state.copyWith(
        status: ProfileStatus.success,
        base64Image: data,
        name: (savedName != null && savedName.isNotEmpty)
            ? savedName
            : user.username,
        email: user.email,
        phone: savedPhone ?? '',
        dob: savedDob ?? '',
        selectedCountry: savedCountry,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: ProfileStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> saveProfile({
    required String name,
    required String phone,
    required String dob,
    String? country,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name.trim());
      await prefs.setString('user_phone', phone.trim());
      await prefs.setString('user_dob', dob.trim());
      if (country != null) {
        await prefs.setString('user_country', country);
      }

      emit(state.copyWith(
        status: ProfileStatus.success,
        name: name,
        phone: phone,
        dob: dob,
        selectedCountry: country,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: ProfileStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateImage(String base64) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', base64);
      emit(state.copyWith(base64Image: base64));
    } catch (e) {
      // ignore
    }
  }
}
