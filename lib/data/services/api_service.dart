import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  final StorageService _storage;
  final http.Client _client;

  ApiService(this._storage, {http.Client? client})
      : _client = client ?? http.Client();

  String get baseUrl => _storage.getBaseUrl();

  Map<String, String> _getHeaders({bool isMultipart = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$baseUrl$cleanEndpoint';
    
    if (queryParams != null && queryParams.isNotEmpty) {
      final sanitizedParams = queryParams.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      return Uri.parse(fullUrl).replace(queryParameters: sanitizedParams);
    }
    return Uri.parse(fullUrl);
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String errorMessage = 'Terjadi kesalahan pada server (${response.statusCode})';
    Map<String, dynamic>? errors;

    if (body is Map<String, dynamic>) {
      if (body.containsKey('message') && body['message'] is String) {
        errorMessage = body['message'];
      }
      if (body.containsKey('errors') && body['errors'] is Map<String, dynamic>) {
        final errMap = body['errors'] as Map<String, dynamic>;
        errors = errMap;
        final firstErrorKey = errMap.keys.firstOrNull;
        if (firstErrorKey != null) {
          final firstErrorList = errMap[firstErrorKey];
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            errorMessage = firstErrorList.first.toString();
          }
        }
      }
    }

    throw ApiException(errorMessage, statusCode: response.statusCode, errors: errors);
  }

  // GET Request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet atau alamat server.');
    } on http.ClientException {
      throw ApiException('Gagal berkomunikasi dengan server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // POST Request (JSON)
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // PUT Request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .delete(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // Multipart Form Request (for file/image uploads)
  Future<dynamic> multipartRequest({
    required String method,
    required String endpoint,
    Map<String, String>? fields,
    String? fileField,
    String? filePath,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest(method, uri);

      request.headers.addAll(_getHeaders(isMultipart: true));

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (fileField != null && filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          final extension = filePath.split('.').last.toLowerCase();
          MediaType mediaType = MediaType('image', 'jpeg');
          if (extension == 'png') {
            mediaType = MediaType('image', 'png');
          } else if (extension == 'webp') {
            mediaType = MediaType('image', 'webp');
          }

          request.files.add(
            await http.MultipartFile.fromPath(
              fileField,
              filePath,
              contentType: mediaType,
            ),
          );
        }
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}
