import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/session_model.dart';
import '../auth/cubit/auth_cubit.dart';
import '../quizzes/quiz_detail_screen.dart';
import '../assignments/assignment_detail_screen.dart';
import 'cubit/session_detail_cubit.dart';
import 'cubit/session_detail_state.dart';
import 'sessions_repository.dart';
import 'edit_session_screen.dart';

/// Wraps [_SessionDetailView] with its own [SessionDetailCubit] so this
/// screen can be pushed from anywhere (sessions list, a quiz/assignment
/// back-link, etc.) without the caller needing to remember to provide one.
class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key, required this.sessionId});
  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => SessionDetailCubit(ctx.read<SessionsRepository>(), sessionId),
      child: _SessionDetailView(sessionId: sessionId),
    );
  }
}

class _SessionDetailView extends StatefulWidget {
  const _SessionDetailView({required this.sessionId});
  final int sessionId;

  @override
  State<_SessionDetailView> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<_SessionDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<SessionDetailCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = context.read<AuthCubit>().state.user?.isStaff ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        actions: [
          if (isStaff)
            BlocBuilder<SessionDetailCubit, SessionDetailState>(
              builder: (context, state) {
                if (state.session == null) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit session',
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => EditSessionScreen(session: state.session!)),
                    );
                    if (updated == true && context.mounted) {
                      context.read<SessionDetailCubit>().load();
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: BlocConsumer<SessionDetailCubit, SessionDetailState>(
        listenWhen: (p, c) => c.errorMessage != null && c.errorMessage != p.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) AppSnackbar.error(context, state.errorMessage!);
        },
        builder: (context, state) {
          if (state.status == DetailStatus.loading || state.status == DetailStatus.initial) {
            return const LoadingView();
          }
          if (state.status == DetailStatus.error && state.session == null) {
            return ErrorView(
              message: state.errorMessage ?? '',
              onRetry: () => context.read<SessionDetailCubit>().load(),
            );
          }
          final session = state.session!;
          return RefreshIndicator(
            onRefresh: () => context.read<SessionDetailCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _header(session),
                const SizedBox(height: 16),
                if (isStaff) _staffActions(context, session, state),
                if (isStaff) const SizedBox(height: 16),
                _infoCard(session),
                const SizedBox(height: 16),
                if (isStaff) ...[
                  _attendanceCard(context, session),
                  const SizedBox(height: 16),
                ],
                if (session.attachments.isNotEmpty) ...[
                  _sectionTitle('Attachments'),
                  ...session.attachments.map((a) => _attachmentTile(a)),
                  const SizedBox(height: 16),
                ],
                if (session.quizzes.isNotEmpty) ...[
                  _sectionTitle('Quizzes'),
                  ...session.quizzes.map((q) => _quizTile(context, q)),
                  const SizedBox(height: 16),
                ],
                if (session.assignments.isNotEmpty) ...[
                  _sectionTitle('Assignments'),
                  ...session.assignments.map((a) => _assignmentTile(context, a)),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(SessionDetail session) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(session.name,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        ),
        StatusBadge(label: Labels.sessionStatus(session.status), status: session.status),
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      );

  Widget _infoCard(SessionDetail session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _infoRow(Icons.person_outline, 'Instructor', session.trainer.name),
            _infoRow(Icons.groups_outlined, 'Group', session.group.name),
            _infoRow(Icons.event_outlined, 'Date', AppDateUtils.dateTime(session.sessionDate)),
            _infoRow(
              session.type == 'live' ? Icons.videocam_outlined : Icons.location_on_outlined,
              'Type',
              Labels.sessionType(session.type),
            ),
            _infoRow(Icons.bookmark_border, 'Topic', Labels.sessionTopic(session.topic)),
            if (session.location != null && session.location!.isNotEmpty)
              _infoRow(Icons.map_outlined, 'Location', session.location!),
            if (session.recordLink != null && session.recordLink!.isNotEmpty)
              _infoRow(Icons.play_circle_outline, 'Recording link', session.recordLink!,
                  isLink: true),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: isLink
                ? InkWell(
                    onTap: () => launchUrl(Uri.parse(value), mode: LaunchMode.externalApplication),
                    child: Text(value,
                        style: const TextStyle(color: AppColors.primary, fontSize: 13.5, decoration: TextDecoration.underline)),
                  )
                : Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _staffActions(BuildContext context, SessionDetail session, SessionDetailState state) {
    final cubit = context.read<SessionDetailCubit>();
    final busy = state.actionInProgress;
    List<Widget> buttons = [];
    if (session.isPending) {
      buttons.add(_actionBtn('Start Session', Icons.play_arrow, AppColors.success, busy,
          () async {
        final ok = await cubit.run();
        if (ok && context.mounted) AppSnackbar.success(context, 'Session started');
      }));
      buttons.add(_actionBtn('Cancel', Icons.close, AppColors.danger, busy, () async {
        final confirm = await showConfirmDialog(context,
            title: 'Cancel Session', message: 'Are you sure you want to cancel this session?', danger: true);
        if (!confirm) return;
        final ok = await cubit.cancel();
        if (ok && context.mounted) AppSnackbar.success(context, 'Session cancelled');
      }));
    } else if (session.isRunning) {
      buttons.add(_actionBtn('Finish Session', Icons.stop_circle_outlined, AppColors.primary, busy,
          () async {
        final ok = await cubit.finish();
        if (ok && context.mounted) AppSnackbar.success(context, 'Session finished');
      }));
    }
    if (buttons.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 10, runSpacing: 10, children: buttons);
  }

  Widget _actionBtn(String label, IconData icon, Color color, bool busy, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: busy ? null : onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _attendanceCard(BuildContext context, SessionDetail session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Attendance', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text('${session.attendanceJoined}/${session.attendanceTotal}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openAttendanceSheet(context),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(session.attendanceTaken ? 'Edit Attendance' : 'Take Attendance'),
            ),
          ],
        ),
      ),
    );
  }

