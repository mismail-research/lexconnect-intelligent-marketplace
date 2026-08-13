import 'package:image_picker/image_picker.dart';
import 'package:lexbid/features/info/presentation/bloc/info_state.dart';

abstract class InfoEvent {}

class LoadInitialData extends InfoEvent {}

class SelectQualification extends InfoEvent {
  final Qualification qualification;
  SelectQualification(this.qualification);
}

class SelectProfileImage extends InfoEvent {
  final String imagePath;
  SelectProfileImage(this.imagePath);
}

class SelectLowerCourtDate extends InfoEvent {
  final DateTime date;
  SelectLowerCourtDate(this.date);
}

class SelectHighCourtDate extends InfoEvent {
  final DateTime date;
  SelectHighCourtDate(this.date);
}

class ToggleHighCourt extends InfoEvent {
  final bool value;
  ToggleHighCourt(this.value);
}

class PickProfileImage extends InfoEvent {
  final ImageSource source;
  PickProfileImage(this.source);
}
class SelectLawyerType extends InfoEvent {
  final LawyerType lawyerType;
  SelectLawyerType(this.lawyerType);
}

class PickBarCardImage extends InfoEvent {
  final ImageSource source;
  PickBarCardImage(this.source);
}

/// ✅ NEW: fired when the user checks/unchecks the
/// "I agree to the Terms & Conditions" tile.
class ToggleTermsAgreement extends InfoEvent {
  final bool value;
  ToggleTermsAgreement(this.value);
}

class SubmitLawyerInfo extends InfoEvent {}