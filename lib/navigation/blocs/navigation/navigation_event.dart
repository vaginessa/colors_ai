part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  @override
  List<Object> get props => [];

  const NavigationEvent();
}

class NavigationShareTabStarted extends NavigationEvent {
  const NavigationShareTabStarted();
}

class NavigationTabChanged extends NavigationEvent {
  final int newTabIndex;

  const NavigationTabChanged(this.newTabIndex);
}

class NavigationGeneratorTabStarted extends NavigationEvent {
  const NavigationGeneratorTabStarted();
}

class NavigationSaverTabStarted extends NavigationEvent {
  const NavigationSaverTabStarted();
}
