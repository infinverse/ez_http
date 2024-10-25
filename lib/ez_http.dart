library ez_http;

import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

/// Enum representing different content types for HTTP requests
enum ContentType { json, urlEncoded, formData, plainText }

enum ResponseBodyType { json, string, int, double, bool }

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
      int retryDelay = 1,
      ResponseBodyType responseBodyType = ResponseBodyType.string}) async {
    return _sendRequest(http.get, url,
        headers: headers,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType);
  }

  static Future<EasyHttpResponse?> post(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ResponseBodyType responseBodyType = ResponseBodyType.string}) async {
    return _sendRequest(http.post, url,
        body: body,
        headers: headers,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType);
  }

  static Future<EasyHttpResponse?> put(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ResponseBodyType responseBodyType = ResponseBodyType.string}) async {
    return _sendRequest(http.put, url,
        body: body,
        headers: headers,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType);
  }

  static Future<EasyHttpResponse?> delete(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ResponseBodyType responseBodyType = ResponseBodyType.string}) async {
    return _sendRequest(http.delete, url,
        body: body,
        headers: headers,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType);
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
      int retryDelay = 1,
      ResponseBodyType responseBodyType = ResponseBodyType.string}) async {
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
          body:
              _parseResponseBody(response, responseBodyType: responseBodyType),
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

  static dynamic _parseResponseBody(http.Response response,
      {ResponseBodyType responseBodyType = ResponseBodyType.string}) {
    switch (responseBodyType) {
      case ResponseBodyType.json:
        return json.decode(response.body);
      case ResponseBodyType.string:
        return response.body;
      case ResponseBodyType.int:
        return int.tryParse(response.body) ?? 0;
      case ResponseBodyType.double:
        return double.tryParse(response.body) ?? 0;
      case ResponseBodyType.bool:
        return response.body == 'true';
      default:
        return response.body;
    }
  }
}
