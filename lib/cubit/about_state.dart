abstract class AboutState {}

class AboutInitial extends AboutState {}

class AboutLoaded extends AboutState {
  final List<Member> members;

  AboutLoaded(this.members); // ✅ gunakan posisi langsung, bukan named argument
}

class Member {
  final String name;
  final String nim;
  final String imagePath;
  final String instagram;
  final String github;

  Member({
    required this.name,
    required this.nim,
    required this.imagePath,
    required this.instagram,
    required this.github,
  });
}
