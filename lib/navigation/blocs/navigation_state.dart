part of 'navigation_bloc.dart';

abstract class NavigationState extends Equatable {
  final int _tabIndex;

  @override
  List<int> get props => <int>[_tabIndex];

  int get tabIndex => _tabIndex;

  const NavigationState(this._tabIndex);
}

class NavigationFailure extends NavigationState {
  const NavigationFailure() : super(1);
}

class NavigationShareTabInitial extends NavigationState {
  const NavigationShareTabInitial() : super(0);
}

class NavigationFavoritesTabInitial extends NavigationState {
  const NavigationFavoritesTabInitial() : super(2);
}

class NavigationGenerateTabInitial extends NavigationState {
  const NavigationGenerateTabInitial() : super(1);
}
