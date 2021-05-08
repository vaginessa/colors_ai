import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: avoid_relative_lib_imports
import '../../lib/repositories/onboarding_repository.dart';
import '../../lib/services/data_storage.dart';

void main() => group('Onboarding storage:', () {
      const OnboardingRepository onboardingRepo = OnboardingRepository();

      test('save onboarding data as done', () async {
        await DataStorage.init();
        await onboardingRepo.onboardingDone();

        final bool isFirstRun = await onboardingRepo.loadOnboardData;

        expect(isFirstRun, false);
      });

      test('check if onboarding data exists', () async {
        final bool isFirstRun = await onboardingRepo.loadOnboardData;

        expect(isFirstRun, false);
      });
    });