  void _openAttendanceSheet(BuildContext context) {
    final cubit = context.read<SessionDetailCubit>();
    cubit.loadAttendance();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => BlocProvider.value(
        value: cubit,
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return BlocBuilder<SessionDetailCubit, SessionDetailState>(
              builder: (context, state) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Take Attendance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    if (state.attendanceLoading)
                      const Expanded(child: LoadingView())
                    else
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: state.attendance.length,
                          itemBuilder: (context, i) {
                            final row = state.attendance[i];
                            return CheckboxListTile(
                              value: row.joined,
                              title: Text(row.studentName),
                              subtitle: row.studentCode != null ? Text(row.studentCode!) : null,
                              onChanged: (v) =>
                                  cubit.toggleAttendance(row.studentId, v ?? false),
                            );
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.actionInProgress
                              ? null
                              : () async {
                                  final ok = await cubit.saveAttendance();
                                  if (ok && context.mounted) {
                                    Navigator.of(context).pop();
                                    AppSnackbar.success(context, 'Attendance saved');
                                  }
                                },
                          child: state.actionInProgress
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Save'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _attachmentTile(SessionAttachmentModel a) {
    final isLink = a.attachmentType == 'link';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(isLink ? Icons.link : Icons.picture_as_pdf_outlined, color: AppColors.primary),
        title: Text(a.title),
        subtitle: Text('Uploaded by ${a.uploadedBy}'),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () {
          final url = isLink ? a.link : a.fileUrl;
          if (url != null) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        },
      ),
    );
  }

  Widget _quizTile(BuildContext context, SessionQuizSummary q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.quiz_outlined, color: AppColors.info),
        title: Text(q.title),
        subtitle: Text(q.dueDate != null ? 'Due: ${AppDateUtils.dateTime(q.dueDate)}' : ''),
        trailing: q.iSubmitted
            ? Text('${q.myScore}/${q.myTotalPoints}',
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => QuizDetailScreen(quizId: q.id)),
        ),
      ),
    );
  }

  Widget _assignmentTile(BuildContext context, SessionAssignmentSummary a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.assignment_outlined, color: AppColors.warning),
        title: Text(a.title),
        subtitle: Text(a.dueDate != null ? 'Due: ${AppDateUtils.dateTime(a.dueDate)}' : ''),
        trailing: a.mySubmitted
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AssignmentDetailScreen(assignmentId: a.id)),
        ),
      ),
    );
  }
}
