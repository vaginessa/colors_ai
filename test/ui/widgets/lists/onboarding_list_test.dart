import 'package:colors_ai/onboarding/blocs/onboarding_bloc.dart';
import 'package:colors_ai/onboarding/repository/onboarding_repository.dart';
import 'package:colors_ai/onboarding/services/storage_providers/onboarding_hive_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: avoid_relative_lib_imports
import '../../../../lib/color_generator/models/colors/constants.dart';
import '../../../../lib/core/services/data_storage.dart';
import '../../../../lib/onboarding/ui/view/onboarding_overlay.dart';
import '../../../../lib/testing/test_keys.dart';

void main() => testWidgets('Onboarding should disappear after tap on "GOT IT" button', (WidgetTester tester) async {
      await const DataStorage().init();

      final Finder button = find.byKey(TestKeys.onboardingFinish);
      final Finder disappear = find.byKey(TestKeys.disappearedOnboard);

      await tester.pumpWidget(
        BlocProvider<OnboardingBloc>(
          create: (_) => OnboardingBloc(const OnboardingRepository(OnboardingHiveStorage())),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: FittedBox(
              child: LayoutBuilder(
                builder: (_, BoxConstraints size) => OnboardingOverlay(
                  size: size,
                  length: kDefaultColors.length,
                ),
              ),
            ),
          ),
        ),
      );

      expect(button, findsOneWidget);
      expect(disappear, findsNothing);

      await tester.tap(button);
      await tester.pump();

      expect(button, findsNothing);
      expect(disappear, findsOneWidget);
    });
