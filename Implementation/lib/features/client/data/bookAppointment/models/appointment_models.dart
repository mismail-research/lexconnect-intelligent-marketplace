class Lawyer {
  final String uid;
  final String name;
  final String imageUrl;
  final String specialization;
  final String location;

  Lawyer({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.specialization,
    required this.location,
  });

  factory Lawyer.fromMap(Map<String, dynamic> map) {
    return Lawyer(
      uid: map['uid'] ?? '',
      name: map['businessName'] ?? map['name'] ?? '',
      imageUrl: map['avatarUrl'] ?? '',
      specialization: map['lawyerType'] ?? '',
      location: map['officeLocation'] ?? 'Pakistan',
    );
  }
}
// ADD THIS MODEL HERE
class ConsultationType {
  final String id;
  final String title;
  final String subtitle;
  final String iconPath;

  ConsultationType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconPath,
  });
}