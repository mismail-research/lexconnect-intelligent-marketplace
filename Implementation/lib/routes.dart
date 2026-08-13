import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexbid/core/di/injectable.dart';
import 'package:lexbid/features/approval/domain/usecase/listen_approval_status.dart';
import 'package:lexbid/features/approval/presentation/bloc/approval_bloc.dart';
import 'package:lexbid/features/approval/presentation/bloc/approval_event.dart';
import 'package:lexbid/features/approval/presentation/view/approval_gate_page.dart';
import 'package:lexbid/features/approval/presentation/view/approval_pending.dart';
import 'package:lexbid/features/approval/presentation/view/approval_rejected.dart';
import 'package:lexbid/features/auth/presentation/view/login_view.dart';
import 'package:lexbid/features/auth/presentation/view/sign_up_view.dart';
import 'package:lexbid/features/client/presentation/view/ClientHome/home.dart';
import 'package:lexbid/features/client/presentation/view/client_bottomNavBar.dart';
import 'package:lexbid/features/client/presentation/view/client_profile/client_profile_screen.dart';
import 'package:lexbid/features/client/presentation/view/clientsAppointments/clients_appointments.dart';
import 'package:lexbid/features/client/presentation/view/lawyerDetail/lawyer_detail_screen.dart';
import 'package:lexbid/features/info/presentation/Info.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_event.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerHome/lawyer_home_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/view/AppointmentDetailScreen/AppointmentDetailScreen.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerAppointments/lawyer_appointments.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerHome/lawyer_home.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerProfile/lawyer_profile_screen.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyer_bottomNavBar.dart';
import 'package:lexbid/features/role_selection/presentation/bloc/role_selection_bloc.dart';
import 'package:lexbid/features/role_selection/presentation/view/role_selection_view.dart';
import 'package:lexbid/features/splash/presentation/view/splash_view.dart';
import 'package:lexbid/features/client/presentation/view/clientAppointmentDetailScreen/client_appointment_detail_screen.dart';
import 'package:lexbid/features/client/presentation/view/bookAppointment/book_appointment_screen.dart';

import 'core/constants/app_color.dart';

class RouteGenerator {
  static const String splashRoute = '/';
  static const String roleSelectionRoute = '/roleSelection';
  static const String loginRoute = '/login';
  static const String signUpRoute = '/signUp';
  static const String clientBottomNavRoute = '/clientBottomNav';
  static const String lawyerBottomNavRoute = '/lawyerBottomNav';
  static const String homeRoute = '/home';
  static const String lawyerInfoRoute = '/lawyerInfo';
  static const String approvalGate    = '/approvalGate';
  static const String approvalPending = '/approvalPending';
  static const String approvalRejected = '/approvalRejected';
  static const String lawyerHome = '/ClientHome';
  static const String clientAppointments = '/clientAppointments';
  static const String clientProfile = '/clientProfile';
  static const String clientAppointmentDetailScreen = '/clientAppointmentDetailScreen';
  static const String lawyerProfile = '/lawyerProfile';
  static const String lawyerDetail = '/lawyerDetail';
  static const String bookAppointment = '/book-bookAppointment';
  static const String lawyerAppointments = '/lawyer-appointments';
  static const String appointmentDetail = '/bookAppointment-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return _createAnimatedRoute(const SplashView());

      case roleSelectionRoute:
        return _createAnimatedRoute(
          BlocProvider(
            create: (_) => RoleSelectionBloc(),
            child: const RoleSelectionView(),
          ),
        );

      case loginRoute:
        final args = (settings.arguments as Map?) ?? {};
        final userType = args['userType'] ?? "client";
        return _createAnimatedRoute(LoginView(userType: userType));

      case signUpRoute:
        final args = (settings.arguments as Map?) ?? {};
        final userType = args['userType'] ?? "client";
        return _createAnimatedRoute(SignUpView(userType: userType));

      case homeRoute:
        return _createAnimatedRoute(const HomeView());

      case clientBottomNavRoute:
        return _createAnimatedRoute(const ClientBottomNavView());

      case clientAppointments:
        return _createAnimatedRoute(ClientAppointments());

      case clientProfile:
        return _createAnimatedRoute(ClientProfileScreen());

      case clientAppointmentDetailScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _createAnimatedRoute(
          ClientAppointmentDetailScreen(appointmentData: args),
          transitionType: _TransitionType.slideUp, // Slide up looks nice for details!
        );

      case lawyerBottomNavRoute:
        return _createAnimatedRoute(const LawyerBottomNavView());

      case lawyerInfoRoute:
        return _createAnimatedRoute( InfoView());

      case approvalGate:
        return _createAnimatedRoute(const ApprovalGatePage());

      case approvalPending:
        return _createAnimatedRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ApprovalBloc(getIt<ListenApprovalStatus>())..add(StartListeningApproval()),
              ),
            ],
            child: const ApprovalPendingPage(),
          ),
        );

      case approvalRejected:
        return _createAnimatedRoute(const ApprovalRejectedPage());

      case lawyerHome:
        return _createAnimatedRoute(
          BlocProvider(
            create: (_) => LawyerHomeBloc()..add(LoadLawyerDataEvent()),
            child: const LawyerHome(),
          ),
        );

      case lawyerProfile:
        return _createAnimatedRoute(LawyerProfileScreen());

      case lawyerDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _createAnimatedRoute(LawyerDetailScreen(lawyerData: args));

      case bookAppointment:
        final args = settings.arguments as Map<String, dynamic>;
        return _createAnimatedRoute(BookAppointmentScreen(lawyerData: args));

      case lawyerAppointments:
        return _createAnimatedRoute(LawyerAppointments());

      case appointmentDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _createAnimatedRoute(
          BlocProvider(
            create: (_) => LawyerAppointmentsBloc()..add(LoadLawyerAppointmentsEvent()),
            child: AppointmentDetailScreen(appointmentData: args),
          ),
          transitionType: _TransitionType.slideUp,
        );

      default:
        return _errorRoute();
    }
  }

  // ---------------- ANIMATION UTILS ----------------
  static PageRouteBuilder _createAnimatedRoute(
      Widget child, {
        _TransitionType transitionType = _TransitionType.fade,
      }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {

        // 1. Smooth Fade Transition (Default)
        if (transitionType == _TransitionType.fade) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        }

        // 2. Elegant Slide Up Transition (Perfect for details/modals)
        if (transitionType == _TransitionType.slideUp) {
          final tween = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        }

        return child;
      },
    );
  }

  // ---------------- ERROR PAGE ----------------
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Routing Error')),
        body: const Center(
          child: Text(
            '404 - Page not found!\nPlease check the route name.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppColors.redColor),
          ),
        ),
      ),
    );
  }
}

enum _TransitionType { fade, slideUp }