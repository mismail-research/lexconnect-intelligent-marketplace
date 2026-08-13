import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lexbid/core/services/navigation_services.dart';
import 'package:lexbid/core/services/notification_service.dart';
import 'package:lexbid/core/di/injectable.dart';
import 'package:lexbid/features/auth/bloc/auth_bloc.dart';
import 'package:lexbid/features/auth/bloc/auth_event.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_bloc.dart';
import 'package:lexbid/routes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  final notificationService = NotificationService();
  await notificationService.initializeNotifications();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider<BottomNavBarBloc>(create: (_) => BottomNavBarBloc()),
      ],
      child: const LexBidApp(),
    ),
  );
}

class LexBidApp extends StatelessWidget {
  const LexBidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: "LexBid",
          theme: ThemeData(useMaterial3: true, fontFamily: "Poppins"),
          initialRoute: RouteGenerator.splashRoute,
          onGenerateRoute: RouteGenerator.generateRoute,
        );
      },
    );
  }
}
