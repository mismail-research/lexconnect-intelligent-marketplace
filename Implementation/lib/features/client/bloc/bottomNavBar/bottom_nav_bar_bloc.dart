import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_event.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_state.dart';

class BottomNavBarBloc extends Bloc< BottomNavBarEvent, BottomNavBarState> {
  BottomNavBarBloc() : super(BottomNavBarState.initial()) {
    on<ChangeClientTab>((event, emit) {
      emit(BottomNavBarState(selectedIndex: event.index));
    });
  }
}
