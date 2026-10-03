import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/pager.dart';
import '../auth/cubit/auth_cubit.dart';
import 'cubit/tickets_list_cubit.dart';
import 'cubit/tickets_list_state.dart';
import 'cubit/ticket_detail_cubit.dart';
import 'cubit/create_ticket_cubit.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';
import 'tickets_repository.dart';

class TicketsListScreen extends StatefulWidget {
  const TicketsListScreen({super.key});

  @override
  State<TicketsListScreen> createState() => _TicketsListScreenState();
}

class _TicketsListScreenState extends State<TicketsListScreen> {
  static const _statusTabs = [
    (null, 'All'),
    ('in_progress', 'In Progress'),
    ('resolved', 'Resolved'),
    ('closed', 'Closed'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<TicketsListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = context.read<AuthCubit>().state.user?.isStudent ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Support Tickets')),
      body: Column(
        children: [
          SearchField(hint: 'Search tickets...', onChanged: (v) => context.read<TicketsListCubit>().search(v)),
          SizedBox(
            height: 38,
            child: BlocBuilder<TicketsListCubit, TicketsListState>(
              builder: (context, state) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _statusTabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final (value, label) = _statusTabs[i];
                  return ChoiceChip(
                    label: Text(label),
                    selected: state.statusFilter == value,
                    onSelected: (_) => context.read<TicketsListCubit>().filterByStatus(value),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<TicketsListCubit, TicketsListState>(
              builder: (context, state) {
                if (state.status == ListStatus.loading && state.items.isEmpty) return const LoadingView();
                if (state.status == ListStatus.error && state.items.isEmpty) {
                  return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<TicketsListCubit>().load());
                }
                if (state.items.isEmpty) {
                  return const EmptyState(message: 'No tickets found', icon: Icons.support_agent_outlined);
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<TicketsListCubit>().load(page: 1),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final t = state.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${t.student != null ? '${t.student!.name} • ' : ''}${AppDateUtils.dateTime(t.createdAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: StatusBadge(label: Labels.ticketStatus(t.status), status: t.status),
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (ctx) => TicketDetailCubit(ctx.read<TicketsRepository>(), t.id),
                                child: TicketDetailScreen(ticketId: t.id),
                              ),
                            ));
                            if (context.mounted) context.read<TicketsListCubit>().load(page: state.page);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          BlocBuilder<TicketsListCubit, TicketsListState>(
            builder: (context, state) => Pager(
              page: state.page,
              pageSize: state.pageSize,
              total: state.total,
              onPageChanged: (p) => context.read<TicketsListCubit>().load(page: p),
            ),
          ),
        ],
      ),
      floatingActionButton: isStudent
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (ctx) => CreateTicketCubit(ctx.read<TicketsRepository>()),
                    child: const CreateTicketScreen(),
                  ),
                ));
                if (context.mounted) context.read<TicketsListCubit>().load();
              },
              icon: const Icon(Icons.add),
              label: const Text('New Ticket'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}
