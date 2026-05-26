library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Enum representing different content types for HTTP requests
enum ContentType { json, urlEncoded, formData, plainText }

enum ResponseBodyType { raw, json, string, int, double, bool, binary }

enum _HttpMethod { get, post, put, delete }

class EasyHttpFile {
  final http.MultipartFile _multipartFile;

  EasyHttpFile._(this._multipartFile);

  factory EasyHttpFile.bytes({
    String field = 'file',
    required List<int> bytes,
    String? filename,
  }) {
    return EasyHttpFile._(
      http.MultipartFile.fromBytes(
        field,
        bytes,
        filename: filename,
      ),
    );
  }

  static Future<EasyHttpFile> path({
    String field = 'file',
    required String path,
    String? filename,
  }) async {
    return EasyHttpFile._(
      await http.MultipartFile.fromPath(
        field,
        path,
        filename: filename,
      ),
    );
  }

  factory EasyHttpFile.text({
    String field = 'file',
    required String value,
    String? filename,
  }) {
    return EasyHttpFile._(
      http.MultipartFile.fromString(
        field,
        value,
        filename: filename,
      ),
    );
  }

  factory EasyHttpFile.fromBytes(
    String field,
    List<int> value, {
    String? filename,
  }) {
    return EasyHttpFile.bytes(
      field: field,
      bytes: value,
      filename: filename,
    );
  }

  static Future<EasyHttpFile> fromPath(
    String field,
    String filePath, {
    String? filename,
  }) {
    return EasyHttpFile.path(
      field: field,
      path: filePath,
      filename: filename,
    );
  }

  factory EasyHttpFile.fromString(
    String field,
    String value, {
    String? filename,
  }) {
    return EasyHttpFile.text(
      field: field,
      value: value,
      filename: filename,
    );
  }
}

class EasyHttpResponse<T> {
  final T body;
  final int statusCode;
  final bool isRedirect;

  EasyHttpResponse({
    required this.body,
    required this.statusCode,
    required this.isRedirect,
  });
}

void _printLog(String message) {
  debugPrint("[ez_http] $message");
}

/// A easy to use HTTP package based on the http package
class EasyHttp {
  static EasyHttpFile fileFromBytes(
    String field,
    List<int> value, {
    String? filename,
  }) {
    return EasyHttpFile.bytes(
      field: field,
      bytes: value,
      filename: filename,
    );
  }

  static Future<EasyHttpFile> fileFromPath(
    String field,
    String filePath, {
    String? filename,
  }) {
    return EasyHttpFile.path(
      field: field,
      path: filePath,
      filename: filename,
    );
  }

  static EasyHttpFile fileFromString(
    String field,
    String value, {
    String? filename,
  }) {
    return EasyHttpFile.text(
      field: field,
      value: value,
      filename: filename,
    );
  }

  static EasyHttpFile fileBytes({
    String field = 'file',
    required List<int> bytes,
    String? filename,
  }) {
    return EasyHttpFile.bytes(
      field: field,
      bytes: bytes,
      filename: filename,
    );
  }

  static Future<EasyHttpFile> filePath({
    String field = 'file',
    required String path,
    String? filename,
  }) {
    return EasyHttpFile.path(
      field: field,
      path: path,
      filename: filename,
    );
  }

  static EasyHttpFile fileText({
    String field = 'file',
    required String value,
    String? filename,
  }) {
    return EasyHttpFile.text(
      field: field,
      value: value,
      filename: filename,
    );
  }

  static Future<EasyHttpResponse<T>?> get<T>(String url,
      {Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ResponseBodyType responseBodyType = ResponseBodyType.string,
      http.Client? client}) async {
    return _sendRequest<T>(
      _HttpMethod.get,
      url,
      headers: headers,
      maxRetry: maxRetry,
      retryDelay: retryDelay,
      responseBodyType: responseBodyType,
      client: client,
    );
  }

