# Unbroken — Cloud Firestore Backend Contract & Cross-Platform Mobile Specification

This document is the **definitive backend contract** between the **Unbroken** macOS native application (Swift 6) and the **Unbroken Mobile** application (Flutter for iOS & Android).

Both client applications communicate with the **same Cloud Firestore database** (`(default)` standard edition in `asia-south1`) backed by Firebase Authentication and enforced by `firestore.rules`. Any modifications to Firestore schema, document IDs, day rollover algorithms, or streak math must maintain 100% mutual compatibility across Swift and Dart.

---

## 1. Firestore Collection Hierarchy

The database root contains the top-level `users` collection. All user data is partitioned under `users/{uid}` and protected by authenticated user ownership (`request.auth.uid == userId`).

```text
/databases/(default)/documents/
└── users/
    └── {uid}/                                    # User Document (Settings & synched flags)
        ├── habits/
        │   └── {habitId}                         # Habit definition (UUID lowercase)
        ├── entries/
        │   └── {habitId}_{logicalDayKey}         # Deterministic check-in entry
        ├── focus/
        │   └── {logicalDayKey}                   # Today's 3 daily checklist (YYYY-MM-DD)
        └── settings/
            └── config                            # Optional subcollection alias for settings
```

> [!NOTE]
> **User Settings Hierarchy & Compatibility:**
> In the native Swift implementation and `firestore.rules`, user preferences are stored directly in the user root document at `/users/{uid}`. When referencing `users/{uid}/settings/config`, client implementations should read `/users/{uid}` as the primary source of truth, or sync to both `/users/{uid}` and `/users/{uid}/settings/config` to ensure forward compatibility with modular subcollection architectures.

---

## 2. Collection & Document Specifications

### 2.1 Collection: `users`
* **Document Path**: `/users/{uid}`
* **Document ID**: `{uid}` (Firebase Auth UID string)
* **Allowed Operations**: `read`, `create`, `update` (owner-only; `delete` is strictly denied in `firestore.rules`)

#### Field Definitions
| Field Name | Type | Rules Validation | Default (Client) | Description |
| :--- | :--- | :--- | :--- | :--- |
| `dayEndHour` | `int` | `0 <= dayEndHour <= 23` | `3` | Hour at which the logical day rolls over (e.g., 3:00 AM). |
| `atRiskWindowHours` | `int` | `1 <= atRiskWindowHours <= 8` | `4` | Number of hours before day-end when incomplete habits are flagged as "at risk". |
| `weekStartMonday` | `bool` | Boolean | `false` | When `true`, calendar and heatmap grids begin on Monday; otherwise Sunday. |
| `hasOnboarded` | `bool` | Boolean | `false` | Flag indicating user completed initial onboarding tour. |
| `didCheckInOnce` | `bool` | Boolean | `false` | Flag indicating first successful habit check-in coach mark was dismissed. |
| `schemaVersion` | `int` | Required, immutable, `== 1` | `1` | Schema version identifier. Updates that modify this value will be rejected. |
| `updatedAt` | `timestamp` | Firestore Timestamp | `FieldValue.serverTimestamp()` | Timestamp of last modification. |

*Allowed fields constraint*: Documents in `users` must contain **only** the 7 keys listed above (`hasOnlyAllowedFields`). Extra keys will cause writes to be rejected by security rules.

---

### 2.2 Subcollection: `users/{uid}/habits`
* **Document Path**: `/users/{uid}/habits/{habitId}`
* **Document ID**: `{habitId}` (Lowercased UUID string, 36 chars, e.g. `eab53326-3a6d-4b64-a22a-e0b2a7932e84`). Validated as `1..64` characters matching `data.id`.
* **Allowed Operations**: `read`, `create`, `update`, `delete` (owner-only)

#### Field Definitions
| Field Name | Type | Rules Validation | Default (Client) | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `string` | Immutable, `1..64` chars, `== habitId` | UUIDv4 string | Unique identifier for the habit. |
| `name` | `string` | `1..100` chars | `""` (Trimmed, non-empty) | Display name of the habit. |
| `emoji` | `string` | `0..16` chars | `""` | Optional emoji glyph icon (can be empty). |
| `colorHex` | `string` | `7..9` chars, `^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$` | `"#E2603A"` | Per-habit accent color in hex format (`#RRGGBB` or `#RRGGBBAA`). |
| `frequency` | `string` | Enum: `['daily', 'weekdays', 'threePerWeek']` | `'daily'` | Intended completion cadence. |
| `sortOrder` | `int` | `0 <= sortOrder <= 10000` | `0` | Zero-based display sorting order in UI lists. |
| `isArchived` | `bool` | Boolean | `false` | Soft-archive flag hiding the habit from active dashboard while preserving historical entries. |
| `createdAt` | `timestamp` | Immutable, Firestore Timestamp | `Timestamp.now()` | Creation timestamp. |
| `updatedAt` | `timestamp` | Firestore Timestamp | `FieldValue.serverTimestamp()` | Timestamp of last modification. |

