import 'package:equatable/equatable.dart';

class TeamMember extends Equatable {
  final String name;
  final String nim;
  final String imagePath;
  final String instagram;
  final String github;

  const TeamMember({
    required this.name,
    required this.nim,
    required this.imagePath,
    required this.instagram,
    required this.github,
  });

  @override
  List<Object> get props => [name, nim, imagePath, instagram, github];
}

abstract class AboutState extends Equatable {
  const AboutState();

  @override
  List<Object> get props => [];
}

class AboutInitial extends AboutState {}

class AboutLoading extends AboutState {}

class AboutLoaded extends AboutState {
  final List<TeamMember> members;

  const AboutLoaded(this.members);

  @override
  List<Object> get props => [members];
}

class AboutError extends AboutState {
  final String message;

  const AboutError(this.message);

  @override
  List<Object> get props => [message];
}
