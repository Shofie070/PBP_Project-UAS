import 'package:flutter_bloc/flutter_bloc.dart';
import 'about_state.dart';

class AboutCubit extends Cubit<AboutState> {
  AboutCubit() : super(AboutInitial());

  void loadMembers() {
    final members = [
      Member(
        name: 'Shofie',
        nim: '1234567890',
        imagePath: 'assets/images/member1.jpg',
        instagram: 'https://instagram.com/anggota1',
        github: 'https://github.com/anggota1',
      ),
      Member(
        name: 'Putu',
        nim: '1234567891',
        imagePath: 'assets/images/member2.jpg',
        instagram: 'https://instagram.com/ncvtq',
        github: 'https://github.com/Chokycakep',
      ),
      Member(
        name: 'Sultan',
        nim: '1234567892',
        imagePath: 'assets/images/member3.jpg',
        instagram: 'https://instagram.com/anggota3',
        github: 'https://github.com/anggota3',
      ),
      Member(
        name: 'Nakula',
        nim: '1234567893',
        imagePath: 'assets/images/member4.jpg',
        instagram: 'https://instagram.com/anggota4',
        github: 'https://github.com/anggota4',
      ),
      Member(
        name: 'Priyo',
        nim: '1234567894',
        imagePath: 'assets/images/member5.jpg',
        instagram: 'https://instagram.com/anggota5',
        github: 'https://github.com/anggota5',
      ),
      Member(
        name: 'Tabligh',
        nim: '1234567895',
        imagePath: 'assets/images/member6.jpg',
        instagram: 'https://instagram.com/anggota6',
        github: 'https://github.com/anggota6',
      ),
    ];

    emit(AboutLoaded(members));
  }

  String getAppVersion() => "Version 1.0.0";
}
