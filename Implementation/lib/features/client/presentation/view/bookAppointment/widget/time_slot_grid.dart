import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lexbid/core/constants/app_color.dart';

class TimeSlotSelector extends StatelessWidget {
  final List<String> timeSlots;
  final String? selectedTime;
  final DateTime? selectedDate;
  final Function(String) onTimeSelected;

  const TimeSlotSelector({
    super.key,
    required this.timeSlots,
    required this.selectedTime,
    required this.selectedDate,
    required this.onTimeSelected,
  });

  bool isPastTime(String time, DateTime? selectedDate) {
    if (selectedDate == null) return false;

    final format = DateFormat("hh:mm a");
    final parsed = format.parse(time);

    final slotDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      parsed.hour,
      parsed.minute,
    );

    return slotDateTime.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Time",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp, // Scaled for text responsiveness
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 50.h, // Dynamic scale container height
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: timeSlots.length,
            separatorBuilder: (_, child) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final time = timeSlots[index];
              final isSelected = selectedTime == time;
              final isDisabled = isPastTime(time, selectedDate);

              return GestureDetector(
                onTap: isDisabled ? null : () => onTimeSelected(time),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isDisabled
                        ? Colors.grey.shade300
                        : isSelected
                        ? null
                        : AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: isSelected || isDisabled
                        ? null
                        : Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isDisabled
                          ? AppColors.lightGrey
                          : isSelected
                          ? AppColors.whiteColor
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp, // Explicit scale applied to children items
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}