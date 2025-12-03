import 'package:equatable/equatable.dart';

/// Model Data Anggota Tim
class TeamMember {
  final String name;
  final String nim;
  final String imagePath;
  final String github;
  final String instagram;

  const TeamMember({
    required this.name,
    required this.nim,
    required this.imagePath,
    required this.github,
    required this.instagram,
  });
}

/// Definisi State
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
