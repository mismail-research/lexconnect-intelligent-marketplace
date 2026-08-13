import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/core/common/widgets/custom_botton.dart';
import 'package:lexbid/core/common/widgets/custom_textfield.dart';
import 'package:lexbid/core/common/widgets/date_tile.dart';
import 'package:lexbid/core/common/widgets/lawyerType_dropDown.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_strings.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/core/utils/app_padding.dart';
import 'package:lexbid/features/info/presentation/bloc/info_bloc.dart';
import 'package:lexbid/features/info/presentation/bloc/info_event.dart';
import 'package:lexbid/features/info/presentation/bloc/info_state.dart';
import 'package:lexbid/features/info/presentation/widgets/bar_card_upload_tile.dart';
import 'package:lexbid/features/info/presentation/widgets/required_label.dart';
import 'package:lexbid/features/info/presentation/widgets/terms_conditions_tile.dart';
import 'package:lexbid/routes.dart';

class InfoView extends StatelessWidget {
  InfoView({super.key});

  /// Used to reach [TermsConditionsTileState] so we can check whether
  /// the user agreed to the Strict Confidentiality & Anti-Blackmail
  /// checkbox before allowing submission — without needing to touch
  /// InfoBloc/InfoState for this new, locally-held flag.
  final GlobalKey<TermsConditionsTileState> _termsKey =
  GlobalKey<TermsConditionsTileState>();

