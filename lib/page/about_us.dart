import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cubit/about_cubit.dart';
import '../../cubit/about_state.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return BlocProvider(
          create: (_) => AboutCubit()..loadMembers(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'About Us',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blueAccent,
            ),
            body: BlocBuilder<AboutCubit, AboutState>(
              builder: (context, state) {
                if (state is AboutInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AboutLoaded) {
                  final members = state.members;
                  return Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Meet Our Team',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Expanded(
                          child: ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 1.h),
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 8.w,
                                        backgroundImage:
                                            AssetImage(member.imagePath),
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              member.name,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              member.nim,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              FontAwesomeIcons.instagram,
                                              color: Colors.pink,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _launchUrl(member.instagram),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              FontAwesomeIcons.github,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _launchUrl(member.github),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Failed to load team data.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
