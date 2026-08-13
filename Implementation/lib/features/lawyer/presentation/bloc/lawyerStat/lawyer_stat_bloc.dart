import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexbid/features/lawyer/data/lawyer_home/lawyerAppointmentModel.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerStat/lawyer_stat_event.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerStat/lawyer_stat_state.dart';

class LawyerStatBloc extends Bloc<LawyerStatEvent, LawyerStatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LawyerStatBloc() : super(LawyerStatInitial()) {
    on<LoadAcceptedAppointments>(_loadAcceptedAppointments);
  }

  Future<void> _loadAcceptedAppointments(
      LoadAcceptedAppointments event, Emitter<LawyerStatState> emit) async {
    emit(LawyerStatLoading());
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        emit(LawyerStatError("User not logged in"));
        return;
      }

      // 1. Fetch appointments targeting ONLY this specific logged-in lawyer
      final snapshot = await _firestore
          .collection('appointments')
          .where('lawyerUid', isEqualTo: uid)
          .get();

      // 2. Generate the dynamic 6-month tracking window (matches UI perfectly)
      final List<DateTime> monthsWindow = _getMonthsWindow();

      // Initialize dataset structures for fl_chart metrics
      List<double> acceptedStats = List.filled(6, 0.0);
      List<double> completedStats = List.filled(6, 0.0);
      List<double> rejectedStats = List.filled(6, 0.0);

      List<LawyerAppointmentModel> acceptedAppointmentsList = [];

      // 3. Loop through your appointments dataset once
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String status = (data['status'] ?? '').toString().toLowerCase();

        // Safe field parsing blocks
        final clientName = data['clientName'] ?? 'Unknown';
        final consultationType = data['consultationType'] ?? data['consultancyType'] ?? 'General';
        final date = data['date'] ?? 'N/A';
        final day = data['day'] ?? '';
        final time = data['time'] ?? 'N/A';
        final imageUrl = data['imageUrl'];

        // Extract creation time to sort into correct month columns
        DateTime? createdAtDate;
        if (data['createdAt'] is Timestamp) {
          createdAtDate = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is String) {
          createdAtDate = DateTime.tryParse(data['createdAt']);
        }

        if (createdAtDate != null) {
          // Identify which month index (0 to 5) this appointment belongs to
          int monthIndex = _findMonthIndex(createdAtDate, monthsWindow);
          if (monthIndex != -1) {
            if (status == 'accepted') {
              acceptedStats[monthIndex]++;
            } else if (status == 'completed') {
              completedStats[monthIndex]++;
            } else if (status == 'rejected') {
              rejectedStats[monthIndex]++;
            }
          }
        }

        // Keep building your active upper list items dynamically
        if (status == 'accepted') {
          acceptedAppointmentsList.add(
            LawyerAppointmentModel(
              appointmentId: doc.id,
              clientName: clientName,
              consultancyType: consultationType,
              date: date,
              day: day,
              time: time,
              status: status,
              imageUrl: imageUrl,
            ),
          );
        }
      }

      // 4. Map keys perfectly to fit both your Line Chart AND bottom Stats row requirements
      final Map<String, List<double>> dynamicStats = {
        'accepted': acceptedStats,
        'completed': completedStats,
        'rejected': rejectedStats,
      };

      emit(LawyerStatLoaded(acceptedAppointmentsList, dynamicStats));
    } catch (e) {
      emit(LawyerStatError(e.toString()));
    }
  }

  // Helper logic to sync data precisely with your UI month intervals
  List<DateTime> _getMonthsWindow() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      return DateTime(now.year, now.month - 4 + index);
    });
  }

  int _findMonthIndex(DateTime date, List<DateTime> window) {
    for (int i = 0; i < window.length; i++) {
      if (window[i].year == date.year && window[i].month == date.month) {
        return i;
      }
    }
    return -1; // Out of dynamic bounds window range
  }
}