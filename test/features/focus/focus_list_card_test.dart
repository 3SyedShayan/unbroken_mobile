import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/focus/repositories/focus_repo.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/widgets/focus_list_card.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

class _MockFocusRepo extends FocusRepo {
  _MockFocusRepo() : super.test();

  final Map<String, Map<String, dynamic>> savedData = {};

  @override
  Stream<List<Map<String, dynamic>>> observeFocus(
    String uid, {
    String? windowStartKey,
  }) {
    return Stream.value(savedData.values.toList());
  }

  @override
  Future<void> upsertFocus(
    String uid,
    String logicalDayKey,
    Map<String, dynamic> focusData,
  ) async {
    savedData[logicalDayKey] = Map<String, dynamic>.from(focusData);
  }

  @override
  Future<void> deleteFocus(String uid, String logicalDayKey) async {
    savedData.remove(logicalDayKey);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const settings = DaySettings(dayEndHour: 3);
  final now = DateTime(2026, 11, 18, 12, 0);
  final today = DateTime(2026, 11, 18);

  late _MockFocusRepo repo;
  late FocusCubit cubit;

  setUp(() {
    repo = _MockFocusRepo();
    cubit = FocusCubit(repo: repo);
    cubit.startObserving('test_uid');
  });

  tearDown(() {
    cubit.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider<FocusCubit>.value(
            value: cubit,
            child: FocusListCard(
              today: today,
              now: now,
              settings: settings,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders first 3 tasks without dropdown when count <= 3', (tester) async {
    await cubit.addTask(text: 'Task 1', asOf: now, settings: settings);
    await cubit.addTask(text: 'Task 2', asOf: now, settings: settings);
    await cubit.addTask(text: 'Task 3', asOf: now, settings: settings);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('Task 2'), findsOneWidget);
    expect(find.text('Task 3'), findsOneWidget);
    expect(find.textContaining('more task'), findsNothing);
    expect(find.byType(TextField), findsNWidgets(4)); // 3 tasks + 1 add field
  });

  testWidgets('shows collapsible overflow dropdown when count > 3', (tester) async {
    await cubit.addTask(text: 'Task 1', asOf: now, settings: settings);
    await cubit.addTask(text: 'Task 2', asOf: now, settings: settings);
    await cubit.addTask(text: 'Task 3', asOf: now, settings: settings);
    await cubit.addTask(text: 'Task 4', asOf: now, settings: settings);
    await cubit.addTask(text: 'Task 5', asOf: now, settings: settings);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Toggle button should be visible indicating 2 more tasks
    expect(find.textContaining('Show 2 more tasks'), findsOneWidget);

    // Tap toggle to expand
    await tester.tap(find.textContaining('Show 2 more tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Task 4'), findsOneWidget);
    expect(find.text('Task 5'), findsOneWidget);
    expect(find.textContaining('Hide additional tasks'), findsOneWidget);

    // Tap again to collapse
    await tester.tap(find.textContaining('Hide additional tasks'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Show 2 more tasks'), findsOneWidget);
  });

  testWidgets('adding 4th task auto-expands dropdown immediately', (tester) async {
    await cubit.addTask(text: 'Task 1', asOf: now, settings: settings);
    await cubit.addTask(text: 'Task 2', asOf: now, settings: settings);
    await cubit.addTask(text: 'Task 3', asOf: now, settings: settings);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Enter a 4th task in the add field
    final addField = find.widgetWithText(TextField, 'Add a task…');
    await tester.enterText(addField, 'Task 4 Overflown');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Dropdown should be auto-expanded
    expect(find.text('Task 4 Overflown'), findsOneWidget);
    expect(find.textContaining('Hide additional tasks'), findsOneWidget);
  });

  testWidgets('displays max 10 tasks reached banner and hides add field at 10 items', (tester) async {
    for (var i = 1; i <= 10; i++) {
      await cubit.addTask(text: 'Task $i', asOf: now, settings: settings);
    }

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Add field should be replaced by max reached banner
    expect(find.text('Maximum 10 tasks reached for today'), findsOneWidget);
    expect(find.text('Add a task…'), findsNothing);
  });

  testWidgets('checkbox toggle updates completion state with animation', (tester) async {
    await cubit.addTask(text: 'Complete Me', asOf: now, settings: settings);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final checkboxFinder = find.byType(AnimatedContainer).first;
    expect(find.byIcon(Icons.check), findsOneWidget); // Icon is present in widget tree (scale animated)

    // Tap checkbox
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final items = cubit.state.focusForDay('2026-11-18').itemsList;
    expect(items.first.done, isTrue);
  });
}
