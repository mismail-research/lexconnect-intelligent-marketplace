import 'package:equatable/equatable.dart';

class BottomNavBarState extends Equatable {
  final int selectedIndex;

  const BottomNavBarState({required this.selectedIndex});

  factory BottomNavBarState.initial() {
    return const BottomNavBarState(selectedIndex: 0);
  }

  @override
  List<Object> get props => [selectedIndex];
}
