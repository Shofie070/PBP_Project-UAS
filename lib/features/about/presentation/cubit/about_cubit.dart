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
          nim: '24111814070',
          imagePath: 'assets/images/shofie.jpg',
          instagram: 'https://www.instagram.com/shofie',
          github: 'https://github.com/Shofie070',
        ),
        const TeamMember(
          name: 'Nakula',
          nim: '24111814116',
          imagePath: 'assets/images/p1.jpg',
          instagram:
              'https://www.instagram.com/nakulasyafa_?igsh=MWN3ZDBvenZwbWtkdw==',
          github: 'https://github.com/Nklasyfa',
        ),
        const TeamMember(
          name: 'SULTAN RAFFI SURYANEGARA',
          nim: '24111814108',
          imagePath: 'assets/images/FOTO KUU.jpg',
          instagram:
              'https://www.instagram.com/sultanrsn?igsh=Z2htOHRqZm5iem90',
          github: 'https://github.com/SultanTnn',
        ),
        const TeamMember(
          name: 'PUTU NOVITA DARMADEWI',
          nim: '24111814007',
          imagePath: 'assets/images/person2.jpg',
          instagram: 'https://www.instagram.com/ncvtq?igsh=aXo2MzN6bG5ycXhl',
          github: 'https://github.com/Chokycakep',
        ),
        const TeamMember(
          name: 'Priyo Prakuso',
          nim: '24111814103',
          imagePath: 'assets/images/p1.jpg',
          instagram: 'https://www.instagram.com/pekzz199?igsh=d3AzNXRjdXlnZ3Bh',
          github: 'https://github.com/Pekzz-store',
        ),
        const TeamMember(
          name: 'Tabligh Akbar',
          nim: '24111814134',
          imagePath: 'assets/images/p1.jpg',
          instagram:
              'https://www.instagram.com/wessbar?igsh=MWcweTBjNDZ2ZW5qZA==',
          github: 'https://github.com/tablighakbar',
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
