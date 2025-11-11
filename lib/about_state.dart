import 'package:equatable/equatable.dart';

class Member {
  final String name;
  final String nim;
  final String role;
  final String github;
  final String instagram;
  final String imagePath;

  Member({
    required this.name,
    required this.nim,
    required this.role,
    required this.github,
    required this.instagram,
    required this.imagePath,
  });
}

abstract class AboutState extends Equatable {
  const AboutState();

  @override
  List<Object?> get props => [];
}

class AboutInitial extends AboutState {}

class AboutLoaded extends AboutState {
  final List<Member> members;
  const AboutLoaded(this.members);

  @override
  List<Object?> get props => [members];
}
