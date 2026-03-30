import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

// Thrown when the API returns a non-2xx status code
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  final String? token;

  /// Called when any API response returns 401 (token expired / invalid).
  static VoidCallback? onUnauthorized;

  ApiService({this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.baseUrl}$path'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(res);
    } on TimeoutException {
      throw ApiException(0, 'La connexion a expiré. Vérifiez votre réseau.');
    } on SocketException {
      throw ApiException(0, 'Pas de connexion internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(0, 'Erreur de connexion.');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(res);
    } on TimeoutException {
      throw ApiException(0, 'La connexion a expiré. Vérifiez votre réseau.');
    } on SocketException {
      throw ApiException(0, 'Pas de connexion internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(0, 'Erreur de connexion.');
    }
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .patch(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(res);
    } on TimeoutException {
      throw ApiException(0, 'La connexion a expiré. Vérifiez votre réseau.');
    } on SocketException {
      throw ApiException(0, 'Pas de connexion internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(0, 'Erreur de connexion.');
    }
  }

  dynamic _handleResponse(http.Response res) {
    if (res.body.isEmpty) return null;
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    // Token expired or invalid → trigger automatic logout
    if (res.statusCode == 401) {
      onUnauthorized?.call();
    }

    final msg = body['message'];
    throw ApiException(
      res.statusCode,
      msg is List ? msg.first.toString() : msg?.toString() ?? 'Erreur serveur',
    );
  }
}
