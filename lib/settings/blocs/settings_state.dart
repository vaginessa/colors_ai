part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  final bool colormindForUI;

  final bool? isDarkTheme;

  final int huemintAdjacency;
  final double huemintTemperature;

  final SelectedAPI selectedAPI;

  @override
  List<Object?> get props => <Object?>[isDarkTheme, colormindForUI, huemintAdjacency, huemintTemperature, selectedAPI];

  const SettingsState({
    required this.selectedAPI,
    required this.colormindForUI,
    required this.huemintAdjacency,
    required this.huemintTemperature,
    this.isDarkTheme,
  });
}

class SettingsInitial extends SettingsState {
  const SettingsInitial()
      : super(
          colormindForUI: true,
          huemintTemperature: 0,
          huemintAdjacency: 0,
          selectedAPI: SelectedAPI.huemint,
        );
}

class SettingsFailure extends SettingsState {
  const SettingsFailure()
      : super(
          colormindForUI: true,
          huemintTemperature: 0,
          huemintAdjacency: 0,
          selectedAPI: SelectedAPI.huemint,
        );
}

class SettingsChangedInitial extends SettingsState {
  const SettingsChangedInitial({
    required SelectedAPI selectedAPI,
    required bool colormindForUI,
    required int huemintAdjacency,
    required double huemintTemperature,
    bool? isDarkTheme,
  }) : super(
          isDarkTheme: isDarkTheme,
          colormindForUI: colormindForUI,
          huemintAdjacency: huemintAdjacency,
          huemintTemperature: huemintTemperature,
          selectedAPI: selectedAPI,
        );
}
