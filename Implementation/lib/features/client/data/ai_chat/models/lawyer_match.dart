class LawyerMatch {
  final String id;
  final String name;
  final String location;
  final String avatarUrl;
  final int experienceYears;
  final int casesWon;
  final bool isAvailable;
  final Map<String, dynamic> rawData; // 👈 full Firestore data

  const LawyerMatch({
    required this.id,
    required this.name,
    required this.location,
    required this.avatarUrl,
    required this.experienceYears,
    required this.casesWon,
    required this.isAvailable,
    required this.rawData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'avatarUrl': avatarUrl,
    'experienceYears': experienceYears,
    'casesWon': casesWon,
    'isAvailable': isAvailable,
    'rawData': rawData,
  };

  factory LawyerMatch.fromJson(Map<String, dynamic> json) => LawyerMatch(
    id: json['id'] as String,
    name: json['name'] as String,
    location: json['location'] as String,
    avatarUrl: json['avatarUrl'] as String,
    experienceYears: json['experienceYears'] as int,
    casesWon: json['casesWon'] as int,
    isAvailable: json['isAvailable'] as bool,
    rawData: (json['rawData'] as Map<String, dynamic>?) ?? {},
  );
}