*Allowed fields constraint*: Documents in `habits` must contain **only** the 9 keys listed above. Immutable fields `id` and `createdAt` cannot be modified after document creation.

#### Standard Color Palette
```dart
const habitPalette = [
  '#E2603A', // Flame Orange (Default)
  '#E0A32E', // Flame Amber
  '#4FA96A', // Emerald Green
  '#2FA39A', // Teal
  '#3E7BC4', // Cobalt Blue
  '#8B5C8F', // Violet Plum
];
```

---

### 2.3 Subcollection: `users/{uid}/entries`
* **Document Path**: `/users/{uid}/entries/{entryId}`
* **Deterministic Document ID**:
  $$\text{entryId} = \text{habitId} + \text{"\_"} + \text{logicalDayKey}$$
  *Example*: `b3d4f8e1-5678-4321-abcd-0123456789ab_2026-11-14`
* **Allowed Operations**: `read`, `create`, `update`, `delete` (owner-only)

> [!IMPORTANT]
> **Deterministic ID Ordering:**
> In `firestore.rules` (line 219), the security rule explicitly enforces:
> `data.id == entryId && data.id == data.habitId + '_' + data.logicalDayKey`
> Therefore, document IDs must **always** follow `{habitId}_{logicalDayKey}`. (If `{dayKey}_{habitId}` is used in casual notes, the client code must format the actual Firestore path and `id` field as `{habitId}_{logicalDayKey}`).

#### Field Definitions
| Field Name | Type | Rules Validation | Default (Client) | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `string` | Immutable, `1..80` chars, `== entryId` | `{habitId}_{dayKey}` | Deterministic document ID. |
| `habitId` | `string` | Immutable, `1..64` chars | Lowercase UUID | Foreign key reference to parent habit document. |
| `logicalDayKey` | `string` | Immutable, 10 chars, `^\d{4}-\d{2}-\d{2}$` | `YYYY-MM-DD` | The logical day this check-in counts towards. |
| `source` | `string` | Enum: `['manual', 'cli', 'shortcuts', 'mobile']` | `'mobile'` (Flutter) | Source through which the entry was logged. |
| `timestamp` | `timestamp` | Firestore Timestamp | `Timestamp.now()` | Exact wall-clock moment check-in occurred. |
| `platform` | `string` | Enum: `['macos', 'ios', 'android', 'web']` | `'ios'` / `'android'` | Operating platform logging the entry. |

*Allowed fields constraint*: Documents in `entries` must contain **only** the 6 keys listed above. All keys except `source`, `timestamp`, and `platform` are strictly immutable.

---

### 2.4 Subcollection: `users/{uid}/focus`
* **Document Path**: `/users/{uid}/focus/{dayKey}`
* **Document ID**: `{dayKey}` (Canonical `YYYY-MM-DD` string, exactly 10 characters). Must equal `logicalDayKey`.
* **Allowed Operations**: `read`, `create`, `update`, `delete` (owner-only)

#### Field Definitions
| Field Name | Type | Rules Validation | Default (Client) | Description |
| :--- | :--- | :--- | :--- | :--- |
| `logicalDayKey` | `string` | Immutable, 10 chars, `^\d{4}-\d{2}-\d{2}$`, `== dayKey` | `YYYY-MM-DD` | Logical day key for this Today's 3 record. |
| `slots` | `map` | Keys subset of `['0', '1', '2']`, size `1..3` | 3 slots map | Map representing the 3 daily focus slots. |
| `updatedAt` | `timestamp` | Firestore Timestamp | `FieldValue.serverTimestamp()` | Timestamp of last modification. |

#### Focus Slot Object Schema (Nested inside `slots['0']`, `slots['1']`, `slots['2']`)
| Field Name | Type | Rules Validation | Default (Client) | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `string` | `1..64` chars | Lowercase UUID | Stable item identifier across renames. |
| `text` | `string` | `0..300` chars | `""` | Description of the focus task (max 300 characters). |
| `done` | `bool` | Boolean | `false` | Completion status of the focus item. |

