import 'package:collection/collection.dart' show IterableEquality;
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: avoid_relative_lib_imports
import '../../lib/core/extensions/color_extensions.dart';
import '../../lib/core/extensions/constants.dart';

void main() => test(
      'Color to list int extension test',
      () async => expect(const IterableEquality<int>().equals(kDarkColor.toListInt(), <int>[0, 0, 0]), true),
    );
