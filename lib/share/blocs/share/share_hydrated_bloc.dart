import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../general/models/color_palette/color_palette.dart';
import '../../repository/share_repository.dart';
import '../../services/url_providers/url_providers.dart';

part 'share_event.dart';
part 'share_state.dart';

class ShareBloc extends HydratedBloc<ShareEvent, ShareState> {
  ShareBloc() : super(const ShareEmptyInitial());

  final ShareRepository _share = ShareRepository();

  @override
  Stream<ShareState> mapEventToState(ShareEvent event) async* {
    if (event is ShareStarted) {
      await _share.init();
    } else if (event is ShareFormatSelected) {
      _share.isLetter = event.isLetter;
    } else if (event is SharePdfShared) {
      try {
        await _share.asPdf(event.palette);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        yield const ShareFailure();
        await _shareFailed();
      }
    } else if (event is ShareImageShared) {
      try {
        await _share.asPng(event.palette);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        yield const ShareFailure();
        await _shareFailed();
      }
    } else if (event is ShareUrlShared) {
      _share.asUrl(event.palette);
    } else if (event is ShareUrlCopied) {
      _share.copyUrl(event.palette);
    } else if (event is ShareUrlProviderSelected) {
      _share.providerIndex = event.providerIndex;
    }
    try {
      yield ShareSelectedInitial(
        providerIndex: _share.providerIndex,
        isLetter: _share.isLetter,
        canSharePdf: _share.canSharePdf,
        canSharePng: _share.canSharePng,
      );
    } on Exception catch (_) {
      yield const ShareFailure();
      await _shareFailed();
    }
  }

  Future<void> _shareFailed() async => Future.delayed(Duration.zero, () async {});

  @override
  ShareState? fromJson(Map<String, dynamic> json) {
    final int? savedProvider = json['index'] as int?;
    final bool? savedFormat = json['isLetter'] as bool?;
    if (savedProvider != null) {
      _share.providerIndex = savedProvider;
    }
    if (savedFormat != null) {
      _share.isLetter = savedFormat;
    }
  }

  @override
  Map<String, dynamic>? toJson(ShareState state) {
    if (state is ShareSelectedInitial) {
      return <String, dynamic>{'index': state.selectedProvider, 'isLetter': state.isLetter};
    }
  }
}