class ClientAppointmentModel {
  final String appointmentId;
  final String lawyerUid;
  final String lawyerName;
  final String consultancyType;
  final String date;
  final String time;
  final String? imageUrl;
  final String status;

  /// Rating Fields
  final bool isRated;
  final double givenRating;
  final bool isSeenByClient;

  ClientAppointmentModel({
    required this.appointmentId,
    required this.lawyerUid,
    required this.lawyerName,
    required this.consultancyType,
    required this.date,
    required this.time,
    this.imageUrl,
    required this.status,

    /// Optional with defaults
    this.isRated = false,
    this.givenRating = 0.0,
    this.isSeenByClient = false,
  });

  factory ClientAppointmentModel.fromMap(
      Map<String, dynamic> map,
      String docId,
      ) {
    return ClientAppointmentModel(
      appointmentId: docId,
      lawyerUid: map['lawyerUid'] ?? '',
      lawyerName: map['lawyerName'] ?? 'Unknown',
      consultancyType: map['consultationType'] ?? 'N/A',
      date: map['date'] ?? 'N/A',
      time: map['time'] ?? 'N/A',
      imageUrl: map['imageUrl'] ?? map['avatarUrl'],
      status: map['status'] ?? 'pending',

      /// Rating Data
      isRated: map['isRated'] ?? false,
      givenRating: (map['givenRating'] ?? 0).toDouble(),
      isSeenByClient: map['isSeenByClient'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'lawyerUid': lawyerUid,
      'lawyerName': lawyerName,
      'consultationType': consultancyType,
      'date': date,
      'time': time,
      'imageUrl': imageUrl,
      'status': status,

      /// Rating Data
      'isRated': isRated,
      'givenRating': givenRating,
    };
  }

  ClientAppointmentModel copyWith({
    String? appointmentId,
    String? lawyerUid,
    String? lawyerName,
    String? consultancyType,
    String? date,
    String? time,
    String? imageUrl,
    String? status,
    bool? isRated,
    double? givenRating,
  }) {
    return ClientAppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      lawyerUid: lawyerUid ?? this.lawyerUid,
      lawyerName: lawyerName ?? this.lawyerName,
      consultancyType: consultancyType ?? this.consultancyType,
      date: date ?? this.date,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isRated: isRated ?? this.isRated,
      givenRating: givenRating ?? this.givenRating,
    );
  }
}