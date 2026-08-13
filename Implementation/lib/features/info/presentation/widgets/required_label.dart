import 'package:flutter/material.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class RequiredLabel extends StatelessWidget {

  final String title;

  const RequiredLabel({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return RichText(
      text: TextSpan(
        text: title,
        style: AppStyle.style16w400(),
        children:  [
          TextSpan(
            text: " *",
            style: AppStyle.style16w400(
              color: AppColors.redColor
            )
          ),
        ],
      ),
    );
  }
}