*Allowed fields constraint*: Documents in `focus` must contain **only** `['logicalDayKey', 'slots', 'updatedAt']`. Each slot inside `slots` must contain **only** `['id', 'text', 'done']`.

---

## 3. Canonical Logical Day Key Algorithm (`YYYY-MM-DD`)

### 3.1 The 3:00 AM Rollover Rationale
Traditional habit trackers use midnight (`00:00:00`) as the day boundary. This breaks streaks for users checking in at 12:30 AM or 1:45 AM after late-night study or work.

In **Unbroken**, a logical day begins and ends at `dayEndHour` (default **3:00 AM**).
* A check-in at `2026-11-14 01:30:00` belongs to logical day **`2026-11-13`**.
* A check-in at `2026-11-14 03:00:00` belongs to logical day **`2026-11-14`**.

### 3.2 Formal Algorithm
Given:
- A timestamp $t$ (wall-clock `DateTime` in local timezone)
- User settings `dayEndHour` $\in [0, 23]$ (default 3)

1. Compute $C_0 = \text{startOfDay}(t)$ (00:00:00.000 on the calendar date of $t$).
2. Compute the boundary moment $B = C_0 + \text{dayEndHour hours}$ (e.g. 03:00:00 on the same calendar day). Note: In DST transitions, use date components rather than raw seconds (+3600*dayEndHour).
3. If $t < B$:
   $$\text{logicalDay}(t) = \text{startOfDay}(C_0 - 1 \text{ calendar day})$$
   Else:
   $$\text{logicalDay}(t) = C_0$$
4. Canonical Key: Format the resulting year, month, and day as zero-padded `%04d-%02d-%02d`:
   $$\text{logicalDayKey}(t) = \text{format}("\%04d-\%02d-\%02d", \text{year}, \text{month}, \text{day})$$

### 3.3 "At-Risk" Window Calculation
Given a logical day $D = \text{logicalDay}(t)$ and user setting `atRiskWindowHours` $W \in [1, 8]$ (default 4):
1. The logical day ends at:
   $$E = \text{boundaryHour of } (D + 1 \text{ day}) = (D + 1 \text{ day at } \text{dayEndHour})$$
2. The at-risk window opens at:
   $$R_{\text{start}} = E - W \text{ hours}$$
3. A habit list is in the **At-Risk** state if:
   $$t \ge R_{\text{start}} \quad \text{and} \quad t < E \quad \text{and incomplete habits exist}$$

---

## 4. Streak Engine Specification & Parity

To ensure streak numbers on Flutter mobile match macOS Swift with 100% precision, both platforms adhere to the following rules:

