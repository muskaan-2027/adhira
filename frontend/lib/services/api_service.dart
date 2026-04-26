import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static final String baseUrl = _configuredBaseUrl.isNotEmpty
      ? _configuredBaseUrl
      : _defaultBaseUrl();

  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator maps host loopback via 10.0.2.2.
      return 'http://10.0.2.2:5000';
    }
    return 'http://127.0.0.1:5000';
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    late http.Response response;
    if (method == 'GET') {
      response = await http.get(uri, headers: headers);
    } else if (method == 'PATCH') {
      response = await http.patch(uri, headers: headers, body: jsonEncode(body ?? {}));
    } else {
      response = await http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
    }

    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};
    if (response.statusCode >= 400) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? 'Request failed'
          : response.body;
      throw Exception(message);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'data': decoded};
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return _request('POST', '/api/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _request('POST', '/api/auth/login', body: {
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> googleLogin(String idToken) {
    return _request('POST', '/api/auth/google', body: {'idToken': idToken});
  }

  static Future<Map<String, dynamic>> getProfile(String token) {
    return _request('GET', '/api/users/me', token: token);
  }

  static Future<Map<String, dynamic>> updateProfile(
    String token, {
    required String name,
    required bool voterIdVerified,
    required bool isAnonymous,
  }) {
    return _request('PATCH', '/api/users/profile', token: token, body: {
      'name': name,
      'voterIdVerified': voterIdVerified,
      'isAnonymous': isAnonymous,
    });
  }

  static Future<Map<String, dynamic>> updateRole(String token, String role) {
    return _request('PATCH', '/api/users/role', token: token, body: {'role': role});
  }

  static Future<Map<String, dynamic>> updateVolunteerAvailability(String token, String availability) {
    return _request('PATCH', '/api/volunteers/availability', token: token, body: {'availability': availability});
  }

  static Future<Map<String, dynamic>> sendSOS(
    String token, {
    required double lat,
    required double lng,
    String notes = '',
  }) {
    return _request('POST', '/api/sos', token: token, body: {
      'lat': lat,
      'lng': lng,
      'notes': notes,
    });
  }

  static Future<Map<String, dynamic>> getSOSHistory(String token) {
    return _request('GET', '/api/sos/history', token: token);
  }

  static Future<Map<String, dynamic>> createHelpRequest(
    String token, {
    required String message,
    String? sosId,
    String? volunteerId,
  }) {
    return _request('POST', '/api/help-requests', token: token, body: {
      'message': message,
      if (sosId != null) 'sosId': sosId,
      if (volunteerId != null) 'volunteerId': volunteerId,
    });
  }

  static Future<Map<String, dynamic>> getHelpRequests(String token) {
    return _request('GET', '/api/help-requests', token: token);
  }

  static Future<Map<String, dynamic>> updateHelpRequestStatus(
    String token,
    String requestId,
    String status,
    {String? assistanceNote}
  ) {
    return _request('PATCH', '/api/help-requests/$requestId/status', token: token, body: {
      'status': status,
      if (assistanceNote != null) 'assistanceNote': assistanceNote,
    });
  }

  static Future<Map<String, dynamic>> getVolunteerProfiles(
    String token, {
    bool onlyActive = true,
  }) {
    return _request(
      'GET',
      '/api/volunteers?onlyActive=${onlyActive ? "true" : "false"}',
      token: token,
    );
  }

  static Future<Map<String, dynamic>> analyzePost(
    String token, {
    required String content,
  }) {
    return _request(
      'POST',
      '/api/posts/analyze',
      token: token,
      body: {'content': content},
    );
  }

  static Future<Map<String, dynamic>> createPost(
    String token, {
    required String content,
    required bool isAnonymous,
  }) {
    return _request('POST', '/api/posts', token: token, body: {
      'content': content,
      'isAnonymous': isAnonymous,
    });
  }

  static Future<Map<String, dynamic>> getPosts() {
    return _request('GET', '/api/posts');
  }

  static Future<Map<String, dynamic>> chatbot(String message) {
    return _request('POST', '/api/chatbot', body: {'message': message});
  }
}
