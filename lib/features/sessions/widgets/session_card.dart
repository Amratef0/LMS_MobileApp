import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/session_model.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, required this.onTap});
  final SessionListItem session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(
                    label: Labels.sessionStatus(session.status),
                    status: session.status,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip(Icons.person_outline, session.trainer.name),
                  _chip(Icons.groups_outlined, session.group.name),
                  _chip(session.type == 'live' ? Icons.videocam_outlined : Icons.location_on_outlined,
                      Labels.sessionType(session.type)),
                  _chip(Icons.bookmark_border, Labels.sessionTopic(session.topic)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(AppDateUtils.dateTime(session.sessionDate),
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
