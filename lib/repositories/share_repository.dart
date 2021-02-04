import 'dart:ui' show Color;

import 'package:share/share.dart';

import '../models/url_providers/url_providers.dart';
import '../services/clipboard/clipboard.dart';
import '../services/share_web/url_provider.dart';

class ShareRepository {
  const ShareRepository({this.favoriteColors = const []});

  final List<List<Color>> favoriteColors;

  static const Clipboards _clipboard = Clipboards();
  static int _selectedProvider = 0;

  // ignore: avoid_setters_without_getters
  set changeProvider(int newPoviderIndex) => _selectedProvider = newPoviderIndex;
  int get selectedProvider => _selectedProvider;

  void shareUrl(List<Color> currentColors) => _convertColorsToUrl(currentColors);
  void copyUrl(List<Color> currentColors) => _convertColorsToUrl(currentColors, copyOnly: true);

  List<ColorsUrlProvider> get providersList => const UrlProviders().list;

  Future<void> _convertColorsToUrl(List<Color> colorList, {bool copyOnly = false}) async {
    final UrlProviders urlProviders = UrlProviders(colors: colorList);
    final ColorsUrlProvider provider = urlProviders.list[_selectedProvider];

    if (copyOnly) {
      await _clipboard.copyURL(provider.url);
    } else {
      await Share.share(provider.url, subject: 'Colors AI');
    }
  }
}