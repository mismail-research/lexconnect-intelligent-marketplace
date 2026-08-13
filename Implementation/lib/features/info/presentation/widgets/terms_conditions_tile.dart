import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

/// A required "I agree to the Terms & Conditions" checkbox tile, plus a
/// second required "Strict Confidentiality & Anti-Blackmail" checkbox.
///
/// TERMS & PRIVACY ROW (unchanged behavior):
/// [value] reflects whether the user has agreed, driven externally
/// (e.g. by a Bloc). [onChanged] is called whenever that checkbox is
/// toggled. [onTermsTap] / [onPrivacyTap] open the full documents.
///
/// CONFIDENTIALITY ROW (new):
/// Its agreement flag is kept locally inside this widget's State (it
/// survives parent rebuilds normally, so no external state wiring is
/// required). Use a `GlobalKey<TermsConditionsTileState>` from the
/// parent to read [TermsConditionsTileState.isConfidentialityAgreed]
/// before submitting, and call
/// [TermsConditionsTileState.setConfidentialityError] to highlight it
/// if the user tries to submit without checking it.
/// [onConfidentialityTap] opens the full confidentiality/anti-blackmail
/// document.
///
/// [showError] highlights the Terms & Privacy row in red when the user
/// tried to submit without agreeing to it.
class TermsConditionsTile extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onConfidentialityTap;
  final bool showError;

  const TermsConditionsTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onConfidentialityTap,
    this.showError = false,
  });

  @override
  State<TermsConditionsTile> createState() => TermsConditionsTileState();
}

class TermsConditionsTileState extends State<TermsConditionsTile> {
  bool _confidentialityAgreed = false;
  bool _confidentialityError = false;

  bool get isConfidentialityAgreed => _confidentialityAgreed;

  /// Lets the parent flag the confidentiality row as errored (e.g. when
  /// the user tries to submit without checking it).
  void setConfidentialityError(bool value) {
    setState(() => _confidentialityError = value);
  }

  void _toggleConfidentiality(bool v) {
    setState(() {
      _confidentialityAgreed = v;
      if (v) _confidentialityError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final termsBorderColor = widget.showError
        ? Colors.red.shade300
        : AppColors.liteBlue.withAlpha(60);

    final confidentialityBorderColor = _confidentialityError
        ? Colors.red.shade300
        : AppColors.liteBlue.withAlpha(60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// =========================
        /// TERMS & PRIVACY ROW (unchanged behavior)
        /// =========================
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: widget.showError
                ? Colors.red.withAlpha(10)
                : AppColors.liteBlue.withAlpha(12),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: termsBorderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: Checkbox(
                  value: widget.value,
                  activeColor: AppColors.liteBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  onChanged: (v) => widget.onChanged(v ?? false),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => widget.onChanged(!widget.value),
                  child: RichText(
                    text: TextSpan(
                      style: AppStyle.style14w400(
                        color: widget.showError
                            ? Colors.red.shade700
                            : Colors.grey.shade800,
                      ),
                      children: [
                        const TextSpan(
                            text: "I confirm that the information "
                                "provided is accurate and I agree to the "),
                        TextSpan(
                          text: "Terms & Conditions",
                          style: AppStyle.style14w400(
                            color: AppColors.liteBlue,
                          ).copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onTermsTap,
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: AppStyle.style14w400(
                            color: AppColors.liteBlue,
                          ).copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onPrivacyTap,
                        ),
                        const TextSpan(text: " of LexBid."),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        /// =========================
        /// STRICT CONFIDENTIALITY & ANTI-BLACKMAIL ROW (new)
        /// =========================
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: _confidentialityError
                ? Colors.red.withAlpha(10)
                : AppColors.liteBlue.withAlpha(12),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: confidentialityBorderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: Checkbox(
                  value: _confidentialityAgreed,
                  activeColor: AppColors.liteBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  onChanged: (v) => _toggleConfidentiality(v ?? false),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () =>
                      _toggleConfidentiality(!_confidentialityAgreed),
                  child: RichText(
                    text: TextSpan(
                      style: AppStyle.style14w400(
                        color: _confidentialityError
                            ? Colors.red.shade700
                            : Colors.grey.shade800,
                      ),
                      children: [
                        const TextSpan(
                            text: "I AGREE to the Strict Confidentiality "
                                "& Anti-Blackmail "),
                        TextSpan(
                          text: "Policy",
                          style: AppStyle.style14w400(
                            color: AppColors.liteBlue,
                          ).copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onConfidentialityTap,
                        ),
                        const TextSpan(text: " of LexBid."),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}