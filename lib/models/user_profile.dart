class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String photoUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      photoUrl: json['photoUrl'] ?? '',
    );
  }
}