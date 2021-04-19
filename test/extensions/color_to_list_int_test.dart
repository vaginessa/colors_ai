import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart' show IterableEquality;

// ignore_for_file: avoid_relative_lib_imports
import '../../lib/extensions/color_to_list_int.dart';
import '../../lib/extensions/constants.dart';

void main() => test('Color to list int extension test',
    () async => expect(const IterableEquality<int>().equals(darkColor.toListInt(), [0, 0, 0]), true));