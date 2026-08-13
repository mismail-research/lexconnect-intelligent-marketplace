import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class LegalQuotesCard extends StatefulWidget {
  final String imagePath;

  const LegalQuotesCard({
    super.key,
    required this.imagePath,
  });

  @override
  State<LegalQuotesCard> createState() => _LegalQuotesCardState();
}

class _LegalQuotesCardState extends State<LegalQuotesCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _quotes = [
    {
      "text": "The life of the law has not been logic: it has been experience.",
      "author": "— Oliver Wendell Holmes Jr."
    },
    {
      "text": "Injustice anywhere is a threat to justice everywhere.",
      "author": "— Martin Luther King Jr."
    },
    {
      "text": "Justice delayed is justice denied.",
      "author": "— William E. Gladstone"
    },
    {
      "text": "Law is order, and good law is good order.",
      "author": "— Aristotle"
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (Timer timer) {
      if (_currentPage < _quotes.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A363B), // Update to your exact dark theme color if needed
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _quotes.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '"${_quotes[index]["text"]}"',
                            style: AppStyle.style14w400(color: AppColors.whiteColor)
                                .copyWith(fontStyle: FontStyle.italic, height: 1.3),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _quotes[index]["author"]!,
                            style: AppStyle.style12w400(color: AppColors.whiteColor.withValues(alpha: 0.7)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: List.generate(
                    _quotes.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: 6.w),
                      height: 6.h,
                      width: _currentPage == index ? 20.w : 6.w,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15.w),
          Image.asset(
            widget.imagePath,
            width: 80.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}