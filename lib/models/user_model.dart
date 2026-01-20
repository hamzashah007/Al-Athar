class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final List<String> bookmarks;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.bookmarks = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'],
      displayName: map['displayName'],
      bookmarks: List<String>.from(map['bookmarks'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'bookmarks': bookmarks,
    };
  }
}
