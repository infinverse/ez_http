import 'package:flutter/material.dart';
import 'package:ez_http/ez_http.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'EasyHttp Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _response = 'No response yet';

  Future<void> _fetchData(String method) async {
    const String url = 'https://httpbin.org/';
    const Map<String, dynamic> body = {'name': 'John Doe', 'age': 30};

    // Using generic type and specifying response body type
    final EasyHttpResponse<Map<String, dynamic>>? response =
        await _sendRequest(method, url, body);

    if (response != null) {
      setState(() {
        _response = '''
Status Code: ${response.statusCode}
Is Redirect: ${response.isRedirect}
Body:
${_formatResponse(response.body)}''';
      });
    } else {
      setState(() {
        _response = 'Failed to fetch data';
      });
    }
  }

  Future<EasyHttpResponse<Map<String, dynamic>>?> _sendRequest(
      String method, String url, Map<String, dynamic> body) async {
    switch (method) {
      case 'get':
        return await EasyHttp.get<Map<String, dynamic>>(
          '$url$method',
          responseBodyType: ResponseBodyType.json,
        );
      case 'post':
        return await EasyHttp.post<Map<String, dynamic>>(
          '$url$method',
          body: body,
          contentType: ContentType.json,
          responseBodyType: ResponseBodyType.json,
        );
      case 'put':
        return await EasyHttp.put<Map<String, dynamic>>(
          '$url$method',
          body: body,
          contentType: ContentType.json,
          responseBodyType: ResponseBodyType.json,
        );
      case 'delete':
        return await EasyHttp.delete<Map<String, dynamic>>(
          '$url$method',
          body: body,
          contentType: ContentType.json,
          responseBodyType: ResponseBodyType.json,
        );
      default:
        return null;
    }
  }

  String _formatResponse(dynamic responseBody) {
    try {
      if (responseBody is String) {
        final Map<String, dynamic> jsonResponse = json.decode(responseBody);
        return const JsonEncoder.withIndent('  ').convert(jsonResponse);
      } else if (responseBody is Map<String, dynamic>) {
        return const JsonEncoder.withIndent('  ').convert(responseBody);
      } else {
        return responseBody.toString();
      }
    } catch (e) {
      return responseBody.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EasyHttp Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _fetchData('get'),
                  child: const Text('GET'),
                ),
                ElevatedButton(
                  onPressed: () => _fetchData('post'),
                  child: const Text('POST'),
                ),
                ElevatedButton(
                  onPressed: () => _fetchData('put'),
                  child: const Text('PUT'),
                ),
                ElevatedButton(
                  onPressed: () => _fetchData('delete'),
                  child: const Text('DELETE'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Response:'),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_response),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
