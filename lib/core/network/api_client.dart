// lib/core/network/api_client.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/local_storage.dart';
import '../utils/app_logger.dart';
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _httpClient;
  final LocalStorage _storage;

  ApiClient({http.Client? httpClient, required LocalStorage storage})
      : _httpClient = httpClient ?? http.Client(),
        _storage = storage;

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final base = AppConfig.current.apiBaseUrl;
    // ensure no double slashes
    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath').replace(
      queryParameters: queryParameters?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Map<String, String> _headers({bool isJson = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    } else {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    }

    final token = _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final uri = _buildUri(path, queryParameters);
    AppLogger.d('GET: $uri');
    try {
      final response = await _httpClient
          .get(uri, headers: _headers())
          .timeout(AppConfig.current.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please check your connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> postJson(String path, dynamic body) async {
    final uri = _buildUri(path);
    final encoded = jsonEncode(body);
    AppLogger.d('POST JSON: $uri -> $encoded');
    try {
      final response = await _httpClient
          .post(uri, headers: _headers(isJson: true), body: encoded)
          .timeout(AppConfig.current.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please check your connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> postForm(String path, Map<String, String> fields) async {
    final uri = _buildUri(path);
    AppLogger.d('POST FORM: $uri -> $fields');
    try {
      final response = await _httpClient
          .post(uri, headers: _headers(isJson: false), body: fields)
          .timeout(AppConfig.current.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please check your connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> patchJson(String path, dynamic body) async {
    final uri = _buildUri(path);
    final encoded = jsonEncode(body);
    AppLogger.d('PATCH JSON: $uri -> $encoded');
    try {
      final response = await _httpClient
          .patch(uri, headers: _headers(isJson: true), body: encoded)
          .timeout(AppConfig.current.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException('Request timed out.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> putJson(String path, dynamic body) async {
    final uri = _buildUri(path);
    final encoded = jsonEncode(body);
    AppLogger.d('PUT JSON: $uri -> $encoded');
    try {
      final response = await _httpClient
          .put(uri, headers: _headers(isJson: true), body: encoded)
          .timeout(AppConfig.current.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException('Request timed out.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> delete(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    AppLogger.d('DELETE: $uri');
    try {
      final response = await _httpClient
          .delete(
            uri,
            headers: _headers(isJson: true),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.current.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException('Request timed out.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  dynamic _handleResponse(http.Response response) {
    AppLogger.d('Response [${response.statusCode}]: ${response.body}');

    // 204 No Content
    if (response.statusCode == 204) {
      return null;
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    // Extract error message from FastAPI detail
    String errorMessage = 'An error occurred. Please try again.';
    if (decoded is Map && decoded.containsKey('detail')) {
      final detail = decoded['detail'];
      if (detail is String) {
        errorMessage = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // Pydantic validation error list: [{"loc": ["body", "email"], "msg": "value is not a valid email"}]
        final first = detail.first;
        if (first is Map && first.containsKey('msg')) {
          final loc = (first['loc'] as List?)?.last?.toString() ?? 'Field';
          errorMessage = '$loc: ${first['msg']}';
        } else {
          errorMessage = detail.toString();
        }
      }
    }

    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(errorMessage);
      case 403:
        throw ForbiddenException(errorMessage);
      case 404:
        throw NotFoundException(errorMessage);
      case 409:
        throw ConflictException(errorMessage);
      case 422:
        throw ValidationException(errorMessage, details: decoded);
      default:
        throw ApiException(errorMessage, statusCode: response.statusCode, details: decoded);
    }
  }
}
