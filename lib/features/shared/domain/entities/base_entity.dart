abstract class BaseEntity {
  final String? id;

  const BaseEntity({this.id});

  Map<String, dynamic> toJson();
}
