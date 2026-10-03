import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/group_model.dart';
import '../auth/cubit/auth_cubit.dart';
import '../coordinators/coordinators_repository.dart';
import 'cubit/group_detail_cubit.dart';
import 'groups_repository.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});
  final int groupId;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GroupDetailCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthCubit>().state.user?.isAdmin ?? false;
    final isStaff = context.read<AuthCubit>().state.user?.isStaff ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Group Details')),
      body: BlocBuilder<GroupDetailCubit, GroupDetailState>(
        builder: (context, state) {
          if (state.status == DetailStatus.loading || state.status == DetailStatus.initial) {
            return const LoadingView();
          }
          if (state.status == DetailStatus.error && state.group == null) {
            return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<GroupDetailCubit>().load());
          }
          final g = state.group!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(g.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${g.code} • ${AppDateUtils.date(g.startDate)} - ${AppDateUtils.date(g.endDate)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Coordinators (${g.coordinators.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (isAdmin)
                    TextButton.icon(
                      onPressed: () => _showAssignCoordinatorDialog(context, g),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Assign'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (g.coordinators.isEmpty)
                const Text('No coordinators assigned', style: TextStyle(color: AppColors.textMuted))
              else
                ...g.coordinators.map((c) => Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                        title: Text(c.name),
                        subtitle: c.email != null ? Text(c.email!) : null,
                        trailing: isAdmin
                            ? IconButton(
                                icon: const Icon(Icons.close, color: AppColors.danger, size: 18),
                                tooltip: 'Remove',
                                onPressed: () => _removeCoordinator(context, g.id, c.id),
                              )
                            : null,
                        dense: true,
                      ),
                    )),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Teams (${g.teams.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (isStaff)
                    TextButton.icon(
                      onPressed: g.students.isEmpty ? null : () => _showCreateTeamDialog(context, g),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New team'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (g.teams.isEmpty)
                const Text('No teams yet', style: TextStyle(color: AppColors.textMuted))
              else
                ...g.teams.map((t) => Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: const Icon(Icons.diversity_3_outlined, color: AppColors.info),
                        title: Text(t.name),
                        trailing: Text('${t.studentsCount} students', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        dense: true,
                      ),
                    )),
              const SizedBox(height: 20),
              Text('Students (${g.students.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (g.students.isEmpty)
                const Text('No students in this group', style: TextStyle(color: AppColors.textMuted))
              else
                ...g.students.map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person_outline, size: 18)),
                        title: Text(s.name),
                        subtitle: Text(s.email ?? ''),
                        trailing: s.studentCode != null ? Text(s.studentCode!, style: const TextStyle(fontSize: 11)) : null,
                        dense: true,
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeCoordinator(BuildContext context, int groupId, int coordinatorId) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Remove Coordinator',
      message: 'Remove this coordinator from the group?',
      confirmLabel: 'Remove',
      danger: true,
    );
    if (!confirm) return;
    try {
      await context.read<GroupsRepository>().removeCoordinator(groupId, coordinatorId);
      if (context.mounted) {
        context.read<GroupDetailCubit>().load();
        AppSnackbar.success(context, 'Coordinator removed');
      }
    } catch (_) {
      if (context.mounted) AppSnackbar.error(context, 'Could not remove coordinator');
    }
  }

  void _showAssignCoordinatorDialog(BuildContext context, GroupDetail group) {
    final coordinatorsRepo = context.read<CoordinatorsRepository>();
    final groupsRepo = context.read<GroupsRepository>();
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder(
        future: coordinatorsRepo.list(pageSize: 200),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return const AlertDialog(content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())));
          }
          final available = snapshot.data!.items
              .where((c) => !group.coordinators.any((gc) => gc.id == c.id))
              .toList();
          if (available.isEmpty) {
            return AlertDialog(
              title: const Text('Assign Coordinator'),
              content: const Text('All coordinators are already assigned to this group, or none exist yet.'),
              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
            );
          }
          int selectedId = available.first.id;
          return StatefulBuilder(
            builder: (ctx, setDialogState) => AlertDialog(
              title: const Text('Assign Coordinator'),
              content: DropdownButtonFormField<int>(
                value: selectedId,
                items: available.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setDialogState(() => selectedId = v ?? selectedId),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    try {
                      await groupsRepo.assignCoordinator(group.id, selectedId);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (context.mounted) {
                        context.read<GroupDetailCubit>().load();
                        AppSnackbar.success(context, 'Coordinator assigned');
                      }
                    } catch (_) {
                      if (context.mounted) AppSnackbar.error(context, 'Could not assign coordinator');
                    }
                  },
                  child: const Text('Assign'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context, GroupDetail group) {
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? teamLeadId;
    final selectedStudents = <int>{};
    final repo = context.read<GroupsRepository>();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Team'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Team name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    value: teamLeadId,
                    decoration: const InputDecoration(labelText: 'Team lead (optional)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('— None —')),
                      ...group.students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                    ],
                    onChanged: (v) => setDialogState(() => teamLeadId = v),
                  ),
                  const SizedBox(height: 12),
                  const Text('Members', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  SizedBox(
                    height: 220,
                    width: 320,
                    child: ListView(
                      shrinkWrap: true,
                      children: group.students
                          .map((s) => CheckboxListTile(
                                dense: true,
                                title: Text(s.name),
                                value: selectedStudents.contains(s.id),
                                onChanged: (checked) => setDialogState(() {
                                  if (checked == true) {
                                    selectedStudents.add(s.id);
                                  } else {
                                    selectedStudents.remove(s.id);
                                  }
                                }),
                              ))
                          .toList(),
                    ),
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
                  await repo.createTeam(
                    group.id,
                    name: nameCtrl.text.trim(),
                    teamLeadId: teamLeadId,
                    studentIds: selectedStudents.toList(),
                  );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    context.read<GroupDetailCubit>().load();
                    AppSnackbar.success(context, 'Team created successfully');
                  }
                } catch (_) {
                  if (context.mounted) AppSnackbar.error(context, 'Could not create team');
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
