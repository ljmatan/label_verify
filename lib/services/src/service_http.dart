import 'dart:convert';

import 'package:http/http.dart' as http;

/// Service implemented for making and handling HTTP calls.
///
class LvServiceHttp {
  LvServiceHttp._();

  /// Globally-accessible class instance.
  ///
  static final instance = LvServiceHttp._();

  /// Default server client response timeout.
  ///
  final _timeout = const Duration(seconds: 10);

  /// Sends an HTTP GET request with the given headers to the given URL.
  ///
  Future<dynamic> get(
    Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final response = await http
        .get(
          url,
          headers: headers,
        )
        .timeout(timeout ?? _timeout);
    dynamic decodedBody;
    try {
      decodedBody = jsonDecode(response.body);
    } catch (e) {
      // Do nothing, response type is not in JSON format.
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Error making GET request to $url:\n${decodedBody['message'] ?? response.body}',
      );
    }
    return decodedBody;
  }

  /// Sends an HTTP GET request with the given headers to the given URL.
  ///
  Future<dynamic> post(
    Uri url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final response = await http
        .post(
          url,
          body: jsonEncode(body),
          headers: headers,
        )
        .timeout(timeout ?? _timeout);
    dynamic decodedBody;
    try {
      decodedBody = jsonDecode(response.body);
    } catch (e) {
      // Do nothing, response type is not in JSON format.
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Error making POST request to $url:\n${decodedBody['message'] ?? response.body}',
      );
    }
    return decodedBody;
  }
}
