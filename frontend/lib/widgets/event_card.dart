import 'package:flutter/material.dart';
import 'package:integrated_grp_frontend/models/event_item.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    required this.event,
    required this.onApply,
    required this.onViewApplicants,
    super.key,
  });

  final EventItem event;
  final VoidCallback onApply;
  final VoidCallback onViewApplicants;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDE4DC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F2EC),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.event_available, color: Color(0xFF16765F)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          color: Color(0xFF173B35),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.duration,
                        style: const TextStyle(color: Color(0xFF6D776F), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${event.applicantCount} applied',
                  style: const TextStyle(
                    color: Color(0xFF52645A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              event.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF47564F), height: 1.45),
            ),
            const SizedBox(height: 17),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: Key('apply-${event.id}'),
                  onPressed: onApply,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Apply'),
                ),
                OutlinedButton.icon(
                  key: Key('applicants-${event.id}'),
                  onPressed: onViewApplicants,
                  icon: const Icon(Icons.groups_outlined),
                  label: const Text('Applicants'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}