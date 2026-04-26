class VolunteerProfileModel {
  final String id;
  final String name;
  final String email;
  final String availability;
  final bool voterIdVerified;

  const VolunteerProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.availability,
    required this.voterIdVerified,
  });

  factory VolunteerProfileModel.fromJson(Map<String, dynamic> json) {
    return VolunteerProfileModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Volunteer',
      email: json['email']?.toString() ?? '',
      availability: json['volunteerAvailability']?.toString() ?? 'inactive',
      voterIdVerified: json['voterIdVerified'] == true,
    );
  }
}
