import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class LawyerProgressChart extends StatelessWidget {
  final Map<String, List<double>> monthlyStats;

  const LawyerProgressChart({super.key, required this.monthlyStats});

  @override
  Widget build(BuildContext context) {
    final months = getCustomMonths(); // ✅ single source of truth

    return Container(
      height: 230.h,
      padding: EdgeInsets.only(top: 20.h, right: 20.w, left: 10.w, bottom: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.buttonGradient1,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.liteBlue,
              strokeWidth: 1.w,
              dashArray: [5, 5],
            ),
            horizontalInterval: 15,
          ),
          titlesData: _buildTitles(months), // ✅ pass months
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                  color: AppColors.lightGrey.withAlpha(50), width: 1.w),
              left: BorderSide(
                  color: AppColors.lightGrey.withAlpha(50), width: 1.w),
            ),
          ),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            _lineData(AppColors.liteGreen, monthlyStats['accepted'] ?? []),
            _lineData(AppColors.purpleColor, monthlyStats['completed'] ?? []),
            _lineData(AppColors.redColor, monthlyStats['rejected'] ?? []),
          ],
        ),
      ),
    );
  }

  // ---------------- LINE DATA ----------------
  LineChartBarData _lineData(Color color, List<double> spots) {
    return LineChartBarData(
      spots: spots
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 4.w,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withAlpha(20), color.withAlpha(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // ---------------- TITLES ----------------
  FlTitlesData _buildTitles(List<String> months) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 35.w,
          interval: 20,
          getTitlesWidget: (value, meta) => Text(
            value.toInt().toString(),
            style: AppStyle.style10w500(color: AppColors.whiteColor),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();

            if (index < 0 || index >= months.length) {
              return const SizedBox();
            }

            return Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                months[index],
                style: AppStyle.style10w500(color: AppColors.whiteColor),
              ),
            );
          },
        ),
      ),
      rightTitles:
      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles:
      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  // ---------------- MONTH LOGIC ----------------
  List<String> getCustomMonths() {
    final now = DateTime.now();

    return List.generate(6, (index) {
      final monthDate = DateTime(now.year, now.month - 4 + index);
      return _getMonthName(monthDate.month);
    });
  }

  String _getMonthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return names[month - 1];
  }
}