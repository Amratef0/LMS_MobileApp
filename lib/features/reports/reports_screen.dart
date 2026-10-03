import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/app_snackbar.dart';
import '../auth/cubit/auth_cubit.dart';
import '../../models/group_model.dart';
import 'cubit/reports_cubit.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  GroupListItem? _selectedGroup;

  @override
  void initState() {
    super.initState();
    final isStudent = context.read<AuthCubit>().state.user?.isStudent ?? false;
    if (!isStudent) context.read<ReportsCubit>().loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = context.read<AuthCubit>().state.user?.isStudent ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: BlocConsumer<ReportsCubit, ReportsState>(
        listener: (context, state) {
          if (state.errorMessage != null) AppSnackbar.error(context, state.errorMessage!);
        },
        builder: (context, state) {
          if (isStudent) return _studentView(context, state);
          return _staffView(context, state);
        },
      ),
    );
  }

  Widget _studentView(BuildContext context, ReportsState state) {
    final busy = state.status == ReportsStatus.downloading;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_outlined, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Your progress report', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              'A PDF with your attendance, grades and quiz/assignment history.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: busy ? null : () => context.read<ReportsCubit>().myProgress(),
              icon: busy
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download_outlined),
              label: Text(busy ? 'Preparing...' : 'Download my report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staffView(BuildContext context, ReportsState state) {
    if (state.status == ReportsStatus.loadingGroups) return const LoadingView();
    if (state.status == ReportsStatus.error && state.groups.isEmpty) {
      return ErrorView(message: state.errorMessage ?? '', onRetry: () => context.read<ReportsCubit>().loadGroups());
    }
    final busy = state.status == ReportsStatus.downloading;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Group Reports', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text(
          'Pick a group, then download the report you need. Files open in your PDF/Excel viewer or you can share them.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<GroupListItem>(
          value: _selectedGroup,
          decoration: const InputDecoration(labelText: 'Group'),
          items: state.groups
              .map((g) => DropdownMenuItem(value: g, child: Text('${g.name} (${g.code})')))
              .toList(),
          onChanged: (v) => setState(() => _selectedGroup = v),
        ),
        const SizedBox(height: 20),
        _ReportTile(
          icon: Icons.event_available_outlined,
          title: 'Attendance Report',
          subtitle: 'Per-session attendance for every student (.xlsx)',
          busy: busy,
          onTap: _selectedGroup == null
              ? null
              : () => context.read<ReportsCubit>().attendance(_selectedGroup!.id, _selectedGroup!.name),
        ),
        _ReportTile(
          icon: Icons.grade_outlined,
          title: 'Grades Report',
          subtitle: 'Quiz and assignment scores for every student (.xlsx)',
          busy: busy,
          onTap: _selectedGroup == null
              ? null
              : () => context.read<ReportsCubit>().grades(_selectedGroup!.id, _selectedGroup!.name),
        ),
        _ReportTile(
          icon: Icons.summarize_outlined,
          title: 'Group Summary Report',
          subtitle: 'Overall stats + per-student attendance rate (.xlsx)',
          busy: busy,
          onTap: _selectedGroup == null
              ? null
              : () => context.read<ReportsCubit>().summary(_selectedGroup!.id, _selectedGroup!.name),
        ),
        if (_selectedGroup == null)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Choose a group above to enable the reports.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
      ],
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.busy,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.download_outlined),
        onTap: busy ? null : onTap,
      ),
    );
  }
}
