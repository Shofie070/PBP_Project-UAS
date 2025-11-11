import 'package:flutter_bloc/flutter_bloc.dart';
import '../about_state.dart';

class AboutCubit extends Cubit<AboutState> {
  AboutCubit() : super(AboutInitial());

  void loadMembers() {
    final members = [
      Member(
        name: "John Doe",
        nim: "12345678",
        role: "Leader",
        github: "https://github.com/johndoe",
        instagram: "https://instagram.com/johndoe",
        imagePath: "assets/images/john_doe.png",
      ),
      Member(
        name: "Jane Smith",
        nim: "87654321",
        role: "Member",
        github: "https://github.com/janesmith",
        instagram: "https://instagram.com/janesmith",
        imagePath: "assets/images/jane_smith.png",
      ),
    ];

    emit(AboutLoaded(members));
  }

  String getAppDescription() {
    return ' R, nous croyons que la mode est plus qu’un vêtement — c’est une expression de lumière intérieure...';
  }

  String getAppVersion() {
    return 'Versi aplikasi 1.0.0';
  }

  String getTeamEmail() {
    return 'kelompok1@unesa.ac.id';
  }

  String getTeamPhone() {
    return '+62 857 8571 4197';
  }
}
