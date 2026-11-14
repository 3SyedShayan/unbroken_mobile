part of '../alice.dart';

/// HTTP Client that intercepts requests and responses to display in Alice.
class _AliceHttpClient extends http.BaseClient {
  final http.Client _inner;
  final Alice _alice;

  _AliceHttpClient(this._inner, this._alice);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final int callId = request.hashCode;
    final call = AliceHttpCall(callId)
      ..client = 'http (package:http)'
      ..method = request.method
      ..uri = request.url.toString()
      ..endpoint = request.url.path.isEmpty ? '/' : request.url.path
      ..server = request.url.host
      ..secure = request.url.scheme == 'https';

    final httpRequest = AliceHttpRequest()
      ..size = request.contentLength ?? 0
      ..time = DateTime.now()
      ..headers = Map<String, String>.from(request.headers);

    if (request is http.Request) {
      httpRequest.body = request.body;
      httpRequest.size = request.bodyBytes.length;
    }

    call.request = httpRequest;

    final stopwatch = Stopwatch()..start();
    try {
      final streamedResponse = await _inner.send(request);
      stopwatch.stop();

      final bytes = await streamedResponse.stream.toBytes();
      final httpResponse = AliceHttpResponse()
        ..status = streamedResponse.statusCode
        ..size = bytes.length
        ..time = DateTime.now()
        ..headers = Map<String, String>.from(streamedResponse.headers)
        ..body = utf8.decode(bytes, allowMalformed: true);

      call.duration = stopwatch.elapsedMilliseconds;
      call.response = httpResponse;
      _alice.addHttpCall(call);

      return http.StreamedResponse(
        Stream.value(bytes),
        streamedResponse.statusCode,
        contentLength: bytes.length,
        request: streamedResponse.request,
        headers: streamedResponse.headers,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: streamedResponse.persistentConnection,
        reasonPhrase: streamedResponse.reasonPhrase,
      );
    } catch (error) {
      stopwatch.stop();
      call.duration = stopwatch.elapsedMilliseconds;
      call.response = AliceHttpResponse();
      call.error = AliceHttpError()..error = error;
      _alice.addHttpCall(call);
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
