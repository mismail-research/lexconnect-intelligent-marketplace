import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexbid/features/client/data/bookAppointment/models/book_appointment_model.dart';

class AppointmentRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AppointmentRemoteDataSource({
    required this.firestore,
    required this.auth,
  });

  Future<void> bookAppointment(AppointmentBookingModel appointment) async {
    final clientUid = auth.currentUser!.uid;

    await firestore.collection("clients").doc(clientUid).set({
      "appointments": FieldValue.arrayUnion([
        appointment.toMap()
      ])
    }, SetOptions(merge: true));
  }
}