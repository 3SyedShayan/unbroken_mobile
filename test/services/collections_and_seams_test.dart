import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/features/core/auth/repositories/auth_repo.dart';
import 'package:unbroken_mobile/features/core/focus/repositories/focus_repo.dart';
import 'package:unbroken_mobile/features/core/habits/repositories/habits_repo.dart';
import 'package:unbroken_mobile/features/support/settings/repositories/settings_repo.dart';
import 'package:unbroken_mobile/services/firebase/collections.dart';
import 'package:unbroken_mobile/services/firebase/firebase_config.dart';

void main() {
  group('Collections Registry & Path Helpers', () {
    test('constants match Firestore backend specification', () {
      expect(Collections.users, equals('users'));
      expect(Collections.habits, equals('habits'));
      expect(Collections.entries, equals('entries'));
      expect(Collections.focus, equals('focus'));
      expect(Collections.settings, equals('settings'));
      expect(Collections.appFeedback, equals('app_feedback'));
      expect(Collections.appPublicConfig, equals('app_public_config'));
    });

    test('canonical path builders produce deterministic Firestore paths', () {
      const uid = 'user_123';
      const habitId = 'H_ABC_123';
      const dayKey = '2026-11-16';

      expect(Collections.userDocPath(uid), equals('users/user_123'));
      expect(Collections.habitsCollectionPath(uid), equals('users/user_123/habits'));
      expect(
        Collections.habitDocPath(uid, habitId),
        equals('users/user_123/habits/h_abc_123'),
      );
      expect(Collections.entriesCollectionPath(uid), equals('users/user_123/entries'));
      expect(
        Collections.entryDocPath(uid, habitId, dayKey),
        equals('users/user_123/entries/h_abc_123_2026-11-16'),
      );
      expect(Collections.focusCollectionPath(uid), equals('users/user_123/focus'));
      expect(
        Collections.focusDocPath(uid, dayKey),
        equals('users/user_123/focus/2026-11-16'),
      );
    });
  });

  group('FirebaseConfig Constants', () {
    test('defaults match production backend expectations', () {
      expect(FirebaseConfig.firestoreRegion, equals('asia-south1'));
      expect(FirebaseConfig.queryTimeout, equals(const Duration(seconds: 15)));
    });
  });

  group('Repository VisibleForTesting Seams', () {
    test('HabitsRepo allows test instance swapping', () {
      final original = HabitsRepo.ins;
      final testInstance = HabitsRepo();
      HabitsRepo.ins = testInstance;
      expect(HabitsRepo.ins, same(testInstance));
      HabitsRepo.ins = original;
    });

    test('FocusRepo allows test instance swapping', () {
      final original = FocusRepo.ins;
      final testInstance = FocusRepo();
      FocusRepo.ins = testInstance;
      expect(FocusRepo.ins, same(testInstance));
      FocusRepo.ins = original;
    });

    test('SettingsRepo allows test instance swapping', () {
      final original = SettingsRepo.ins;
      final testInstance = SettingsRepo();
      SettingsRepo.ins = testInstance;
      expect(SettingsRepo.ins, same(testInstance));
      SettingsRepo.ins = original;
    });

    test('AuthRepo allows test instance swapping', () {
      final original = AuthRepo.ins;
      final testInstance = AuthRepo();
      AuthRepo.ins = testInstance;
      expect(AuthRepo.ins, same(testInstance));
      AuthRepo.ins = original;
    });
  });

  group('SignOutCleanupRegistry', () {
    test('runs all pre-sign-out handlers before post-sign-out handlers', () async {
      final registry = SignOutCleanupRegistry.forTesting();
      final order = <String>[];

      registry.registerPostSignOut(() async {
        await Future<void>.delayed(Duration.zero);
        order.add('post_1');
      });
      registry.register(() async {
        await Future<void>.delayed(Duration.zero);
        order.add('pre_1');
      });
      registry.register(() => order.add('pre_2'));

      await registry.runAll();
      expect(order, equals(['pre_1', 'pre_2', 'post_1']));
    });
  });
}
