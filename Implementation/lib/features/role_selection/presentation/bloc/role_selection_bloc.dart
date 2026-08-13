  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'role_selection_event.dart';
  import 'role_selection_state.dart';

  class RoleSelectionBloc extends Bloc<RoleSelectionEvent, RoleSelectionState> {
    RoleSelectionBloc() : super(RoleInitial()) {
      on<SelectClient>((event, emit) => emit(ClientSelected()));
      on<SelectLawyer>((event, emit) => emit(LawyerSelected()));
    }
  }