  /// Renamed from `_showImageSourceDialog` — local functions/variables
  /// shouldn't use a leading underscore in Dart; that prefix is reserved
  /// for library-private top-level/class members.
  void showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (bottomSheetContext) {
        final bloc = context.read<InfoBloc>();

        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.liteBlue,
                  ),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    bloc.add(
                      PickProfileImage(ImageSource.gallery),
                    );
                  },
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.liteBlue,
                ),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);

                  bloc.add(
                    PickProfileImage(ImageSource.camera),
                  );
                },
              ),

              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  /// Simple in-app viewer for the full Terms & Conditions / Privacy
  /// Policy / Confidentiality & Anti-Blackmail text. Swap this for a
  /// dedicated route/WebView if you already host these documents
  /// elsewhere.
  void showLegalDocument(BuildContext context, String title, String body) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyle.style16w400().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        body,
                        style: AppStyle.style14w400(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InfoBloc()..add(LoadInitialData()),
      child: BlocListener<InfoBloc, InfoState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppFlushBar.showError(
              context,
              message: state.errorMessage!,
            );
          }

          if (state.isSuccess) {
            Navigator.pushReplacementNamed(
              context,
              RouteGenerator.approvalPending,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Padding(
            padding: AppPadding.afterAuth,
            child: SingleChildScrollView(
              child: BlocBuilder<InfoBloc, InfoState>(
                builder: (context, state) {
                  final bloc = context.read<InfoBloc>();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      /// =========================
                      /// PROFILE SECTION IMPROVED
                      /// =========================
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      showImageSourceDialog(context),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: EdgeInsets.all(4.r),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.liteBlue,
                                          AppColors.liteGreen,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          // withOpacity -> withValues to avoid precision loss
                                          color: AppColors.liteBlue
                                              .withValues(alpha: 0.20),
                                          blurRadius: 15,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 58.r,
                                      backgroundColor:
                                      AppColors.whiteColor,
                                      child: CircleAvatar(
                                        radius: 54.r,
                                        backgroundColor:
                                        Colors.grey.shade200,
                                        backgroundImage:
                                        state.profileImagePath != null
                                            ? FileImage(
                                          File(
                                            state.profileImagePath!,
                                          ),
                                        )
                                            : null,
                                        child:
                                        state.profileImagePath == null
                                            ? Icon(
                                          Icons.person_rounded,
                                          size: 60.sp,
                                          color:
                                          Colors.grey.shade500,
                                        )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  bottom: 2.h,
                                  right: -2.w,
                                  child: GestureDetector(
                                    onTap: () =>
                                        showImageSourceDialog(context),
                                    child: Container(
                                      padding: EdgeInsets.all(10.r),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.liteBlue,
                                            AppColors.liteGreen,
                                          ],
                                        ),
                                        border: Border.all(
                                          color: AppColors.whiteColor,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            // withOpacity -> withValues to avoid precision loss
                                            color: Colors.black
                                                .withValues(alpha: 0.12),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color: AppColors.whiteColor,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 14.h),

                            Text(
                              "Upload Profile Picture",
                              style: AppStyle.style16w400(),
                            ),

                            SizedBox(height: 5.h),

                            Text(
                              "Tap to choose from gallery or camera",
                              textAlign: TextAlign.center,
                              style: AppStyle.style14w400(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28.h),

                      /// BUSINESS NAME
                      RequiredLabel(
                        title: AppStrings.businessName,
                      ),

                      CustomTextField(
                        width: double.infinity,
                        height: 60.h,
                        hintText: "Your name",
                        controller: bloc.businessNameController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
                      ),

                      SizedBox(height: 5.h),

                      RequiredLabel(
                        title: AppStrings.whatsAppNo,
                      ),

                      CustomTextField(
                        width: double.infinity,
                        height: 60.h,
                        hintText: "e.g. 03XXXXXXXXX",
                        controller: bloc.whatsAppNoController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                      ),

                      SizedBox(height: 5.h),

                      /// BAR COUNCIL NUMBER
                      RequiredLabel(
                        title: AppStrings.barCouncilNumber,
                      ),

                      CustomTextField(
                        width: double.infinity,
                        height: 60.h,
                        hintText: "e.g. 12345/LHC",
                        controller: bloc.barCouncilController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(9),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9A-Za-z/]'),
                          ),
                        ],
                      ),

                      SizedBox(height: 7.h),

                      Text(
                        "Lawyer Type",
                        style: AppStyle.style16w400(),
                      ),

                      SizedBox(height: 5.h),

                      LawyerTypeDropDown(
                        value: state.lawyerType,
                        onChanged: (type) {
                          bloc.add(SelectLawyerType(type));
                        },
                      ),

                      SizedBox(height: 7.h),

                      /// QUALIFICATION
                      Text(
                        AppStrings.qualification,
                        style: AppStyle.style16w400(),
                      ),

                      /// RadioGroup replaces the deprecated per-Radio
                      /// `groupValue` / `onChanged` params (deprecated
                      /// since Flutter 3.32).
                      RadioGroup<Qualification>(
                        groupValue: state.qualification,
                        onChanged: (v) {
                          if (v != null) {
                            bloc.add(SelectQualification(v));
                          }
                        },
                        child: Row(
                          children: [
                            Radio<Qualification>(
                              activeColor: AppColors.liteBlue,
                              value: Qualification.llb,
                            ),

                            Text(
                              AppStrings.lLB,
                              style: AppStyle.style14w400(),
                            ),

                            Radio<Qualification>(
                              activeColor: AppColors.liteBlue,
                              value: Qualification.llm,
                            ),

                            Text(
                              AppStrings.lLM,
                              style: AppStyle.style14w400(),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 5.h),

                      /// LOWER COURT DATE
                      DateTile(
                        title: AppStrings.enrollmentLowerCourt,
                        date: state.lowerCourtDate,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1980),
                            lastDate: DateTime.now(),
                          );

                          if (date != null) {
                            bloc.add(SelectLowerCourtDate(date));
                          }
                        },
                      ),

                      /// HIGH COURT TOGGLE
                      SwitchListTile(
                        contentPadding: EdgeInsets.only(right: 10.w),
                        activeThumbColor: AppColors.liteBlue,
                        title: Text(
                          AppStrings.highCourtAdvocate,
                          style: AppStyle.style16w400(),
                        ),
                        value: state.isHighCourt,
                        onChanged: (v) =>
                            bloc.add(ToggleHighCourt(v)),
                      ),

                      /// HIGH COURT DATE
                      if (state.isHighCourt)
                        DateTile(
                          title: AppStrings.endorsementHighCourt,
                          date: state.highCourtDate,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1980),
                              lastDate: DateTime.now(),
                            );

                            if (date != null) {
                              bloc.add(SelectHighCourtDate(date));
                            }
                          },
                        ),

                      SizedBox(height: 25.h),

                      Text(
                        "Office Location",
                        style: AppStyle.style16w400(),
                      ),

                      CustomTextField(
                        width: double.infinity,
                        height: 60.h,
                        hintText: "e.g. Faisalabad",
                        controller: bloc.officeLocationController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(16),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),

                      if (state.lowerCourtDate != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                            horizontal: 14.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.liteBlue.withAlpha(20),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.liteBlue.withAlpha(60),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timeline_rounded,
                                color: AppColors.liteBlue,
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "${AppStrings.experience}: "
                                    "${DateTime.now().year - state.lowerCourtDate!.year} years",
                                style: AppStyle.style16w400(),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 5.h),

                      Text(
                        AppStrings.caseWon,
                        style: AppStyle.style16w400(),
                      ),

                      CustomTextField(
                        width: double.infinity,
                        height: 60.h,
                        hintText: "no.of",
                        controller: bloc.caseWonController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        AppStrings.barCardPhoto,
                        style: AppStyle.style16w400(),
                      ),

                      SizedBox(height: 5.h),

                      BarCardUploadTile(
                        imagePath: state.barCardImagePath,
                        onTap: () {
                          bloc.add(
                            PickBarCardImage(ImageSource.gallery),
                          );
                        },
                      ),

                      SizedBox(height: 20.h),

                      /// =========================
                      /// TERMS & CONDITIONS + CONFIDENTIALITY
                      /// =========================
                      TermsConditionsTile(
                        key: _termsKey,
                        value: state.agreedToTerms,
                        showError: !state.agreedToTerms &&
                            (state.errorMessage
                                ?.contains("Terms & Conditions") ??
                                false),
                        onChanged: (v) =>
                            bloc.add(ToggleTermsAgreement(v)),
                        onTermsTap: () => showLegalDocument(
                          context,
                          "Terms & Conditions",
                          termsAndConditionsText,
                        ),
                        onPrivacyTap: () => showLegalDocument(
                          context,
                          "Privacy Policy",
                          privacyPolicyText,
                        ),
                        onConfidentialityTap: () => showLegalDocument(
                          context,
                          "Strict Confidentiality & Anti-Blackmail Policy",
                          confidentialityAndAntiBlackmailText,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      /// SUBMIT
                      CustomButton(
                        width: double.infinity,
                        height: 45.h,
                        gradientColors: [
                          AppColors.liteBlue,
                          AppColors.liteGreen,
                        ],
                        text: "Submit",
                        textStyle: AppStyle.style16w400(
                          color: AppColors.whiteColor,
                        ),
                        onTap: state.isSubmitting
                            ? null
                            : () {
                          final confidentialityAgreed = _termsKey
                              .currentState?.isConfidentialityAgreed ??
                              false;

                          if (!confidentialityAgreed) {
                            _termsKey.currentState
                                ?.setConfidentialityError(true);
                            AppFlushBar.showError(
                              context,
                              message:
                              "Please agree to the Strict Confidentiality & "
                                  "Anti-Blackmail Policy to continue.",
                            );
                            return;
                          }

                          bloc.add(SubmitLawyerInfo());
                        },
                        child: state.isSubmitting
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : null,
                      ),

                      SizedBox(height: 20.h),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Replace with your actual legal copy, or fetch it from Firestore /
/// a CMS if it needs to change without a store release.
const String termsAndConditionsText = '''
Welcome to LexBid. By registering as a lawyer on this platform, you agree
to the following terms:

1. You confirm that all information, documents, and credentials
   (including your Bar Council number and bar card image) submitted are
   true, accurate, and belong to you.
2. LexBid reserves the right to verify your credentials with the
   relevant Bar Council and to reject or suspend any profile found to
   contain false or misleading information.
3. You are responsible for keeping your profile information up to
   date.
4. LexBid acts as a platform connecting clients with lawyers and is not
   a party to any engagement between you and a client.
5. Misuse of the platform, impersonation, or fraudulent submissions may
   result in permanent suspension of your account.

Please read the full Terms & Conditions on our website before
continuing.
''';

const String privacyPolicyText = '''
LexBid collects the information you provide during registration
(including your profile photo, bar card image, contact number, and
professional details) to verify your identity as a licensed lawyer and
to display your profile to prospective clients.

We do not sell your personal data. Information may be shared with the
relevant Bar Council solely for verification purposes. You may request
access to, correction of, or deletion of your data at any time by
contacting support.

Please read the full Privacy Policy on our website for complete
details.
''';

/// New: Strict Confidentiality & Anti-Blackmail commitment shown behind
/// the second checkbox in TermsConditionsTile. Replace with your actual
/// legal copy, or fetch it from Firestore / a CMS if it needs to change
/// without a store release.
const String confidentialityAndAntiBlackmailText = '''
As a lawyer registering on LexBid, you additionally agree to the following
Strict Confidentiality & Anti-Blackmail commitments:

1. You will keep all client communications, case details, and personal
   information shared through this platform strictly confidential and
   will not disclose them to any third party without lawful authority
   or client consent.
2. You will not use any information obtained through this platform to
   threaten, coerce, intimidate, or blackmail any client, opposing
   party, or other user of LexBid.
3. You will not misuse your access to client documents, bar card
   details, or personal data for personal gain or to pressure any
   party involved in a case.
4. Any attempt at blackmail, extortion, harassment, or confidentiality
   breach will result in immediate suspension of your account and may
   be reported to the relevant Bar Council and law enforcement
   authorities.
5. This commitment applies for the duration of your use of LexBid and
   continues to apply after any engagement with a client has ended.

Please read the full policy on our website before continuing.
''';