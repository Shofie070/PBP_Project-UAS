import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? base64Image;
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String? selectedCountry;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.base64Image,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.dob = '',
    this.selectedCountry,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? base64Image,
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? selectedCountry,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      base64Image: base64Image ?? this.base64Image,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        base64Image,
        name,
        email,
        phone,
        dob,
        selectedCountry,
        errorMessage,
      ];
}
