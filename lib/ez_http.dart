library ez_http;

import 'package:http/http.dart' as http;
import 'dart:convert';

/// Enum representing different content types for HTTP requests
enum ContentType { json, urlEncoded, formData, plainText }

enum ResponseBodyType { json, string, int, double, bool }

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

/// A easy to use HTTP package based on the http package
class EasyHttp {
  static Future<EasyHttpResponse<T>?> get<T>(String url,
      {Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ResponseBodyType responseBodyType = ResponseBodyType.string}) async {
    return _sendRequest<T>(
      http.get,
      url,
      headers: headers,
      maxRetry: maxRetry,
      retryDelay: retryDelay,
      responseBodyType: responseBodyType,
    );
  }

  static Future<EasyHttpResponse<T>?> post<T>(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ContentType? contentType,
      ResponseBodyType responseBodyType = ResponseBodyType.string}) async {
    return _sendRequest<T>(http.post, url,
        body: body,
        headers: headers,
        contentType: contentType,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType);
  }

  static Future<EasyHttpResponse<T>?> put<T>(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ContentType? contentType,
      ResponseBodyType responseBodyType = ResponseBodyType.string}) async {
    return _sendRequest<T>(http.put, url,
        body: body,
        headers: headers,
        contentType: contentType,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType);
  }

  static Future<EasyHttpResponse<T>?> delete<T>(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      int maxRetry = 3,
      int retryDelay = 1,
      ContentType? contentType,
      ResponseBodyType responseBodyType = ResponseBodyType.string}) async {
    return _sendRequest<T>(http.delete, url,
        body: body,
        headers: headers,
        contentType: contentType,
        maxRetry: maxRetry,
        retryDelay: retryDelay,
        responseBodyType: responseBodyType);
  }

  /// Returns the appropriate content type string for the given ContentType enum
  static String getContentTypeString(ContentType? contentType) {
    switch (contentType) {
      case ContentType.json:
        return 'application/json';
      case ContentType.urlEncoded:
        return 'application/x-www-form-urlencoded';
      case ContentType.formData:
        return 'multipart/form-data';
      case ContentType.plainText:
        return 'text/plain';
      default:
        return 'application/x-www-form-urlencoded';
    }
  }

  static Future<EasyHttpResponse<T>?> _sendRequest<T>(
      Function method, String url,
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
        dynamic payload = body;
        if (body != null) {
          headers["Content-Type"] = getContentTypeString(contentType);
          if (contentType == ContentType.json) {
            payload = jsonEncode(body);
          }
        }

        final response = body == null
            ? await method(uri, headers: headers)
            : await method(uri, body: payload, headers: headers);

        return EasyHttpResponse<T>(
          body: _parseResponseBody(response, responseBodyType: responseBodyType)
              as T,
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
    final decodedBody = utf8.decode(response.bodyBytes);

    switch (responseBodyType) {
      case ResponseBodyType.json:
        return json.decode(decodedBody);
      case ResponseBodyType.string:
        return decodedBody;
      case ResponseBodyType.int:
        return int.tryParse(decodedBody) ?? 0;
      case ResponseBodyType.double:
        return double.tryParse(decodedBody) ?? 0;
      case ResponseBodyType.bool:
        return decodedBody == 'true';
      default:
        return decodedBody;
    }
  }
}
