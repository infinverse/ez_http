# Easy HTTP

Easy HTTP is a lightweight Flutter package that simplifies HTTP requests, making it effortless to perform GET, POST, PUT, and DELETE operations. With an intuitive API, you can start making network requests right away without any complex setup.

## Features

- 🚀 Simple and intuitive API for HTTP requests
- 🔧 Supports GET, POST, PUT, and DELETE methods out of the box
- 🎯 Minimal setup required - start using it immediately
- 🔄 Easy handling of JSON data
- 🛠 Customizable headers and request parameters
- 🧪 Optional custom `http.Client` for tests or client reuse

## Getting started

To use this package, add `ez_http` as a dependency in your `pubspec.yaml` file:
```yaml
dependencies:
  ez_http: ^1.0.9
```

Then run `dart pub get` or `flutter pub get` to install the package.

## Usage

Here are some quick examples to get you started with Easy HTTP:

All request methods return `Future<EasyHttpResponse<T>?>`. The parsed payload is
available on `response.body`.
If a request or response parse still fails after the configured attempts, the
method returns `null`.

### GET Request

```dart
import 'package:ez_http/ez_http.dart';

void main() async {
  final EasyHttpResponse<Map<String, dynamic>>? response =
      await EasyHttp.get<Map<String, dynamic>>(
    'https://api.example.com/users',
    responseBodyType: ResponseBodyType.json,
  );
  print(response?.body);
}
```

### POST Request

```dart
import 'package:ez_http/ez_http.dart';

void main() async {
  final EasyHttpResponse<Map<String, dynamic>>? response =
      await EasyHttp.post<Map<String, dynamic>>(
    'https://api.example.com/users',
    body: {'name': 'John Doe', 'email': 'john@example.com'},
    responseBodyType: ResponseBodyType.json,
    contentType: ContentType.json,
  );
  print(response?.statusCode);
  print(response?.body);
}
```

### PUT Request

```dart
import 'package:ez_http/ez_http.dart';

void main() async {
  final EasyHttpResponse<Map<String, dynamic>>? response =
      await EasyHttp.put<Map<String, dynamic>>(
    'https://api.example.com/users/1',
    body: {'name': 'Jane Doe'},
    responseBodyType: ResponseBodyType.json,
    contentType: ContentType.json,
  );
  print(response?.statusCode);
}
```

### DELETE Request

```dart
import 'package:ez_http/ez_http.dart';

void main() async {
  final EasyHttpResponse<Map<String, dynamic>>? response =
      await EasyHttp.delete<Map<String, dynamic>>(
    'https://api.example.com/users/1',
  );
  print(response?.statusCode);
}
```

### Body Types

- `ContentType.json`: accepts any JSON-encodable object and sends it as JSON.
- `ContentType.urlEncoded` or `null`: a `Map` body is sent as
  `application/x-www-form-urlencoded`.
- `ContentType.formData`: a `Map` body is sent as `multipart/form-data`, and
  `EasyHttp` manages the multipart boundary header for you.
- `ContentType.plainText`: sends the body as a string.

### Response Body Types

- `ResponseBodyType.raw` and `ResponseBodyType.string`: return a UTF-8 decoded
  string response.
- `ResponseBodyType.json`: parses JSON using `jsonDecode`.
- `ResponseBodyType.int`, `double`, `bool`: parse scalar values.
- `ResponseBodyType.binary`: returns `response.bodyBytes`.

### Custom Client

You can inject a custom `http.Client` when you want to reuse a client instance
or provide a mock client in tests:

```dart
import 'package:ez_http/ez_http.dart';
import 'package:http/http.dart' as http;

void main() async {
  final client = http.Client();

  try {
    final response = await EasyHttp.get<String>(
      'https://api.example.com/health',
      client: client,
    );
    print(response?.body);
  } finally {
    client.close();
  }
}
```

## Additional information

For more detailed examples and advanced usage, please check out the `/example` folder in the package repository.

### Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please file an issue on the [GitHub repository](https://github.com/infinverse/ez_http).

### License

This package is released under the MIT License. See the LICENSE file for details.
