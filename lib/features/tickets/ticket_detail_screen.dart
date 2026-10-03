import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/app_snackbar.dart';
import '../auth/cubit/auth_cubit.dart';
import 'cubit/ticket_detail_cubit.dart';
import 'cubit/ticket_detail_state.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});
  final int ticketId;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TicketDetailCubit>().load();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final isStaff = user?.isStaff ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket')),
      body: BlocConsumer<TicketDetailCubit, TicketDetailState>(
        listenWhen: (p, c) => c.errorMessage != null && c.errorMessage != p.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) AppSnackbar.error(context, state.errorMessage!);
        },
        builder: (context, state) {
          if (state.status == DetailStatus.loading || state.status == DetailStatus.initial) {
            return const LoadingView();
          }
          if (state.status == DetailStatus.error && state.data == null) {
            return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<TicketDetailCubit>().load());
          }
          final data = state.data!;
          final closed = data.status == 'closed';
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(data.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ),
                        StatusBadge(label: Labels.ticketStatus(data.status), status: data.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(AppDateUtils.dateTime(data.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 14),
                    Card(
                      color: AppColors.surface2,
                      child: Padding(padding: const EdgeInsets.all(14), child: Text(data.description)),
                    ),
                    const SizedBox(height: 18),
                    if (isStaff)
                      Row(
                        children: [
                          const Text('Status:', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: data.status,
                            items: const [
                              DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                              DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                              DropdownMenuItem(value: 'closed', child: Text('Closed')),
                            ],
                            onChanged: (v) {
                              if (v != null) context.read<TicketDetailCubit>().updateStatus(v);
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    ...data.replies.map((r) => Align(
                          alignment: r.userId == user?.id ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 300),
                            decoration: BoxDecoration(
                              color: r.userId == user?.id ? AppColors.primaryLight : AppColors.surface2,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(r.message),
                                const SizedBox(height: 4),
                                Text(AppDateUtils.dateTime(r.createdAt),
                                    style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              if (!closed)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgCtrl,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(hintText: 'Type a reply...'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: state.sending
                              ? null
                              : () {
                                  final msg = _msgCtrl.text.trim();
                                  if (msg.isEmpty) return;
                                  context.read<TicketDetailCubit>().reply(msg);
                                  _msgCtrl.clear();
                                },
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
