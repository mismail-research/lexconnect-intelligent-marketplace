import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class ChartStatsRow extends StatelessWidget {
  final Map<String, List<double>> monthlyStats;

  const ChartStatsRow({super.key, required this.monthlyStats});

  int _getTotal(List<double> list) {
    return list.fold(0.0, (a, b) => a + b).toInt();
  }

  Widget _item(Color color, String title, int value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: color.withAlpha(85),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: AppStyle.style16w800(),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: AppStyle.style12w600(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accepted = _getTotal(monthlyStats['accepted'] ?? []);
    final completed = _getTotal(monthlyStats['completed'] ?? []);
    final rejected = _getTotal(monthlyStats['rejected'] ?? []);

    return Row(
      children: [
        _item(AppColors.liteGreen, "Active", accepted),
        _item(AppColors.purpleColor, "Completed", completed),
        _item(AppColors.redColor, "Rejected", rejected),
      ],
    );
  }
}