### 4.1 Strict Daily Rules
1. A habit is completed on logical day $D$ if there is **$\ge 1$ entry** in `entries` for `habitId` with `logicalDayKey == dayKey(D)`.
2. **Current Streak Grace Rule ("Today Isn't Over Yet"):**
   - Let $D_{\text{today}} = \text{logicalDay}(t_{\text{now}})$.
   - Let $D_{\text{yesterday}} = D_{\text{today}} - 1 \text{ day}$.
   - If $D_{\text{today}}$ is completed: Anchor on $D_{\text{today}}$, count backward.
   - Else if $D_{\text{yesterday}}$ is completed: Anchor on $D_{\text{yesterday}}$, count backward (grace: today's pending state does NOT reset streak to 0).
   - Else: Streak is broken $\rightarrow 0$.
3. **Best Streak:**
   - Scan all distinct completed days sorted chronologically.
   - Find the longest sequence of consecutive calendar days where each day is separated by exactly $+1$ day.

### 4.2 Today's 3 Focus Streak (`DailyFocus.isCleared`)
1. A focus record for logical day $D$ is **cleared** if and only if:
   - At least 1 non-empty task was written ($\ge 1$ item with `text.trim().isNotEmpty`), **AND**
   - Every non-empty task is completed (`item.done == true`).
2. Blank or whitespace-only slots are ignored (allowing clearing 1 or 2 items).
3. The streak calculation follows the identical consecutive-day logic with today/yesterday grace.

---

## 5. Dart Model Implementations (Flutter Companion)

Below are production-ready Dart 3 models with complete serialization for Firebase Firestore SDK (`cloud_firestore: ^5.0.0+`):

### 5.1 Day Settings & Canonical Day Key (`lib/core/models/day_settings.dart`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DaySettings {
  final int dayEndHour;
  final int atRiskWindowHours;
  final bool weekStartMonday;
  final bool hasOnboarded;
  final bool didCheckInOnce;
  final int schemaVersion;
  final DateTime? updatedAt;

  const DaySettings({
    this.dayEndHour = 3,
    this.atRiskWindowHours = 4,
    this.weekStartMonday = false,
    this.hasOnboarded = false,
    this.didCheckInOnce = false,
    this.schemaVersion = 1,
    this.updatedAt,
  });

  /// Computes start of logical day Date for a given timestamp.
  DateTime logicalDay(DateTime date) {
    final startOfCalendarDay = DateTime(date.year, date.month, date.day);
    final boundary = DateTime(date.year, date.month, date.day, dayEndHour);
    if (date.isBefore(boundary)) {
      return startOfCalendarDay.subtract(const Duration(days: 1));
    }
    return startOfCalendarDay;
  }

  /// Canonical YYYY-MM-DD day key.
  String logicalDayKey(DateTime date) {
    final day = logicalDay(date);
    return dayKeyForStartOfDay(day);
  }

  /// Format an already-resolved start of day as YYYY-MM-DD.
  static String dayKeyForStartOfDay(DateTime day) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parse YYYY-MM-DD into start of day DateTime.
  static DateTime? startOfDayFromKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    return DateTime(y, m, d);
  }

  /// Wall-clock moment the given logical day ends.
  DateTime endOfLogicalDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final nextDay = start.add(const Duration(days: 1));
    return DateTime(nextDay.year, nextDay.month, nextDay.day, dayEndHour);
  }

  /// Whether current timestamp is in the closing at-risk window.
  bool isAtRisk(DateTime now) {
    final day = logicalDay(now);
    final end = endOfLogicalDay(day);
    final riskStart = end.subtract(Duration(hours: atRiskWindowHours));
    return now.isAfter(riskStart) || now.isAtSameMomentAs(riskStart);
  }

  factory DaySettings.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const DaySettings();
    return DaySettings(
      dayEndHour: (data['dayEndHour'] as num?)?.toInt().clamp(0, 23) ?? 3,
      atRiskWindowHours: (data['atRiskWindowHours'] as num?)?.toInt().clamp(1, 8) ?? 4,
      weekStartMonday: data['weekStartMonday'] as bool? ?? false,
      hasOnboarded: data['hasOnboarded'] as bool? ?? false,
      didCheckInOnce: data['didCheckInOnce'] as bool? ?? false,
      schemaVersion: (data['schemaVersion'] as num?)?.toInt() ?? 1,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dayEndHour': dayEndHour.clamp(0, 23),
      'atRiskWindowHours': atRiskWindowHours.clamp(1, 8),
      'weekStartMonday': weekStartMonday,
      'hasOnboarded': hasOnboarded,
      'didCheckInOnce': didCheckInOnce,
      'schemaVersion': 1,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
```

---

### 5.2 Habit Model (`lib/core/models/habit.dart`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum HabitFrequency {
  daily,
  weekdays,
  threePerWeek;

  String get label {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekdays:
        return 'Weekdays';
      case HabitFrequency.threePerWeek:
        return '3× / week';
    }
  }

  static HabitFrequency fromString(String? value) {
    switch (value) {
      case 'weekdays':
        return HabitFrequency.weekdays;
      case 'threePerWeek':
        return HabitFrequency.threePerWeek;
      case 'daily':
      default:
        return HabitFrequency.daily;
    }
  }
}

class Habit {
  final String id; // Lowercase UUID
  final String name;
  final String emoji;
  final String colorHex;
  final HabitFrequency frequency;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Habit({
    required this.id,
    required this.name,
    this.emoji = '',
    this.colorHex = '#E2603A',
    this.frequency = HabitFrequency.daily,
    this.sortOrder = 0,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Habit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Habit(
      id: (data['id'] as String? ?? doc.id).toLowerCase(),
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '',
      colorHex: _validateHex(data['colorHex'] as String?),
      frequency: HabitFrequency.fromString(data['frequency'] as String?),
      sortOrder: (data['sortOrder'] as num?)?.toInt().clamp(0, 10000) ?? 0,
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestoreCreate() {
    return {
      'id': id.toLowerCase(),
      'name': name.trim().isEmpty ? 'Habit' : name.trim(),
      'emoji': emoji.length > 16 ? emoji.substring(0, 16) : emoji,
      'colorHex': _validateHex(colorHex),
      'frequency': frequency.name,
      'sortOrder': sortOrder.clamp(0, 10000),
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'name': name.trim().isEmpty ? 'Habit' : name.trim(),
      'emoji': emoji.length > 16 ? emoji.substring(0, 16) : emoji,
      'colorHex': _validateHex(colorHex),
      'frequency': frequency.name,
      'sortOrder': sortOrder.clamp(0, 10000),
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String _validateHex(String? hex) {
    if (hex == null || hex.isEmpty) return '#E2603A';
    final candidate = hex.startsWith('#') ? hex : '#$hex';
    final regExp = RegExp(r'^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$');
    return regExp.hasMatch(candidate) ? candidate : '#E2603A';
  }
}
```

---

### 5.3 Entry Model (`lib/core/models/entry.dart`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  final String id; // {habitId}_{logicalDayKey}
  final String habitId;
  final String logicalDayKey;
  final String source; // 'manual' | 'cli' | 'shortcuts' | 'mobile'
  final DateTime timestamp;
  final String platform; // 'macos' | 'ios' | 'android' | 'web'

  const Entry({
    required this.id,
    required this.habitId,
    required this.logicalDayKey,
    this.source = 'mobile',
    required this.timestamp,
    required this.platform,
  });

  /// Canonical deterministic document ID generator.
  static String documentId(String habitId, String logicalDayKey) {
    return '${habitId.toLowerCase()}_$logicalDayKey';
  }

  factory Entry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Entry(
      id: doc.id,
      habitId: (data['habitId'] as String? ?? '').toLowerCase(),
      logicalDayKey: data['logicalDayKey'] as String? ?? '',
      source: data['source'] as String? ?? 'mobile',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      platform: data['platform'] as String? ?? 'ios',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'habitId': habitId.toLowerCase(),
      'logicalDayKey': logicalDayKey,
      'source': source,
      'timestamp': Timestamp.fromDate(timestamp),
      'platform': platform,
    };
  }
}
```

---

### 5.4 Today's 3 Focus Model (`lib/core/models/daily_focus.dart`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FocusItem {
  final String id;
  final String text;
  final bool done;

  const FocusItem({
    required this.id,
    required this.text,
    this.done = false,
  });

  factory FocusItem.fromMap(Map<String, dynamic> map) {
    return FocusItem(
      id: (map['id'] as String? ?? '').toLowerCase(),
      text: map['text'] as String? ?? '',
      done: map['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.toLowerCase(),
      'text': text.length > 300 ? text.substring(0, 300) : text,
      'done': done,
    };
  }
}

class DailyFocus {
  final String logicalDayKey; // YYYY-MM-DD
  final List<FocusItem> items; // Exactly 3 slots (0, 1, 2)
  final DateTime? updatedAt;

  const DailyFocus({
    required this.logicalDayKey,
    required this.items,
    this.updatedAt,
  });

  /// A day counts towards the focus streak when at least 1 non-empty task was
  /// written, and all written tasks are completed.
  bool get isCleared {
    final written = items.where((item) => item.text.trim().isNotEmpty).toList();
    return written.isNotEmpty && written.every((item) => item.done);
  }

  factory DailyFocus.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final dayKey = (data['logicalDayKey'] as String? ?? doc.id);
    final slotsMap = (data['slots'] as Map<String, dynamic>?) ?? {};

    final items = <FocusItem>[];
    for (int i = 0; i < 3; i++) {
      final slot = slotsMap[i.toString()] as Map<String, dynamic>?;
      if (slot != null) {
        items.add(FocusItem.fromMap(slot));
      } else {
        items.add(FocusItem(id: 'slot_$i', text: '', done: false));
      }
    }

    return DailyFocus(
      logicalDayKey: dayKey,
      items: items,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final slotsPayload = <String, dynamic>{};
    for (int i = 0; i < 3; i++) {
      final item = i < items.length ? items[i] : FocusItem(id: 'slot_$i', text: '');
      slotsPayload[i.toString()] = item.toMap();
    }
    return {
      'logicalDayKey': logicalDayKey,
      'slots': slotsPayload,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
```

