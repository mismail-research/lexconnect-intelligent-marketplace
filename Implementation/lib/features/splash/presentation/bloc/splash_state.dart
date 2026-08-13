import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashNavigate extends SplashState {
  final String route;
  final String? name;
  SplashNavigate(this.route, {this.name});

  @override
  List<Object?> get props => [route];
}
