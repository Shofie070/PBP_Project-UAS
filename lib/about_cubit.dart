import 'package:flutter_bloc/flutter_bloc.dart';
import 'about_state.dart';

class AboutCubit extends Cubit<AboutState> {
  AboutCubit() : super(AboutInitial());

  // Fungsi untuk memuat data anggota
  void loadMembers() async {
    emit(AboutLoading());

    // Simulasi delay loading agar terlihat efeknya (opsional, bisa dihapus)
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Data Hardcoded Anggota Kelompok 1
      final List<TeamMember> members = [
        TeamMember(
          name: "Nakula",
          nim: "111",
          imagePath: "assets/images/FOTO KUU.jpg", // Pastikan foto ini ada
          github: "https://github.com/sultan",
          instagram: "https://instagram.com/sultan",
        ),
        TeamMember(
          name: "shofie",
          nim: "123",
          imagePath: "assets/images/novita.jpg",
          github: "https://github.com/novita",
          instagram: "https://instagram.com/ncvtq",
        ),
        TeamMember(
          name: "Novita",
          nim: "124",
          imagePath: "assets/images/shofie.jpg",
          github: "https://github.com/shofie",
          instagram: "https://instagram.com/shofie",
        ),
        TeamMember(
          name: "sultan",
          nim: "125",
          imagePath: "assets/images/nakula.jpg",
          github: "https://github.com/nakula",
          instagram: "https://instagram.com/nakula",
        ),
        TeamMember(
          name: "Priyo",
          nim: "126",
          imagePath: "assets/images/priyo.jpg",
          github: "https://github.com/priyo",
          instagram: "https://instagram.com/priyo",
        ),
        TeamMember(
          name: "Tabligh",
          nim: "127",
          imagePath: "assets/images/tabligh.jpg",
          github: "https://github.com/tabligh",
          instagram: "https://instagram.com/tabligh",
        ),
      ];

      emit(AboutLoaded(members));
    } catch (e) {
      emit(const AboutError("Gagal memuat data anggota tim."));
    }
  }

  // Helper function untuk info versi aplikasi
  String getAppVersion() {
    return "Version 1.0.0 • Kelompok 1";
  }
}