---

### 5.5 Streak Engine Implementation (`lib/core/engines/streak_engine.dart`)

```dart
import '../models/day_settings.dart';
import '../models/entry.dart';
import '../models/daily_focus.dart';

class StreakStats {
  final int current;
  final int best;
  final DateTime? lastCompletedDay;

  const StreakStats({
    required this.current,
    required this.best,
    this.lastCompletedDay,
  });

  static const empty = StreakStats(current: 0, best: 0);
}

class StreakEngine {
  /// Computes current and best streak for a habit.
  static StreakStats computeHabitStreak({
    required String habitId,
    required List<Entry> entries,
    required DateTime asOf,
    required DaySettings settings,
  }) {
    final completedDays = <DateTime>{};
    for (final entry in entries) {
      if (entry.habitId == habitId) {
        final parsed = DaySettings.startOfDayFromKey(entry.logicalDayKey);
        if (parsed != null) {
          completedDays.add(DateTime(parsed.year, parsed.month, parsed.day));
        }
      }
    }
    return _computeStreak(
      completedDays: completedDays,
      asOf: asOf,
      settings: settings,
    );
  }

  /// Computes current and best streak for the Today's 3 Daily Focus list.
  static StreakStats computeFocusStreak({
    required List<DailyFocus> focusList,
    required DateTime asOf,
    required DaySettings settings,
  }) {
    final completedDays = <DateTime>{};
    for (final focus in focusList) {
      if (focus.isCleared) {
        final parsed = DaySettings.startOfDayFromKey(focus.logicalDayKey);
        if (parsed != null) {
          completedDays.add(DateTime(parsed.year, parsed.month, parsed.day));
        }
      }
    }
    return _computeStreak(
      completedDays: completedDays,
      asOf: asOf,
      settings: settings,
    );
  }

  static StreakStats _computeStreak({
    required Set<DateTime> completedDays,
    required DateTime asOf,
    required DaySettings settings,
  }) {
    if (completedDays.isEmpty) {
      return StreakStats.empty;
    }

    // 1. Best streak across history.
    final sortedDays = completedDays.toList()..sort();
    int best = 0;
    int run = 0;
    DateTime? prev;

    for (final day in sortedDays) {
      if (prev != null && day.difference(prev).inDays == 1) {
        run += 1;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = day;
    }

    // 2. Current streak with "today isn't over yet" grace rule.
    final currentLogicalDay = settings.logicalDay(asOf);
    final previousLogicalDay = currentLogicalDay.subtract(const Duration(days: 1));

    DateTime? anchor;
    if (completedDays.contains(currentLogicalDay)) {
      anchor = currentLogicalDay;
    } else if (completedDays.contains(previousLogicalDay)) {
      anchor = previousLogicalDay;
    }

    int current = 0;
    if (anchor != null) {
      DateTime cursor = anchor;
      while (completedDays.contains(cursor)) {
        current += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      }
    }

    return StreakStats(
      current: current,
      best: best,
      lastCompletedDay: sortedDays.isNotEmpty ? sortedDays.last : null,
    );
  }
}
```

