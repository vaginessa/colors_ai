import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';

import '../../core/services/data_storage.dart';

mixin DeviceCapabilities {
  late final bool canSharePdf;
  late final bool canSharePng;

  late final String storagePath;

  Future<void> init() async {
    storagePath = kIsWeb ? '' : await DataStorage.path;
    final PrintingInfo info = await Printing.info();
    canSharePdf = info.canShare;
    canSharePng = info.canRaster;
  }
}
