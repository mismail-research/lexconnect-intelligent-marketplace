import 'package:equatable/equatable.dart';

enum Qualification { llb, llm }
enum LawyerType { family, criminal, taxes, civil }

class InfoState extends Equatable {
  final String businessName;
  final Qualification qualification;
  final LawyerType lawyerType;
  final DateTime? lowerCourtDate;
  final DateTime? highCourtDate;
  final bool isHighCourt;
  final String? profileImagePath;
  final String? barCardImagePath;
  final bool isSubmitting;
  final String? errorMessage; // Added to handle failures within the same state type
  final bool isSuccess;

  /// ✅ NEW: whether the user has agreed to the Terms & Conditions.
  /// Defaults to false so existing constructor calls (e.g. InfoFailure)
  /// don't need to change.
  final bool agreedToTerms;

  const InfoState({
    required this.businessName,
    required this.qualification,
    required this.lawyerType,
    this.lowerCourtDate,
    this.highCourtDate,
    required this.isHighCourt,
    this.profileImagePath,
    this.barCardImagePath,
    required this.isSubmitting,
    this.errorMessage,
    required this.isSuccess,
    this.agreedToTerms = false,
  });

  factory InfoState.initial() {
    return const InfoState(
      businessName: '',
      qualification: Qualification.llb,
      lawyerType: LawyerType.family,
      lowerCourtDate: null,
      highCourtDate: null,
      isHighCourt: false,
      profileImagePath: null,
      barCardImagePath: null,
      isSubmitting: false,
      errorMessage: null,
      isSuccess: false,
      agreedToTerms: false,
    );
  }

  InfoState copyWith({
    String? businessName,
    Qualification? qualification,
    LawyerType? lawyerType,
    DateTime? lowerCourtDate,
    DateTime? highCourtDate,
    bool? isHighCourt,
    String? profileImagePath,
    String? barCardImagePath,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
    bool? agreedToTerms,
  }) {
    return InfoState(
      businessName: businessName ?? this.businessName,
      qualification: qualification ?? this.qualification,
      lawyerType: lawyerType ?? this.lawyerType,
      lowerCourtDate: lowerCourtDate ?? this.lowerCourtDate,
      highCourtDate: highCourtDate ?? this.highCourtDate,
      isHighCourt: isHighCourt ?? this.isHighCourt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      barCardImagePath: barCardImagePath ?? this.barCardImagePath,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      // We set this to null by default unless a new error is passed
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    );
  }

  @override
  List<Object?> get props => [
    businessName,
    qualification,
    lawyerType,
    lowerCourtDate,
    highCourtDate,
    isHighCourt,
    profileImagePath,
    barCardImagePath,
    isSubmitting,
    errorMessage,
    isSuccess,
    agreedToTerms,
  ];
}

// Fixed the InfoFailure class to call the super constructor correctly
class InfoFailure extends InfoState {
  final String message;

  const InfoFailure(this.message)
      : super(
      businessName: '',
      qualification: Qualification.llb,
      lawyerType: LawyerType.family,
      isHighCourt: false,
      isSubmitting: false,
      errorMessage: message,
      isSuccess: false
  );

  @override
  List<Object?> get props => [message];
}