  static Future<EasyHttpResponse<T>?> post<T>(String url,
      {Object? body,
      List<EasyHttpFile>? files,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ContentType? contentType,
      ResponseBodyType responseBodyType = ResponseBodyType.string,
      http.Client? client}) async {
    return _sendRequest<T>(_HttpMethod.post, url,
        body: body,
        files: files,
        headers: headers,
        contentType: contentType,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType,
        client: client);
  }

  static Future<EasyHttpResponse<T>?> put<T>(String url,
      {Object? body,
      List<EasyHttpFile>? files,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ContentType? contentType,
      ResponseBodyType responseBodyType = ResponseBodyType.string,
      http.Client? client}) async {
    return _sendRequest<T>(_HttpMethod.put, url,
        body: body,
        files: files,
        headers: headers,
        contentType: contentType,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType,
        client: client);
  }

  static Future<EasyHttpResponse<T>?> delete<T>(String url,
      {Object? body,
      List<EasyHttpFile>? files,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ContentType? contentType,
      ResponseBodyType responseBodyType = ResponseBodyType.string,
      http.Client? client}) async {
    return _sendRequest<T>(_HttpMethod.delete, url,
        body: body,
        files: files,
        headers: headers,
        contentType: contentType,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType,
        client: client);
  }

  /// Returns the appropriate content type string for the given ContentType enum
  static String getContentTypeString(ContentType? contentType) {
    switch (contentType) {
      case ContentType.json:
        return 'application/json';
      case ContentType.urlEncoded:
      case null:
        return 'application/x-www-form-urlencoded';
      case ContentType.formData:
        return 'multipart/form-data';
      case ContentType.plainText:
        return 'text/plain';
    }
  }

  static Future<EasyHttpResponse<T>?> _sendRequest<T>(
      _HttpMethod method, String url,
      {Object? body,
      List<EasyHttpFile>? files,
      Map<String, String>? headers,
      ContentType? contentType,
      int maxRetry = 3,
      int retryDelay = 1,
      ResponseBodyType responseBodyType = ResponseBodyType.string,
      http.Client? client}) async {
    int retryCount = 0;
    final uri = Uri.parse(url);
    final activeClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      while (retryCount < maxRetry) {
        try {
          final response = await _executeRequest(
            activeClient,
            method,
            uri,
            body: body,
            files: files,
            headers: headers,
            contentType: contentType,
          );

          return EasyHttpResponse<T>(
            body: _parseResponseBody(
              response,
              responseBodyType: responseBodyType,
            ) as T,
            statusCode: response.statusCode,
            isRedirect: response.isRedirect,
          );
        } catch (e) {
          _printLog("Error: $e");
          retryCount++;
          if (retryCount >= maxRetry || !_canRetryRequest(files)) {
            if (!_canRetryRequest(files)) {
              _printLog(
                  'Multipart file uploads are not retried automatically.');
            }
            _printLog("Max retry reached. Returning null.");
            return null;
          }

          await Future.delayed(Duration(seconds: retryDelay));
        }
      }
    } finally {
      if (shouldCloseClient) {
        activeClient.close();
      }
    }

