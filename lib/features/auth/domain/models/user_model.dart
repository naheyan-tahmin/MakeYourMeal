class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
