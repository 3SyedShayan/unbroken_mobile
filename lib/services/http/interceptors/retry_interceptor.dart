part of '../api.dart';

/// Creates an HTTP Client wrapper that implements exponential backoff retry mechanism.
/// Retries failed requests up to 3 times with increasing delays.
http.Client _createRetryClient(http.Client inner) {
  const int maxRetries = 3;
  const int baseDelayMs = 1000;

  return RetryClient(
    inner,
    retries: maxRetries,
    when: (response) =>
        response.statusCode >= 500 && response.statusCode < 600,
    whenError: (error, _) =>
        error is SocketException ||
        error is TimeoutException ||
        error is http.ClientException,
    delay: (retryCount) => Duration(
      milliseconds: baseDelayMs * (1 << retryCount),
    ),
    onRetry: (req, resp, retryCount) {
      'Retry attempt ${retryCount + 1}/$maxRetries for ${req.url}'.appLog(
        tag: 'RETRY_CLIENT',
      );
    },
  );
}
