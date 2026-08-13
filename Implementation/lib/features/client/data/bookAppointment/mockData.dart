// MockData in your data layer
import 'package:lexbid/core/constants/app_strings.dart';
import 'package:lexbid/features/client/data/bookAppointment/models/appointment_models.dart';


class MockData {
  static List<ConsultationType> get consultationTypes => [
    ConsultationType(
        id: '1',
        title: AppStrings.online,
        subtitle: "Video call with lawyer",
        iconPath: "video"
    ),
    ConsultationType(
        id: '2',
        title: AppStrings.lawyerOffice,
        subtitle: "Visit the lawyer at their office",
        iconPath: "office"
    ),
    ConsultationType(
        id: '3',
        title: AppStrings.clientOffice,
        subtitle: "Lawyer visit your location",
        iconPath: "location"
    ),
  ];

  static List<String> get timeSlots => [
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "02:00 PM",
    "03:00 PM"
  ];
}