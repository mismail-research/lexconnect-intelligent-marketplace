class LawyerProfileModel {
  final String name;
  final String email;
  final String avatarUrl;
  final bool isAvailable;
  final String location;
  final String whatsappNumber;
  final int experienceYears;
  final int casesWon;
  final String lawyerType;

  const LawyerProfileModel({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.isAvailable,
    required this.location,
    required this.whatsappNumber,
    required this.experienceYears,
    required this.casesWon,
    required this.lawyerType,
  });

  factory LawyerProfileModel.fromMap(Map<String, dynamic> data) {
    return LawyerProfileModel(
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      avatarUrl: (data['avatarUrl'] ?? '').toString(),
      isAvailable: data['isAvailable'] ?? false,
      location: (data['officeLocation'] ?? '').toString(),
      whatsappNumber: (data['whatsAppNo'] ?? '').toString(),
      experienceYears:
      int.tryParse((data['experience'] ?? '0').toString()) ?? 0,
      casesWon: data['caseWon'] ?? 0,

      // 🔥 KEY FIX (NEVER NULL)
      lawyerType: (data['lawyerType'] ?? 'general').toString(),
    );
  }

  LawyerProfileModel copyWith({
    String? name,
    bool? isAvailable,
    String? location,
    String? whatsappNumber,
    int? experienceYears,
    int? casesWon,
    String? avatarUrl,
    String? lawyerType,
  }) {
    return LawyerProfileModel(
      name: name ?? this.name,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      casesWon: casesWon ?? this.casesWon,

      // 🔥 SAFE
      lawyerType: lawyerType ?? this.lawyerType,
    );
  }
}