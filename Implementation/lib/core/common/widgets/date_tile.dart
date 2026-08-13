import 'package:flutter/material.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class DateTile extends StatelessWidget {
  final String title;
  final DateTime? date;
  final VoidCallback onTap;

  const DateTile({
    super.key,
    required this.title,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppStyle.style16w400()),
      subtitle: Text(
        date == null
            ? "Select date"
            : "${date!.day}-${date!.month}-${date!.year}",
        style: AppStyle.style14w400(color: AppColors.liteBlue),
      ),
      trailing: const Icon(Icons.calendar_month),
      onTap: onTap,
    );
  }
}
