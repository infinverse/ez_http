library ez_http;

import 'package:http/http.dart' as http;
import 'dart:convert';

/// Enum representing different content types for HTTP requests
enum ContentType { json, urlEncoded, formData, plainText }

class EasyHttpResponse {
  final dynamic body;
  final int statusCode;
  final bool isRedirect;

  EasyHttpResponse({
    required this.body,
    required this.statusCode,
    required this.isRedirect,
  });
}

/// A easy to use HTTP package based on the http package
class EasyHttp {
  static Future<EasyHttpResponse?> get(String url,
      {Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1}) async {
    return _sendRequest(http.get, url,
        headers: headers, maxRetry: maxRetry, retryDelay: retryDelay);
  }

  static Future<EasyHttpResponse?> post(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1}) async {
    return _sendRequest(http.post, url,
        body: body,
        headers: headers,
        maxRetry: maxRetry,
        retryDelay: retryDelay);
  }

  static Future<EasyHttpResponse?> put(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1}) async {
    return _sendRequest(http.put, url,
        body: body,
        headers: headers,
        maxRetry: maxRetry,
        retryDelay: retryDelay);
  }

  static Future<EasyHttpResponse?> delete(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1}) async {
    return _sendRequest(http.delete, url,
        body: body,
        headers: headers,
        maxRetry: maxRetry,
        retryDelay: retryDelay);
  }

  /// Returns the appropriate content type string for the given ContentType enum
  static String getContentTypeString(ContentType contentType) {
    switch (contentType) {
      case ContentType.json:
        return 'application/json';
      case ContentType.urlEncoded:
        return 'application/x-www-form-urlencoded';
      case ContentType.formData:
        return 'multipart/form-data';
      case ContentType.plainText:
        return 'text/plain';
    }
  }

  static Future<EasyHttpResponse?> _sendRequest(Function method, String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      ContentType? contentType,
      int maxRetry = 3,
      int retryDelay = 1}) async {
    int retryCount = 0;
    while (retryCount < maxRetry) {
      try {
        final uri = Uri.parse(url);
        headers ??= {};
        if (contentType != null) {
          headers["Content-Type"] = getContentTypeString(contentType);
        }

        final response = method is Future<http.Response> Function(Uri,
                {Map<String, String>? headers})
            ? await method(uri, headers: headers)
            : await method(uri, body: body, headers: headers);

        return EasyHttpResponse(
          body: _parseResponseBody(response),
          statusCode: response.statusCode,
          isRedirect: response.isRedirect,
        );
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetry) {
          return null;
        }
        // Add a delay before retrying
        await Future.delayed(Duration(seconds: retryDelay));
      }
    }
    return null;
  }

  static dynamic _parseResponseBody(http.Response response) {
    final contentType = response.headers['content-type'];
    if (contentType != null && contentType.contains('application/json')) {
      return json.decode(response.body);
    }
    return response.body;
  }
}
