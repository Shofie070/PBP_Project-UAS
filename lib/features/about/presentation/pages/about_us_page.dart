import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubit/about_cubit.dart';
import '../cubit/about_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/shared/routes/app_router.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AboutCubit()..loadMembers(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            "About Us",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              tooltip: 'Home',
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. BACKGROUND IMAGE
            Image.asset(
              'assets/images/bg3.jpg',
              fit: BoxFit.cover,
            ),

            // Overlay tipis
            Container(
              color: Colors.black.withOpacity(0.3),
            ),

            // 2. KONTEN
            BlocBuilder<AboutCubit, AboutState>(
              builder: (context, state) {
                if (state is AboutLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                } else if (state is AboutLoaded) {
                  return _buildContent(context, state.members);
                } else if (state is AboutError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TeamMember> members) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 900;
      double responsiveSize(double mobileSp, double desktopPx) =>
          isDesktop ? desktopPx : mobileSp.sp;

      return SingleChildScrollView(
        // Padding diatur agar konten mulai agak dari atas dan tidak mepet kiri
        padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 6.w,
            isDesktop ? 100 : 15.h, isDesktop ? 32 : 6.w, isDesktop ? 40 : 5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // RATA KIRI
          children: [
            // === JUDUL & DESKRIPSI (RATA KIRI) ===
            Text(
              "KELOMPOK 1",
              style: TextStyle(
                color: Colors.white,
                fontSize: responsiveSize(24, 32), // Font diperbesar sedikit
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                shadows: const [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            SizedBox(height: isDesktop ? 10 : 1.h),

            // Subjudul
            Text(
              "We Work Hard, We Play Hard",
              style: TextStyle(
                color: Colors.white,
                fontSize: responsiveSize(12, 16),
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: isDesktop ? 10 : 1.h),

            // Deskripsi Singkat (New)
            SizedBox(
              width: isDesktop
                  ? 600
                  : 80.w, // Membatasi lebar teks agar tidak terlalu panjang ke kanan
              child: Text(
                "Kami adalah tim pengembang aplikasi mobile yang berdedikasi untuk menciptakan solusi digital inovatif dengan antarmuka yang modern dan pengalaman pengguna yang terbaik.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: responsiveSize(11, 14),
                  height: 1.5, // Jarak antar baris
                ),
              ),
            ),

            SizedBox(height: isDesktop ? 40 : 6.h),

            // === GRID MEMBER (DI TENGAH) ===
            // Menggunakan Container width infinity agar Wrap berada di tengah layar horizontal
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: isDesktop ? 30 : 5.w, // Jarak horizontal diperlebar
                runSpacing: isDesktop ? 50 : 5.h, // Jarak vertikal diperlebar
                alignment: WrapAlignment.center, // Kartu tetap di tengah layar
                children: members.map((member) {
                  return _MemberItem(
                      member: member,
                      responsiveSize: responsiveSize,
                      isDesktop: isDesktop);
                }).toList(),
              ),
            ),

            SizedBox(height: isDesktop ? 80 : 10.h),

            // FOOTER
            Center(
              child: Text(
                context.read<AboutCubit>().getAppVersion(),
                style: TextStyle(
                    color: Colors.white54, fontSize: responsiveSize(10, 12)),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// === WIDGET ITEM ANGGOTA ===
class _MemberItem extends StatelessWidget {
  final TeamMember member;
  final Function responsiveSize;
  final bool isDesktop;
  final ValueNotifier<bool> _isHovered = ValueNotifier(false);

  _MemberItem(
      {required this.member,
      required this.responsiveSize,
      required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isHovered,
        builder: (context, isHovered, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. BAGIAN FOTO (DIPERBESAR)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                transform: isHovered
                    ? (Matrix4.identity()..scale(1.05))
                    : Matrix4.identity(),
                // UKURAN DIPERBESAR
                width: isDesktop ? 180 : 40.w, // Sebelumnya 140
                height: isDesktop ? 220 : 50.w, // Sebelumnya 160
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isHovered
                          ? Colors.purpleAccent.withOpacity(0.5)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: isHovered ? 25 : 15,
                      offset:
                          isHovered ? const Offset(0, 10) : const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    member.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.person,
                          size: isDesktop ? 80 : 20.w, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              SizedBox(height: isDesktop ? 20 : 2.h),

              // 2. BAGIAN INFO
              Text(
                member.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsiveSize(14, 18), // Font Nama diperbesar
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1)),
                  ],
                ),
              ),

              SizedBox(height: isDesktop ? 5 : 0.5.h),

              Text(
                "NIM: ${member.nim}",
                style: TextStyle(
                  color: Colors.purple[100],
                  fontSize: responsiveSize(11, 14), // Font NIM diperbesar
                  fontWeight: FontWeight.w600,
                  shadows: const [
                    Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1)),
                  ],
                ),
              ),

              SizedBox(height: isDesktop ? 15 : 2.h),

              // 3. TOMBOL SOSMED
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _socialButton(
                      "https://cdn-icons-png.flaticon.com/512/25/25231.png",
                      () => _launch(member.github),
                      isDesktop),
                  SizedBox(width: isDesktop ? 20 : 5.w),
                  _socialButton(
                      "https://cdn-icons-png.flaticon.com/512/1077/1077042.png",
                      () => _launch(member.instagram),
                      isDesktop),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _socialButton(String imageUrl, VoidCallback onTap, bool isDesktop) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: EdgeInsets.all(
              isDesktop ? 10 : 2.w), // Padding tombol sedikit diperbesar
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 1.5),
            color: Colors.black.withOpacity(0.2),
          ),
          child: Image.network(
            imageUrl,
            width: isDesktop ? 22 : 5.w, // Icon diperbesar
            height: isDesktop ? 22 : 5.w,
            color: Colors.white,
            errorBuilder: (ctx, _, __) => Icon(Icons.link,
                color: Colors.white, size: isDesktop ? 22 : 5.w),
          ),
        ),
      ),
    );
  }

  Future<void> _launch(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Tidak bisa membuka URL: $urlString");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
}
