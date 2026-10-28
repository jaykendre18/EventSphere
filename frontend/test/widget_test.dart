import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integrated_grp_frontend/main.dart';
import 'package:integrated_grp_frontend/services/event_api.dart';

void main() {
    testWidgets('creates an event, accepts an application, and shows applicants', (tester) async {
      final events = <Map<String, dynamic>>[];
      final applications = <int, List<Map<String, dynamic>>>{};
      var nextEventId = 1;
      var nextApplicationId = 1;

      final client = MockClient((request) async {
        final path = request.url.path;
        if (request.method == 'GET' && path == '/api/events') {
          return http.Response(jsonEncode(events), 200);
        }
        if (request.method == 'POST' && path == '/api/events') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          events.add({
            'id': nextEventId++,
            'name': body['name'],
            'duration': body['duration'],
            'description': body['description'],
            'applicantCount': 0,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          });
          return http.Response(jsonEncode(events.last), 201);
        }
        final applicationPath = RegExp(r'^/api/events/(\d+)/applications$').firstMatch(path);
        if (applicationPath == null) return http.Response('Not found', 404);

        final eventId = int.parse(applicationPath.group(1)!);
        applications.putIfAbsent(eventId, () => []);
        if (request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final application = {
            'id': nextApplicationId++,
            'eventId': eventId,
            'applicantName': body['applicantName'],
            'reason': body['reason'],
            'appliedAt': DateTime.now().toUtc().toIso8601String(),
          };
          applications[eventId]!.add(application);
          final event = events.singleWhere((item) => item['id'] == eventId);
          event['applicantCount'] = applications[eventId]!.length;
          return http.Response(jsonEncode(application), 201);
        }
        if (request.method == 'GET') {
          return http.Response(jsonEncode(applications[eventId]), 200);
        }
        return http.Response('Method not allowed', 405);
      });

      await tester.pumpWidget(EventSphereApp(api: EventApi(client: client, baseUrl: 'http://test')));
      await tester.pumpAndSettle();
      expect(find.text('No events yet'), findsOneWidget);

      await tester.tap(find.byKey(const Key('create-event-button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('event-name-field')), 'Campus Build Day');
      await tester.enterText(find.byKey(const Key('event-duration-field')), '1 day');
      await tester.enterText(find.byKey(const Key('event-description-field')), 'Build something useful.');
      await tester.ensureVisible(find.byKey(const Key('submit-event-button')));
      await tester.tap(find.byKey(const Key('submit-event-button')));
      await tester.pumpAndSettle();
      expect(find.text('Campus Build Day'), findsOneWidget);

      await tester.tap(find.byKey(const Key('apply-1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('applicant-name-field')), 'Taylor Morgan');
      await tester.enterText(find.byKey(const Key('application-reason-field')), 'I enjoy building tools.');
      await tester.ensureVisible(find.byKey(const Key('submit-application-button')));
      await tester.tap(find.byKey(const Key('submit-application-button')));
      await tester.pumpAndSettle();
      expect(find.text('1 applied'), findsOneWidget);

      await tester.tap(find.byKey(const Key('applicants-1')));
      await tester.pumpAndSettle();
      expect(find.text('Taylor Morgan'), findsOneWidget);
      expect(find.text('I enjoy building tools.'), findsOneWidget);
    });
}