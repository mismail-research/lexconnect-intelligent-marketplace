class LawyerAppointmentModel {
  final String appointmentId;
  final String clientName;
  final String consultancyType;
  final String date;
  final String time;
  final String day; // 🔥 Added back
  final String? imageUrl;
  final String status;
  final bool isSeenByLawyer;


  LawyerAppointmentModel({
    required this.appointmentId,
    required this.clientName,
    required this.consultancyType,
    required this.date,
    required this.time,
    required this.day, // 🔥 Required now
    required this.status,
    this.imageUrl,
    this.isSeenByLawyer = false,
  });
}