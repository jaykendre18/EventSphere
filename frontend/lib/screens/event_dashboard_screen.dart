import 'dart:async';

import 'package:flutter/material.dart';
import 'package:integrated_grp_frontend/models/event_application.dart';
import 'package:integrated_grp_frontend/models/event_item.dart';
import 'package:integrated_grp_frontend/services/event_api.dart';
import 'package:integrated_grp_frontend/widgets/event_card.dart';

class EventDashboardScreen extends StatefulWidget {
  const EventDashboardScreen({required this.api, super.key});

  final EventApi api;

  @override
  State<EventDashboardScreen> createState() => _EventDashboardScreenState();
}

class _EventDashboardScreenState extends State<EventDashboardScreen> {
  List<EventItem> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadEvents());
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final events = await widget.api.getEvents();
      if (mounted) setState(() => _events = events);
    } on Exception catch (exception) {
      if (mounted) setState(() => _error = exception.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createEvent() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => CreateEventDialog(api: widget.api),
    );
    if (created != true || !mounted) return;
    await _loadEvents();
    if (mounted) _showMessage('Event added to the event list.');
  }

  Future<void> _apply(EventItem event) async {
    final applied = await showDialog<bool>(
      context: context,
      builder: (context) => ApplyDialog(api: widget.api, event: event),
    );
    if (applied != true || !mounted) return;
    await _loadEvents();
    if (mounted) _showMessage('Your application was submitted.');
  }

  Future<void> _showApplicants(EventItem event) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ApplicantsSheet(api: widget.api, event: event),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Refresh events',
            onPressed: _isLoading ? null : _loadEvents,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text(
              'Make room for\nsomething great.',
              style: TextStyle(
                color: Color(0xFF173B35),
                fontSize: 34,
                height: 1.08,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Discover gatherings, share your idea, and bring people together.',
              style: TextStyle(color: Color(0xFF657168), fontSize: 15, height: 1.45),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                key: const Key('create-event-button'),
                onPressed: _createEvent,
                icon: const Icon(Icons.add),
                label: const Text('Create event'),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Events',
                    style: TextStyle(
                      color: Color(0xFF173B35),
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${_events.length} listed',
                  style: const TextStyle(color: Color(0xFF657168), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 13),
            if (_error != null) _ErrorPanel(message: _error!, onRetry: _loadEvents),
            if (_isLoading && _events.isEmpty && _error == null)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_isLoading && _events.isEmpty && _error == null) const _EmptyEventsPanel(),
            for (final event in _events)
              EventCard(
                event: event,
                onApply: () => _apply(event),
                onViewApplicants: () => _showApplicants(event),
              ),
          ],
        ),
      ),
    );
  }
}

class CreateEventDialog extends StatefulWidget {
  const CreateEventDialog({required this.api, super.key});

  final EventApi api;

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.api.createEvent(
        name: _nameController.text.trim(),
        duration: _durationController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (exception) {
      if (mounted) setState(() => _error = exception.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create an event'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('event-name-field'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Event name'),
                  maxLength: 120,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('event-duration-field'),
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Duration (e.g. 2 days)'),
                  maxLength: 100,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('event-description-field'),
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 4000,
                  validator: _required,
                ),
                if (_error != null) _InlineError(message: _error!),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('submit-event-button'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit event'),
        ),
      ],
    );
  }
}

class ApplyDialog extends StatefulWidget {
  const ApplyDialog({required this.api, required this.event, super.key});

  final EventApi api;
  final EventItem event;

  @override
  State<ApplyDialog> createState() => _ApplyDialogState();
}

class _ApplyDialogState extends State<ApplyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.api.applyToEvent(
        eventId: widget.event.id,
        applicantName: _nameController.text.trim(),
        reason: _reasonController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (exception) {
      if (mounted) setState(() => _error = exception.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Apply to ${widget.event.name}'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('applicant-name-field'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Your name'),
                  maxLength: 120,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('application-reason-field'),
                  controller: _reasonController,
                  decoration: const InputDecoration(labelText: 'Why do you want to apply?'),
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 2000,
                  validator: _required,
                ),
                if (_error != null) _InlineError(message: _error!),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('submit-application-button'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit application'),
        ),
      ],
    );
  }
}

class ApplicantsSheet extends StatefulWidget {
  const ApplicantsSheet({required this.api, required this.event, super.key});

  final EventApi api;
  final EventItem event;

  @override
  State<ApplicantsSheet> createState() => _ApplicantsSheetState();
}

class _ApplicantsSheetState extends State<ApplicantsSheet> {
  late Future<List<EventApplication>> _applications;

  @override
  void initState() {
    super.initState();
    _applications = widget.api.getApplications(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Applicants',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF173B35),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(widget.event.name, style: const TextStyle(color: Color(0xFF657168))),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<EventApplication>>(
                  future: _applications,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFB34335)),
                        ),
                      );
                    }
                    final applicants = snapshot.data ?? [];
                    if (applicants.isEmpty) {
                      return const Center(child: Text('No one has applied yet.'));
                    }
                    return ListView.separated(
                      itemCount: applicants.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final application = applicants[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE7F2EC),
                            foregroundColor: const Color(0xFF16765F),
                            child: Text(application.applicantName.characters.first.toUpperCase()),
                          ),
                          title: Text(application.applicantName),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(application.reason),
                          ),
                          isThreeLine: true,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyEventsPanel extends StatelessWidget {
  const _EmptyEventsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDE4DC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_note, size: 34, color: Color(0xFF728078)),
          SizedBox(height: 10),
          Text('No events yet', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text(
            'Create the first event and it will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF657168)),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EF),
        border: Border.all(color: const Color(0xFFF0C9C1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Color(0xFF9B3428))),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(message, style: const TextStyle(color: Color(0xFFB34335))),
      ),
    );
  }
}