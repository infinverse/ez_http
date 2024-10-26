# Easy HTTP

Easy HTTP is a lightweight Flutter package that simplifies HTTP requests, making it effortless to perform GET, POST, PUT, and DELETE operations. With an intuitive API, you can start making network requests right away without any complex setup.

## Features

- 🚀 Simple and intuitive API for HTTP requests
- 🔧 Supports GET, POST, PUT, and DELETE methods out of the box
- 🎯 Minimal setup required - start using it immediately
- 🔄 Easy handling of JSON data
- 🛠 Customizable headers and request parameters

## Getting started

To use this package, add `ez_http` as a dependency in your `pubspec.yaml` file:
```yaml
dependencies:
  ez_http: ^1.0.6
```

Then run `dart pub get` or `flutter pub get` to install the package.

## Usage

Here are some quick examples to get you started with Easy HTTP:

### GET Request

```dart
import 'package:ez_http/ez_http.dart';

void main() async {
  final response = await EasyHttp.get('https://api.example.com/users');
  print(response.body);
}
```

### POST Request

```dart
import 'package:ez_http/ez_http.dart';

void main() async {
  final response = await EasyHttp.post(
    'https://api.example.com/users',
    body: {'name': 'John Doe', 'email': 'john@example.com'},
    responseBodyType: ResponseBodyType.json,
    contentType: ContentType.json,
  );
  print(response.statusCode);
  print(response.body);
}
```

### PUT Request

```dart
import 'package:ez_http/ez_http.dart';

void main() async {
  final response = await EasyHttp.put(
    'https://api.example.com/users/1',
    body: {'name': 'Jane Doe'},
    responseBodyType: ResponseBodyType.json,
    contentType: ContentType.json,
  );
  print(response.statusCode);
}
```

### DELETE Request

```dart
import 'package:ez_http/ez_http.dart';

void main() async {
  final response = await EasyHttp.delete('https://api.example.com/users/1');
  print(response.statusCode);
}
```

## Additional information

For more detailed examples and advanced usage, please check out the `/example` folder in the package repository.

### Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please file an issue on the [GitHub repository](https://github.com/infinverse/ez_http).

### License

This package is released under the MIT License. See the LICENSE file for details.
