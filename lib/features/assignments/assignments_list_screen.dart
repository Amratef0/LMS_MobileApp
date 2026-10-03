import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/pager.dart';
import '../auth/cubit/auth_cubit.dart';
import 'cubit/assignments_list_cubit.dart';
import 'cubit/assignments_list_state.dart';
import 'create_assignment_screen.dart';
import 'assignment_detail_screen.dart';

class AssignmentsListScreen extends StatefulWidget {
  const AssignmentsListScreen({super.key});

  @override
  State<AssignmentsListScreen> createState() => _AssignmentsListScreenState();
}

class _AssignmentsListScreenState extends State<AssignmentsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AssignmentsListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = context.read<AuthCubit>().state.user?.isStaff ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: Column(
        children: [
          SearchField(hint: 'Search assignments...', onChanged: (v) => context.read<AssignmentsListCubit>().search(v)),
          Expanded(
            child: BlocBuilder<AssignmentsListCubit, AssignmentsListState>(
              builder: (context, state) {
                if (state.status == ListStatus.loading && state.items.isEmpty) return const LoadingView();
                if (state.status == ListStatus.error && state.items.isEmpty) {
                  return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<AssignmentsListCubit>().load());
                }
                if (state.items.isEmpty) {
                  return const EmptyState(message: 'No assignments found', icon: Icons.assignment_outlined);
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<AssignmentsListCubit>().load(page: 1),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final a = state.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.warningLight,
                            child: const Icon(Icons.assignment_outlined, color: AppColors.warning),
                          ),
                          title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${a.session?.name ?? ''}\nDue: ${AppDateUtils.dateTime(a.dueDate)}'),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AssignmentDetailScreen(assignmentId: a.id)),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          BlocBuilder<AssignmentsListCubit, AssignmentsListState>(
            builder: (context, state) => Pager(
              page: state.page,
              pageSize: state.pageSize,
              total: state.total,
              onPageChanged: (p) => context.read<AssignmentsListCubit>().load(page: p),
            ),
          ),
        ],
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
                );
                if (created == true && context.mounted) {
                  context.read<AssignmentsListCubit>().load(page: 1);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Assignment'),
            )
          : null,
    );
  }
}
