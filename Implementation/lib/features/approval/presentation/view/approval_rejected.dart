import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/common/widgets/custom_botton.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/routes.dart';
import 'package:lexbid/widgets/error.dart';

class ApprovalRejectedPage extends StatelessWidget {
  const ApprovalRejectedPage({super.key});

  Future<void> _editInformation(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final uid = currentUser.uid;

    await FirebaseFirestore.instance
        .collection("lawyers")
        .doc(uid)
        .update({
      "approvalStatus": "edit pending",
      "submissionTime": FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(
      context,
      RouteGenerator.lawyerInfoRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔥 Replaced Icon(Icons.cancel) with ErrorShot from secondary file
              ErrorShot(size: 150.r),

              SizedBox(height: 20.h),

              Text(
                "Request Rejected",
                style: AppStyle.style20w900(),
              ),

              SizedBox(height: 10.h),

              Text(
                "Your information does not satisfy the legal lawyer criteria.",
                textAlign: TextAlign.center,
                style: AppStyle.style14w400(),
              ),

              SizedBox(height: 30.h),

              CustomButton(
                width: 180.w,
                height: 45.h,
                gradientColors: [
                  AppColors.liteBlue,
                  AppColors.liteGreen,
                ],
                text: "Edit Information",
                textStyle: AppStyle.style16w400(
                  color: AppColors.whiteColor,
                ),
                onTap: () => _editInformation(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}