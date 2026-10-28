import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:integrated_grp_frontend/screens/event_dashboard_screen.dart';
import 'package:integrated_grp_frontend/services/event_api.dart';
import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

void main() {
  runApp(const EventSphereApp());
}

class EventSphereApp extends StatelessWidget {
  const EventSphereApp({super.key, this.api});

  final EventApi? api;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF173B35);
    const canvas = Color(0xFFF4F5EF);

    return MaterialApp(
      title: 'EventSphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16836B),
          surface: canvas,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: canvas,
          foregroundColor: ink,
          centerTitle: false,
        ),
      ),
      home: EventDashboardScreen(api: api ?? EventApi()),
    );
  }
}

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  String? _status;
  String? _service;
  String? _error;
  bool _isLoading = false;

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/api/health'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw Exception('Server returned HTTP ${response.statusCode}.');
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _status = payload['status'] as String? ?? 'UNKNOWN';
        _service = payload['service'] as String? ?? 'Unknown service';
      });
    } on Exception catch (exception) {
      if (!mounted) return;
      setState(() {
        _error = exception.toString().replaceFirst('Exception: ', '');
        _status = null;
        _service = null;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = _status == 'UP';
    final statusColor = _error != null
        ? const Color(0xFFB34335)
        : isHealthy
            ? const Color(0xFF167D68)
            : const Color(0xFF727A73);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'INTEGRATED GROUP',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            tooltip: 'Check backend connection',
            onPressed: _isLoading ? null : _checkConnection,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              children: [
                const Text(
                  'Your workspace,\nconnected.',
                  style: TextStyle(
                    color: Color(0xFF173B35),
                    fontSize: 38,
                    height: 1.08,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Flutter is ready. Check the Spring Boot service to confirm the connection.',
                  style: TextStyle(color: Color(0xFF626B64), fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDE2D9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BACKEND SERVICE',
                        style: TextStyle(
                          color: Color(0xFF727A73),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Icon(
                            _error != null
                                ? Icons.error_outline
                                : isHealthy
                                    ? Icons.check_circle_outline
                                    : Icons.radio_button_unchecked,
                            color: statusColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isLoading
                                  ? 'Checking connection...'
                                  : _error != null
                                      ? 'Connection failed'
                                      : _status ?? 'Not checked yet',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (_isLoading)
                            const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      if (_service != null || _error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error ?? _service!,
                          style: const TextStyle(color: Color(0xFF626B64), height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 22),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      const Text(
                        'API endpoint',
                        style: TextStyle(color: Color(0xFF727A73), fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      SelectableText(
                        '$apiBaseUrl/api/health',
                        style: const TextStyle(
                          color: Color(0xFF173B35),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _checkConnection,
                          icon: const Icon(Icons.link),
                          label: const Text('Check connection'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'INTEGRATED GRP  /  DEVELOPMENT',
                  style: TextStyle(
                    color: Color(0xFF727A73),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}