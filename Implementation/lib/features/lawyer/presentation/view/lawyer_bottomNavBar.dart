import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexbid/core/common/widgets/custom_bottom_bar.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_bloc.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_event.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_state.dart';

import 'package:lexbid/features/lawyer/presentation/bloc/lawyerHome/lawyer_home_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerStat/lawyer_stat_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerStat/lawyer_stat_event.dart';

import 'package:lexbid/features/lawyer/presentation/view/lawyerHome/lawyer_home.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerProfile/lawyer_profile_screen.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerStat/lawyerStat.dart';

class LawyerBottomNavView extends StatelessWidget {
  const LawyerBottomNavView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BottomNavBarBloc()),
        BlocProvider(
          create: (_) => LawyerHomeBloc()..add(LoadLawyerDataEvent()),
        ),
        BlocProvider(
          create: (_) => LawyerStatBloc()..add(LoadAcceptedAppointments()),
        ),
      ],
      child: BlocBuilder<BottomNavBarBloc, BottomNavBarState>(
        builder: (context, state) {
          return Scaffold(
            extendBody: true,
            body: _screens[state.selectedIndex],

            /// 🔥 CUSTOM NAV BAR (SAME AS CLIENT)
            bottomNavigationBar: CustomAnimatedBottomBar(
              selectedIndex: state.selectedIndex,
              onItemSelected: (index) {
                context.read<BottomNavBarBloc>().add(
                  ChangeClientTab(index),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// ✅ KEEP SCREENS STATIC (NO REBUILD)
  static final List<Widget> _screens = [
    const LawyerHome(),
    const LawyerStat(),
    const LawyerProfileScreen(),
  ];
}