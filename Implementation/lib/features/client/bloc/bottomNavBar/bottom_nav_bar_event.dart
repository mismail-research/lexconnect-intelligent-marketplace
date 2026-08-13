import 'package:equatable/equatable.dart';

abstract class BottomNavBarEvent extends Equatable {
  const BottomNavBarEvent();

  @override
  List<Object> get props => [];
}

class ChangeClientTab extends BottomNavBarEvent {
  final int index;

  const ChangeClientTab(this.index);

  @override
  List<Object> get props => [index];
}
