import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import '../../../../../../core/constants/app_color.dart';

class DateSelector extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Date",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 80.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, child) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = selectedDate != null &&
                  selectedDate!.day == date.day &&
                  selectedDate!.month == date.month;
              return _buildDateCard(date, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard(DateTime date, bool isSelected) {
    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: Container(
        width: 65.w,
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.borderColor.withValues().withAlpha(40),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            )
          ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E').format(date),
              style: AppStyle.style12w400(
                color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              DateFormat('d').format(date),
              style: AppStyle.style18w600(
                color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}