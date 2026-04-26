class AppUser {
  final String id;
  final String name;
  final String email;
  final String? role;
  final bool onboardingCompleted;
  final bool voterIdVerified;
  final String volunteerAvailability;
  final bool isAnonymous;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.onboardingCompleted,
    required this.voterIdVerified,
    required this.volunteerAvailability,
    required this.isAnonymous,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString(),
      onboardingCompleted: json['onboardingCompleted'] == true,
      voterIdVerified: json['voterIdVerified'] == true,
      volunteerAvailability: json['volunteerAvailability']?.toString() ?? 'inactive',
      isAnonymous: json['isAnonymous'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'onboardingCompleted': onboardingCompleted,
      'voterIdVerified': voterIdVerified,
      'volunteerAvailability': volunteerAvailability,
      'isAnonymous': isAnonymous,
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? role,
    bool? onboardingCompleted,
    bool? voterIdVerified,
    String? volunteerAvailability,
    bool? isAnonymous,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      voterIdVerified: voterIdVerified ?? this.voterIdVerified,
      volunteerAvailability: volunteerAvailability ?? this.volunteerAvailability,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}
