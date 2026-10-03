import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/pager.dart';
import '../../core/widgets/app_snackbar.dart';
import 'cubit/groups_list_cubit.dart';
import 'cubit/groups_list_state.dart';
import 'cubit/group_detail_cubit.dart';
import 'group_detail_screen.dart';
import 'groups_repository.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GroupsListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: Column(
        children: [
          SearchField(hint: 'Search by group name or code...', onChanged: (v) => context.read<GroupsListCubit>().search(v)),
          Expanded(
            child: BlocBuilder<GroupsListCubit, GroupsListState>(
              builder: (context, state) {
                if (state.status == ListStatus.loading && state.items.isEmpty) return const LoadingView();
                if (state.status == ListStatus.error && state.items.isEmpty) {
                  return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<GroupsListCubit>().load());
                }
                if (state.items.isEmpty) {
                  return const EmptyState(message: 'No groups found', icon: Icons.groups_outlined);
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<GroupsListCubit>().load(page: 1),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final g = state.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Text(g.code.isNotEmpty ? g.code.substring(0, 1) : '?',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ),
                          title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${g.code} • ${g.studentsCount} students\n${AppDateUtils.date(g.startDate)} - ${AppDateUtils.date(g.endDate)}'),
                          isThreeLine: true,
                          trailing: Icon(Icons.circle, size: 10, color: g.isActive ? AppColors.success : AppColors.textMuted),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (ctx) => GroupDetailCubit(ctx.read<GroupsRepository>(), g.id),
                              child: GroupDetailScreen(groupId: g.id),
                            ),
                          )),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          BlocBuilder<GroupsListCubit, GroupsListState>(
            builder: (context, state) => Pager(
              page: state.page,
              pageSize: state.pageSize,
              total: state.total,
              onPageChanged: (p) => context.read<GroupsListCubit>().load(page: p),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime? startDate;
    DateTime? endDate;
    final repo = context.read<GroupsRepository>();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Group'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Group name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Group code'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 730)),
                            );
                            if (picked != null) setDialogState(() => startDate = picked);
                          },
                          child: Text(startDate == null ? 'Start date' : AppDateUtils.date(startDate)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now().add(const Duration(days: 90)),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 730)),
                            );
                            if (picked != null) setDialogState(() => endDate = picked);
                          },
                          child: Text(endDate == null ? 'End date' : AppDateUtils.date(endDate)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await repo.create(
                    name: nameCtrl.text.trim(),
                    code: codeCtrl.text.trim(),
                    startDate: startDate,
                    endDate: endDate,
                  );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    context.read<GroupsListCubit>().load();
                    AppSnackbar.success(context, 'Group added successfully');
                  }
                } catch (_) {
                  if (context.mounted) AppSnackbar.error(context, 'Could not add group');
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
