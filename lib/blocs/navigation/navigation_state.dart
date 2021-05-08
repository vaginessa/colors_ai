part of 'navigation_bloc.dart';

abstract class NavigationState extends Equatable {
  const NavigationState(this._tabIndex);

  final int _tabIndex;

  static const List<String> _tabLabels = ['Share Palette', 'Generate Palette', 'Favorite Palettes'];

  List<String> get tabLabels => _tabLabels;
  String get currentTabName => _tabLabels[_tabIndex];
  int get tabIndex => _tabIndex;

  @override
  List<Object> get props => [_tabIndex];
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
