abstract class AboutState {
  const AboutState();
}

class AboutInitial extends AboutState {
  const AboutInitial();
}

class AboutLoaded extends AboutState {
  final List<Member> members;
  
  const AboutLoaded({required this.members});
}

class AboutError extends AboutState {
  final String message;
  
  const AboutError(this.message);
}

class Member {
  final String name;
  final String nim;
  final String role;
  final String imagePath;
  final String instagram;
  final String github;

  Member({
    required this.name,
    required this.nim,
    required this.role,
    required this.imagePath,
    required this.instagram,
    required this.github,
  });
}
