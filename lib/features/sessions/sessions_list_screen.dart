import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/pager.dart';
import '../auth/cubit/auth_cubit.dart';
import 'cubit/sessions_list_cubit.dart';
import 'cubit/sessions_list_state.dart';
import 'create_session_screen.dart';
import 'session_detail_screen.dart';
import 'widgets/session_card.dart';

class SessionsListScreen extends StatefulWidget {
  const SessionsListScreen({super.key});

  @override
  State<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> {
  static const _statusTabs = [
    (null, 'All'),
    ('pending', 'Pending'),
    ('running', 'Running'),
    ('finished', 'Finished'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<SessionsListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = context.read<AuthCubit>().state.user?.isStaff ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: Column(
        children: [
          SearchField(
            hint: 'Search by session name or group code...',
            onChanged: (v) => context.read<SessionsListCubit>().search(v),
          ),
          SizedBox(
            height: 38,
            child: BlocBuilder<SessionsListCubit, SessionsListState>(
              builder: (context, state) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statusTabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final (value, label) = _statusTabs[i];
                    final selected = state.statusFilter == value;
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) =>
                          context.read<SessionsListCubit>().filterByStatus(value),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<SessionsListCubit, SessionsListState>(
              builder: (context, state) {
                if (state.status == ListStatus.loading && state.items.isEmpty) {
                  return const LoadingView();
                }
                if (state.status == ListStatus.error && state.items.isEmpty) {
                  return ErrorView(
                    message: state.errorMessage ?? '',
                    onRetry: () => context.read<SessionsListCubit>().load(),
                  );
                }
                if (state.items.isEmpty) {
                  return const EmptyState(message: 'No sessions found', icon: Icons.event_busy_outlined);
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<SessionsListCubit>().load(page: 1),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    itemBuilder: (context, i) {
                      final session = state.items[i];
                      return SessionCard(
                        session: session,
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SessionDetailScreen(sessionId: session.id),
                          ));
                          if (context.mounted) {
                            context.read<SessionsListCubit>().load(page: state.page);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          BlocBuilder<SessionsListCubit, SessionsListState>(
            builder: (context, state) => Pager(
              page: state.page,
              pageSize: state.pageSize,
              total: state.total,
              onPageChanged: (p) => context.read<SessionsListCubit>().load(page: p),
            ),
          ),
        ],
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
                );
                if (created == true && context.mounted) {
                  context.read<SessionsListCubit>().load(page: 1);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Session'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}
