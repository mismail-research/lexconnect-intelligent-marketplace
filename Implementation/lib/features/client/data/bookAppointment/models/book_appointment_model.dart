class AppointmentBookingModel {
  final String clientUid;
  final String clientName;
  final String lawyerUid;
  final String lawyerName;
  final String consultationType;
  final String date;
  final String time;
  final String status;

  AppointmentBookingModel({
    required this.clientUid,
    required this.clientName,
    required this.lawyerUid,
    required this.lawyerName,
    required this.consultationType,
    required this.date,
    required this.time,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "clientUid": clientUid,
      "clientName": clientName,
      "lawyerUid": lawyerUid,
      "lawyerName": lawyerName,
      "consultationType": consultationType,
      "date": date,
      "time": time,
      "status": status,
    };
  }
}