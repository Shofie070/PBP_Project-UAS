import 'package:flutter/material.dart';
import 'package:flutter_application_1/cubit/about_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../cubit/about_cubit.dart';
import '../../cubit/about_state.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AboutCubit()..loadMembers(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("About Us"),
          backgroundColor: Colors.pinkAccent,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/background.png', fit: BoxFit.cover),
            BlocBuilder<AboutCubit, AboutState>(
              builder: (context, state) {
                if (state is AboutInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AboutLoaded) {
                  return _buildContent(context, state);
                } else {
                  return const Center(child: Text('Gagal memuat data'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AboutLoaded state) {
    final cubit = context.read<AboutCubit>();

    return Center(
      child: SingleChildScrollView(
        child: Card(
          color: const Color.fromARGB(255, 164, 0, 0).withOpacity(0.85),
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/FOTO KUU.jpg',
                    height: 25.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  'd’ÉTOILE WEAR',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  cubit.getAppDescription(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.pinkAccent),
                  title: const Text('Email'),
                  subtitle: Text(cubit.getTeamEmail()),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.pinkAccent),
                  title: const Text('Telepon'),
                  subtitle: Text(cubit.getTeamPhone()),
                ),
                const Divider(),
                const Text(
                  'Team Kelompok 1',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 1.h),

                // === Data dari Cubit ===
                ...state.members.map(
                  (m) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(m.imagePath),
                    ),
                    title: Text(m.name),
                    subtitle: Text('NiM: ${m.nim}\nRole: ${m.role}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () => _launchUrl(context, m.github),
                    ),
                    onTap: () => _launchUrl(context, m.instagram),
                  ),
                ),

                SizedBox(height: 1.5.h),
                Text(
                  cubit.getAppVersion(),
                  style: TextStyle(
                    color: const Color.fromARGB(137, 255, 255, 255),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) {
    // Tambahkan logika untuk membuka URL
  }
}
