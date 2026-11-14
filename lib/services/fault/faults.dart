import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unbroken_mobile/configs/configs.dart';

/// Represents the body and status code of a HTTP response that failed
typedef HttpFailure = ({
  Map<String, dynamic>? data,
  int? status,
  String? message,
});

/// [Fault] is a sealed class that represents a fault in the system.
/// It handles exceptions, errors, unknown faults, and custom faults.
sealed class Fault<T> {
  const Fault._internal(this.stackTrace);
  final StackTrace stackTrace;

  factory Fault.fromObjectAndStackTrace(Object object, StackTrace stackTrace) =>
      switch (object) {
        final http.ClientException ex =>
          HttpFault.fromClientException(ex, stackTrace),
        final FirebaseAuthException ex =>
          FirebaseAuthFault.fromFirebaseAuthException(ex, stackTrace),
        final FirebaseException ex =>
          FirebaseFault.fromFirebase(ex, stackTrace),
        final Exception ex => ExceptionFault(ex, stackTrace),
        final Error err => ErrorFault(err, stackTrace),
        _ => UnknownFault(object.toString(), stackTrace),
      };

  @override
  String toString() => message;
}

/// Represents a fault caused by an HTTP call using [package:http].
final class HttpFault<T> extends Fault<T> {
  final HttpFailure body;
  const HttpFault(this.body, StackTrace stackTrace)
    : super._internal(stackTrace);

  /// Creates an [HttpFault] from an HTTP [http.Response] by parsing response data.
  factory HttpFault.fromResponse(http.Response response, StackTrace stackTrace) {
    final statusCode = response.statusCode;
    dynamic decoded;
    try {
      if (response.body.isNotEmpty) {
        decoded = jsonDecode(response.body);
      }
    } catch (_) {
      decoded = response.body;
    }

    final HttpFailure httpFailure = switch (decoded) {
      final String message => (
        message: message,
        data: {'message': message},
        status: statusCode,
      ),
      final Map<String, dynamic> map when map.containsKey('data') => (
        message: _extractMessage(map),
        data: map['data'] is Map<String, dynamic>
            ? map['data'] as Map<String, dynamic>
            : map,
        status: statusCode,
      ),
      final Map<String, dynamic> map when map.containsKey('message') => (
        message: map['message']?.toString() ?? 'UNKNOWN-ERROR',
        data: {'message': map['message']},
        status: statusCode,
      ),
      final Map<String, dynamic> map => (
        message: _extractMessage(map),
        data: map,
        status: statusCode,
      ),
      _ => (
        message: response.body.isNotEmpty
            ? response.body
            : 'HTTP error with status: $statusCode',
        data: <String, dynamic>{},
        status: statusCode,
      ),
    };

    debugPrint('[HttpFault] Status: $statusCode | Message: ${httpFailure.message}');
    return HttpFault(httpFailure, stackTrace);
  }

  /// Creates an [HttpFault] from an HTTP [http.ClientException].
  factory HttpFault.fromClientException(
    http.ClientException ex,
    StackTrace stackTrace,
  ) {
    final httpFailure = (
      message: ex.message,
      data: {'uri': ex.uri?.toString()},
      status: null,
    );

    debugPrint('[HttpFault] ClientException: ${ex.message}');
    return HttpFault(httpFailure, stackTrace);
  }

  /// Extracts a meaningful error message from the response map.
  static String _extractMessage(Map<String, dynamic> map) {
    return map['message']?.toString() ??
        map['error']?.toString() ??
        map['detail']?.toString() ??
        'UNKNOWN-ERROR';
  }
}

/// Represents a fault caused by Firebase Auth
final class FirebaseAuthFault<T> extends Fault<T> {
  final String errorMessage;
  const FirebaseAuthFault(this.errorMessage, StackTrace stackTrace)
    : super._internal(stackTrace);

