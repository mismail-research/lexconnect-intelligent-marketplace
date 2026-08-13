import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../domain/entities/home/lawyer_type.dart';

part 'client_home_event.dart';
part 'client_home_state.dart';

class ClientHomeBloc extends Bloc<ClientHomeEvent, ClientHomeState> {

  ClientHomeBloc() : super(ClientHomeInitial()) {
    on<LoadLawyerTypes>((event, emit) {
      emit(
        LawyerTypesLoaded(
          types: const [
            LawyerType('Family'),
            LawyerType('Criminal'),
            LawyerType('Taxes'),
            LawyerType('Civil'),
          ],
          selectedIndex: 0,
        ),
      );
    });

    on<SelectLawyerType>((event, emit) {
      final current = state as LawyerTypesLoaded;
      emit(
        LawyerTypesLoaded(
          types: current.types,
          selectedIndex: event.index,
        ),
      );
    });
  }
}
