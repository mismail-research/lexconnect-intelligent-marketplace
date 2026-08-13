import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/features/info/presentation/bloc/info_state.dart';

class LawyerTypeDropDown extends StatelessWidget {
  final LawyerType value;
  final ValueChanged<LawyerType> onChanged;

  const LawyerTypeDropDown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.15),
          width: 1.w,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LawyerType>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          style: AppStyle.style14w400(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: const [
            DropdownMenuItem(value: LawyerType.family, child: Text("Family")),
            DropdownMenuItem(
              value: LawyerType.criminal,
              child: Text("Criminal"),
            ),
            DropdownMenuItem(value: LawyerType.taxes, child: Text("Taxes")),
            DropdownMenuItem(value: LawyerType.civil, child: Text("Civil")),
          ],
        ),
      ),
    );
  }
}