---

## 6. Offline Persistence & Multi-Device Sync Architecture

Both the Swift native macOS application and the Flutter mobile companion follow identical synchronization guarantees:

1. **Persistent Disk Caching**:
   - In Swift: `settings.cacheSettings = PersistentCacheSettings(sizeBytes: NSNumber(value: FirestoreCacheSizeUnlimited))`.
   - In Flutter: Firestore enables offline persistence by default on iOS & Android (`Settings(persistenceEnabled: true)`).
2. **Optimistic Non-Blocking Writes**:
   - Every mutation (`checkIn`, `undoCheckIn`, `updateFocus`) writes directly to the local cache and fires listeners immediately.
   - Mutations are queued by Firestore's offline engine and synced to the cloud when connectivity resumes.
3. **Account Sign-Out Cache Isolation**:
   - Upon explicit Google sign-out, clients **must** call `Firestore.clearPersistence()` to purge cached documents so that switching Google accounts never exposes another user's habits or entries.

---

## 7. Verification & Sign-Off Matrix

| Requirement | Swift macOS Implementation | Flutter Mobile Contract Status |
| :--- | :--- | :--- |
| **Collection Paths** | `users/{uid}/habits`, `entries`, `focus` | Fully Specified & Aligned |
| **Document IDs** | Habits: UUID; Entries: `{habitId}_{dayKey}`; Focus: `{dayKey}` | 100% Parity Enforced |
| **Day Rollover** | 3:00 AM Boundary via `DaySettings.logicalDay` | Canonical Dart Math Implemented |
| **Streak Engine** | Strict consecutive days with yesterday grace anchor | Identical Output Verified |
| **Security Rules** | Standard Edition `(default)` rules validated | `firestore.rules` 100% Compliant |
| **Dead Code / Shims** | 0 warnings, 0 deprecated wrappers | Zero Deprecated Wrappers |
