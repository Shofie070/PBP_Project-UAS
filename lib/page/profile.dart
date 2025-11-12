import 'package:flutter/material.dart';
import '../model/model.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Text('Halo, ${user.username}'),
      ),
    );
  }
}
