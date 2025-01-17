import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../repository/sounds_repository.dart';

part 'sound_event.dart';
part 'sound_state.dart';

class SoundBloc extends Bloc<SoundEvent, SoundState> {
  final SoundsRepository _soundRepository;

  SoundBloc(this._soundRepository) : super(const SoundInitial());

  @override
  Stream<SoundState> mapEventToState(SoundEvent event) async* {
    if (event is SoundStarted) {
      await _soundRepository.init();
      // On web it's not allowed to play sounds without user interaction first.
      if (!kIsWeb) {
        _soundRepository.playFavoritesAdded();
      }
    } else if (event is SoundRefreshed) {
      _soundRepository.playRefresh();
    } else if (event is SoundFavoritesAdded) {
      _soundRepository
        ..playFavoritesAdded()
        ..vibrate();
    } else if (event is SoundLocked) {
      _soundRepository.playLock();
    } else if (event is SoundCopied) {
      _soundRepository.playCopy();
    }
  }
}
