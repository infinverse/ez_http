# Easy HTTP

Easy HTTP is a lightweight Flutter package that simplifies HTTP requests, making it effortless to perform GET, POST, PUT, and DELETE operations. With an intuitive API, you can start making network requests right away without any complex setup.

## Features

- 🚀 Simple and intuitive API for HTTP requests
- 🔧 Supports GET, POST, PUT, and DELETE methods out of the box
- 🎯 Minimal setup required - start using it immediately
- 🔄 Easy handling of JSON data
- 🛠 Customizable headers and request parameters
- 📎 Multipart form uploads with fields and files
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

### Multipart File Upload

```dart
import 'package:ez_http/ez_http.dart';
import 'package:http/http.dart' as http;

void main() async {
  final file = http.MultipartFile.fromBytes(
    'avatar',
    [1, 2, 3, 4],
    filename: 'avatar.png',
  );

  final response = await EasyHttp.post<String>(
    'https://api.example.com/upload',
    body: {'userId': '42'},
    files: [file],
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
- `files`: pass `List<http.MultipartFile>` to upload files with multipart form
  requests. If `files` is not empty, `EasyHttp` automatically uses multipart.
- `ContentType.plainText`: sends the body as a string.

Create `http.MultipartFile` with whichever constructor matches your platform:

- `http.MultipartFile.fromPath(...)`: useful on mobile/desktop when you have a file path.
- `http.MultipartFile.fromBytes(...)`: useful for web or in-memory file data.
- `http.MultipartFile.fromString(...)`: useful for text file uploads in tests.

Multipart file uploads are sent once per call. If an upload fails, create fresh
`http.MultipartFile` instances before calling `EasyHttp` again.

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

If you pass a custom `client`, you are responsible for closing it. If you do
not pass one, `EasyHttp` creates and closes its own client internally.

## Additional information

For more detailed examples and advanced usage, please check out the `/example` folder in the package repository.

### Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please file an issue on the [GitHub repository](https://github.com/infinverse/ez_http).

### License

This package is released under the MIT License. See the LICENSE file for details.
