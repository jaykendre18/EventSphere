import 'dart:convert';

import 'package:integrated_grp_frontend/models/event_application.dart';
import 'package:integrated_grp_frontend/models/event_item.dart';
import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

class EventApi {
  EventApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<List<EventItem>> getEvents() async {
    final response = await _client.get(_uri('/api/events')).timeout(const Duration(seconds: 10));
    _ensureSuccess(response);
    final items = jsonDecode(response.body) as List<dynamic>;
    return items
        .map((item) => EventItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createEvent({
    required String name,
    required String duration,
    required String description,
  }) async {
    final response = await _client
        .post(
          _uri('/api/events'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'duration': duration,
            'description': description,
          }),
        )
        .timeout(const Duration(seconds: 10));
    _ensureSuccess(response);
  }

  Future<void> applyToEvent({
    required int eventId,
    required String applicantName,
    required String reason,
  }) async {
    final response = await _client
        .post(
          _uri('/api/events/$eventId/applications'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'applicantName': applicantName,
            'reason': reason,
          }),
        )
        .timeout(const Duration(seconds: 10));
    _ensureSuccess(response);
  }

  Future<List<EventApplication>> getApplications(int eventId) async {
    final response = await _client
        .get(_uri('/api/events/$eventId/applications'))
        .timeout(const Duration(seconds: 10));
    _ensureSuccess(response);
    final items = jsonDecode(response.body) as List<dynamic>;
    return items
        .map((item) => EventApplication.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    var message = 'Request failed (${response.statusCode}).';
    try {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      message = payload['message'] as String? ?? message;
    } on FormatException {
      if (response.body.isNotEmpty) message = response.body;
    } on TypeError {
      // Keep the HTTP status message when the server response is not an error object.
    }
    throw EventApiException(message);
  }
}

class EventApiException implements Exception {
  const EventApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
