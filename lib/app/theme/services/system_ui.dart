import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import '../../../core/ui/constants.dart';

class SystemUI {
  const SystemUI();

  static void init() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      setWindowTitle(kAppName);
      setWindowMinSize(Size(344, 554 + (Platform.isWindows ? 146 : 0)));
    }
  }
}
