class ClientProfileModel {
  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final String whatsappNumber;

  ClientProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.whatsappNumber,
  });

  factory ClientProfileModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ClientProfileModel(
      // Priority: docId from Firestore > map field > empty string
      uid: docId ?? map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      whatsappNumber: map['whatsappNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'whatsappNumber': whatsappNumber,
    };
  }

  ClientProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? avatarUrl,
    String? whatsappNumber,
  }) {
    return ClientProfileModel(
      // Use the local 'this.uid' but provide a fallback if it's somehow null
      // even though it's marked non-nullable in Dart.
      uid: uid ?? (this.uid ?? ''),
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }
}