  factory FirebaseAuthFault.fromFirebaseAuthException(
    FirebaseAuthException ex,
    StackTrace stackTrace,
  ) {
    debugPrint('[FirebaseAuthFault] Code: ${ex.code} | Message: ${ex.message}');

    return switch (ex.code) {
      'user-not-found' => FirebaseAuthFault(
        'No account found with this email.',
        stackTrace,
      ),
      'wrong-password' || 'invalid-credential' => FirebaseAuthFault(
        'Incorrect email or password.',
        stackTrace,
      ),
      'email-already-in-use' => FirebaseAuthFault(
        'An account already exists with this email, please login.',
        stackTrace,
      ),
      'invalid-email' => FirebaseAuthFault(
        'The email address is not valid.',
        stackTrace,
      ),
      'weak-password' => FirebaseAuthFault(
        'Password is too weak. Use at least 6 characters.',
        stackTrace,
      ),
      'user-disabled' => FirebaseAuthFault(
        'This account has been disabled. Please contact support.',
        stackTrace,
      ),
      'too-many-requests' => FirebaseAuthFault(
        'Too many attempts. Please try again later.',
        stackTrace,
      ),
      'requires-recent-login' => FirebaseAuthFault(
        'Please sign in again to continue.',
        stackTrace,
      ),
      'network-request-failed' => FirebaseAuthFault(
        'Network error. Please check your connection.',
        stackTrace,
      ),
      _ => FirebaseAuthFault(
        ex.message ?? 'Authentication error. Please try again.',
        stackTrace,
      ),
    };
  }
}

/// Represents a fault caused by Firebase core / Firestore
final class FirebaseFault<T> extends Fault<T> {
  final String errorMessage;
  const FirebaseFault(this.errorMessage, StackTrace stackTrace)
    : super._internal(stackTrace);

  factory FirebaseFault.fromFirebase(
    FirebaseException ex,
    StackTrace stackTrace,
  ) {
    debugPrint('[FirebaseFault] Code: ${ex.code} | Message: ${ex.message}');

    return switch (ex.code) {
      'permission-denied' => FirebaseFault(
        'Permission denied. Please check your internet connection.',
        stackTrace,
      ),
      'unavailable' => FirebaseFault(
        'Service unavailable. Please check your internet connection.',
        stackTrace,
      ),
      'internal' => FirebaseFault(
        'Internal server error. Please try again later.',
        stackTrace,
      ),
      'unknown' => FirebaseFault(
        'Unknown error. Please try again later.',
        stackTrace,
      ),
      'failed-precondition' => FirebaseFault(
        'Something went wrong with indexing. Please contact support.',
        stackTrace,
      ),
      _ => FirebaseFault(
        ex.message ?? 'Firebase error, try again!',
        stackTrace,
      ),
    };
  }
}

/// Represents a fault caused by an AI (Gemini) call
final class AiFault<T> extends Fault<T> {
  final String errorMessage;
  const AiFault(this.errorMessage, StackTrace stackTrace)
    : super._internal(stackTrace);

  factory AiFault.fromException(Object ex, StackTrace stackTrace) {
    final message = ex.toString();
    debugPrint('[AiFault] $message');
    return AiFault(message, stackTrace);
  }
}

/// Represents a fault caused by an exception
final class ExceptionFault<T> extends Fault<T> {
  final Exception exception;
  const ExceptionFault(this.exception, StackTrace stackTrace)
    : super._internal(stackTrace);
}

/// Represents a fault caused by an error
final class ErrorFault<T> extends Fault<T> {
  final Object error;
  const ErrorFault(this.error, StackTrace stackTrace)
    : super._internal(stackTrace);
}

/// Represents a fault with unknown cause
final class UnknownFault<T> extends Fault<T> {
  final String text;
  const UnknownFault(this.text, StackTrace stackTrace)
    : super._internal(stackTrace);
}

/// Represents a fault with network connection
final class NetworkFault<T> extends Fault<T> {
  final String text;
  const NetworkFault(this.text, StackTrace stackTrace)
    : super._internal(stackTrace);
}

/// Represents a fault with custom information
final class CustomFault<T> extends Fault<T> {
  final T faultInfo;
  const CustomFault(this.faultInfo, StackTrace stackTrace)
    : super._internal(stackTrace);
}

/// Returns the message of the fault
extension FaultExtension on Fault {
  String get message => switch (this) {
    final ExceptionFault ex => ex.exception.toString().splitError,
    final ErrorFault err => err.error.toString(),
    final UnknownFault text => text.text,
    final CustomFault fault => fault.faultInfo.toString(),
    final FirebaseAuthFault authFault => authFault.errorMessage,
    final FirebaseFault firebaseFault => firebaseFault.errorMessage.splitError,
    final NetworkFault networkFault => networkFault.text.splitError,
    final AiFault aiFault => aiFault.errorMessage,
    final HttpFault httpFault => httpFault.body.message.toString(),
  };
}
