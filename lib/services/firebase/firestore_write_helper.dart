import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';
import 'package:unbroken_mobile/services/firebase/crash/crashlytics.dart';
import 'package:unbroken_mobile/services/firebase/firebase_config.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';

/// Executes a Firestore mutation with optimistic non-blocking offline behavior.
///
/// If the remote acknowledgement arrives within [timeout], errors propagate
/// immediately as a [Fault]. If [timeout] elapses while offline or on a slow
/// network, the future completes once the write is queued locally, while any
/// delayed server failure is logged and recorded to Crashlytics.
Future<void> runOptimisticWrite(
  Future<void> Function() write, {
  Duration timeout = FirebaseConfig.writeTimeout,
  String tag = 'FIRESTORE',
}) {
  final completer = Completer<void>();
  var timedOut = false;

  final timer = Timer(timeout, () {
    if (!completer.isCompleted) {
      timedOut = true;
      completer.complete();
    }
  });

  Future<void>.sync(write).then(
    (_) {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
    onError: (Object error, StackTrace stackTrace) {
      timer.cancel();
      final fault = error is Fault
          ? error
          : Fault.fromObjectAndStackTrace(error, stackTrace);
      if (!completer.isCompleted) {
        completer.completeError(fault, stackTrace);
      } else if (timedOut) {
        'Deferred Firestore write failure: $fault'.appLog(
          tag: tag,
          level: AppLogLevel.error,
          error: error,
          stackTrace: stackTrace,
        );
        unawaited(
          EnhancedCrashlytics.ins.recordNonFatalEvent(
            fault,
            stackTrace,
            reason: 'Deferred optimistic Firestore write failed ($tag)',
          ),
        );
      }
    },
  );

  return completer.future;
}

/// Deletes [refs] in chunks of [chunkSize] to stay safely under Firestore's
/// 500-operation `WriteBatch` ceiling.
Future<void> commitChunkedDeletes(
  FirebaseFirestore firestore,
  List<DocumentReference<Map<String, dynamic>>> refs, {
  int chunkSize = FirebaseConfig.maxDeleteBatchSize,
  String tag = 'FIRESTORE',
}) async {
  for (var i = 0; i < refs.length; i += chunkSize) {
    final end = (i + chunkSize < refs.length) ? i + chunkSize : refs.length;
    final batch = firestore.batch();
    for (var j = i; j < end; j++) {
      batch.delete(refs[j]);
    }
    await runOptimisticWrite(() => batch.commit(), tag: tag);
  }
}