    return null;
  }

  static Future<http.Response> _executeRequest(
    http.Client client,
    _HttpMethod method,
    Uri uri, {
    Object? body,
    List<EasyHttpFile>? files,
    Map<String, String>? headers,
    ContentType? contentType,
  }) async {
    final requestHeaders = Map<String, String>.from(headers ?? const {});

    if (_shouldSendMultipart(contentType, files)) {
      return _sendMultipartRequest(
        client,
        method,
        uri,
        body: body,
        files: files,
        headers: requestHeaders,
      );
    }

    final payload = _preparePayload(
      body,
      contentType: contentType,
      headers: requestHeaders,
    );

    switch (method) {
      case _HttpMethod.get:
        return client.get(uri, headers: requestHeaders);
      case _HttpMethod.post:
        return client.post(uri, headers: requestHeaders, body: payload);
      case _HttpMethod.put:
        return client.put(uri, headers: requestHeaders, body: payload);
      case _HttpMethod.delete:
        return client.delete(uri, headers: requestHeaders, body: payload);
    }
  }

  static bool _shouldSendMultipart(
    ContentType? contentType,
    List<EasyHttpFile>? files,
  ) {
    return contentType == ContentType.formData ||
        (files != null && files.isNotEmpty);
  }

  static bool _canRetryRequest(List<EasyHttpFile>? files) {
    return files == null || files.isEmpty;
  }

  static Object? _preparePayload(
    Object? body, {
    required ContentType? contentType,
    required Map<String, String> headers,
  }) {
    if (body == null) {
      return null;
    }

    switch (contentType) {
      case ContentType.json:
        _putHeaderIfAbsent(
            headers, 'Content-Type', getContentTypeString(contentType));
        return jsonEncode(body);
      case ContentType.urlEncoded:
      case null:
        if (body is Map) {
          return _stringifyBodyMap(body);
        }
        return body;
      case ContentType.formData:
        return body;
      case ContentType.plainText:
        _putHeaderIfAbsent(
            headers, 'Content-Type', getContentTypeString(contentType));
        return body is String ? body : body.toString();
    }
  }

  static Future<http.Response> _sendMultipartRequest(
    http.Client client,
    _HttpMethod method,
    Uri uri, {
    Object? body,
    List<EasyHttpFile>? files,
    required Map<String, String> headers,
  }) async {
    if (body != null && body is! Map) {
      throw ArgumentError('formData requests require a Map body.');
    }

    final request = http.MultipartRequest(_methodName(method), uri)
      ..headers.addAll(_withoutContentType(headers));

    if (body != null) {
      request.fields.addAll(_stringifyBodyMap(body as Map));
    }

    if (files != null && files.isNotEmpty) {
      request.files.addAll(
        files.map((file) => file._multipartFile),
      );
    }

    final streamedResponse = await client.send(request);
    return http.Response.fromStream(streamedResponse);
  }

  static Map<String, String> _stringifyBodyMap(Map body) {
    return body.map<String, String>(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  static void _putHeaderIfAbsent(
    Map<String, String> headers,
    String name,
    String value,
  ) {
    final hasHeader = headers.keys.any(
      (headerName) => headerName.toLowerCase() == name.toLowerCase(),
    );

    if (!hasHeader) {
      headers[name] = value;
    }
  }

  static Map<String, String> _withoutContentType(Map<String, String> headers) {
    final filteredHeaders = Map<String, String>.from(headers);
    filteredHeaders.removeWhere(
      (headerName, _) => headerName.toLowerCase() == 'content-type',
    );
    return filteredHeaders;
  }

  static String _methodName(_HttpMethod method) {
    switch (method) {
      case _HttpMethod.get:
        return 'GET';
      case _HttpMethod.post:
        return 'POST';
      case _HttpMethod.put:
        return 'PUT';
      case _HttpMethod.delete:
        return 'DELETE';
    }
  }

  static dynamic _parseResponseBody(http.Response response,
      {ResponseBodyType responseBodyType = ResponseBodyType.string}) {
    if (responseBodyType == ResponseBodyType.binary) {
      return response.bodyBytes;
    }

    final decodedBody = utf8.decode(response.bodyBytes);

    switch (responseBodyType) {
      case ResponseBodyType.raw:
        return decodedBody;
      case ResponseBodyType.json:
        return json.decode(decodedBody);
      case ResponseBodyType.string:
        return decodedBody.toString();
      case ResponseBodyType.int:
        return int.tryParse(decodedBody) ?? 0;
      case ResponseBodyType.double:
        return double.tryParse(decodedBody) ?? 0;
      case ResponseBodyType.bool:
        return decodedBody == 'true';
      case ResponseBodyType.binary:
        return response.bodyBytes;
    }
  }
}
