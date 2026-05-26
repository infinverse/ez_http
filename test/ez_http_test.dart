import 'dart:convert';
import 'dart:typed_data';

import 'package:ez_http/ez_http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('EasyHttp', () {
    test('parses JSON responses and preserves metadata', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');

        return http.Response(
          jsonEncode({'ok': true}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final response = await EasyHttp.get<Map<String, dynamic>>(
        'https://example.com/users',
        client: client,
        responseBodyType: ResponseBodyType.json,
      );

      expect(response, isNotNull);
      expect(response!.statusCode, 200);
      expect(response.isRedirect, isFalse);
      expect(response.body, {'ok': true});
    });

    test('encodes JSON request bodies', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.headers['content-type'] ?? request.headers['Content-Type'],
          startsWith('application/json'),
        );
        expect(request.body, '{"name":"Jack","age":30}');

        return http.Response('created', 201);
      });

      final response = await EasyHttp.post<String>(
        'https://example.com/users',
        body: {'name': 'Jack', 'age': 30},
        contentType: ContentType.json,
        client: client,
      );

      expect(response, isNotNull);
      expect(response!.statusCode, 201);
      expect(response.body, 'created');
    });

    test('stringifies default form fields for url encoded requests', () async {
      late http.Request capturedRequest;

      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('ok', 200);
      });

      await EasyHttp.post<String>(
        'https://example.com/login',
        body: {'name': 'Jack', 'age': 30},
        client: client,
      );

      expect(
        Uri.splitQueryString(capturedRequest.body),
        {'name': 'Jack', 'age': '30'},
      );
      expect(
        capturedRequest.headers['content-type'] ??
            capturedRequest.headers['Content-Type'],
        startsWith('application/x-www-form-urlencoded'),
      );
    });

    test('builds multipart form-data requests when requested', () async {
      late http.Request capturedRequest;

      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('uploaded', 200);
      });

      final response = await EasyHttp.post<String>(
        'https://example.com/upload',
        body: {'token': 'abc123'},
        contentType: ContentType.formData,
        client: client,
      );

      final multipartBody = utf8.decode(
        capturedRequest.bodyBytes,
        allowMalformed: true,
      );

      expect(response, isNotNull);
      expect(
        capturedRequest.headers['content-type'] ??
            capturedRequest.headers['Content-Type'],
        startsWith('multipart/form-data; boundary='),
      );
      expect(multipartBody, contains('name="token"'));
      expect(multipartBody, contains('abc123'));
    });

    test('uploads multipart files and switches to multipart automatically',
        () async {
      late http.Request capturedRequest;

      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('uploaded', 200);
      });

      final response = await EasyHttp.post<String>(
        'https://example.com/upload',
        body: {'folder': 'avatars'},
        files: [
          http.MultipartFile.fromString(
            'file',
            'hello world',
            filename: 'hello.txt',
          ),
        ],
        client: client,
      );

      final multipartBody = utf8.decode(
        capturedRequest.bodyBytes,
        allowMalformed: true,
      );

      expect(response, isNotNull);
      expect(
        capturedRequest.headers['content-type'] ??
            capturedRequest.headers['Content-Type'],
        startsWith('multipart/form-data; boundary='),
      );
      expect(multipartBody, contains('name="folder"'));
      expect(multipartBody, contains('avatars'));
      expect(multipartBody, contains('name="file"; filename="hello.txt"'));
      expect(multipartBody, contains('hello world'));
    });

    test('returns binary response bytes untouched', () async {
      final bytes = Uint8List.fromList([0, 1, 2, 255]);
      final client = MockClient((request) async {
        return http.Response.bytes(bytes, 200);
      });

      final response = await EasyHttp.get<Uint8List>(
        'https://example.com/file',
        client: client,
        responseBodyType: ResponseBodyType.binary,
      );

      expect(response, isNotNull);
      expect(response!.body, orderedEquals(bytes));
    });

    test('does not retry multipart file uploads automatically', () async {
      var attempts = 0;
      final client = MockClient((request) async {
        attempts++;
        throw Exception('temporary upload failure');
      });

      final response = await EasyHttp.post<String>(
        'https://example.com/upload',
        files: [
          http.MultipartFile.fromString(
            'file',
            'hello world',
            filename: 'hello.txt',
          ),
        ],
        client: client,
        maxRetry: 3,
        retryDelay: 0,
      );

      expect(attempts, 1);
      expect(response, isNull);
    });

    test('retries failed requests up to maxRetry', () async {
      var attempts = 0;
      final client = MockClient((request) async {
        attempts++;
        if (attempts == 1) {
          throw Exception('temporary failure');
        }

        return http.Response('ok', 200);
      });

      final response = await EasyHttp.get<String>(
        'https://example.com/retry',
        client: client,
        maxRetry: 2,
        retryDelay: 0,
      );

      expect(attempts, 2);
      expect(response, isNotNull);
      expect(response!.body, 'ok');
    });
  });
}
