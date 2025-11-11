import 'package:flutter_bloc/flutter_bloc.dart';
import 'about_state.dart';

class AboutCubit extends Cubit<AboutState> {
  AboutCubit() : super(AboutInitial());

  void loadMembers() {
    // Contoh data anggota
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
}
