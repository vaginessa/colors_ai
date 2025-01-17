import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../repository/about_repository.dart';

part 'about_event.dart';
part 'about_state.dart';

class AboutBloc extends Bloc<AboutEvent, AboutState> {
  final AboutRepository _aboutRepository;

  AboutBloc(this._aboutRepository) : super(const AboutInitial(appVersion: ''));

  @override
  Stream<AboutState> mapEventToState(AboutEvent event) async* {
    if (event is AboutStarted) {
      await _aboutRepository.init(event.currentLocale);
    } else if (event is AboutColormindApiTaped) {
      _aboutRepository.openAboutColormind();
    } else if (event is AboutHuemintApiTaped) {
      _aboutRepository.openAboutHuemint();
    } else if (event is AboutSourceCodeTaped) {
      _aboutRepository.openSourceCode();
    } else if (event is AboutSoundAssetsTaped) {
      _aboutRepository.openAboutSounds();
    } else if (event is AboutGoogleTaped) {
      _aboutRepository.openAboutGoogle();
    } else if (event is AboutLicenseTaped) {
      _aboutRepository.openAboutLicenses();
    }
    yield AboutInitial(appVersion: _aboutRepository.version);
  }
}
