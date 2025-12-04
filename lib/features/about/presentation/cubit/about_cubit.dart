import 'package:flutter_bloc/flutter_bloc.dart';

import 'about_state.dart';

class AboutCubit extends Cubit<AboutState> {
  AboutCubit() : super(AboutInitial());

  Future<void> loadMembers() async {
    emit(AboutLoading());
    try {
      // Simulate delay
      await Future.delayed(const Duration(milliseconds: 500));

      final members = [
        const TeamMember(
          name: 'Shofie',
          nim: '2209106007',
          imagePath: 'assets/images/shofie.jpg',
          instagram: 'https://instagram.com/shofie',
          github: 'https://github.com/shofie',
        ),
        const TeamMember(
          name: 'Member 2',
          nim: '2209106xxx',
          imagePath: 'assets/images/person1.png',
          instagram: 'https://instagram.com',
          github: 'https://github.com',
        ),
        const TeamMember(
          name: 'Member 3',
          nim: '2209106xxx',
          imagePath: 'assets/images/person2.png',
          instagram: 'https://instagram.com',
          github: 'https://github.com',
        ),
      ];

      emit(AboutLoaded(members));
    } catch (e) {
      emit(AboutError(e.toString()));
    }
  }

  String getAppVersion() {
    return "Version 1.0.0";
  }
}
