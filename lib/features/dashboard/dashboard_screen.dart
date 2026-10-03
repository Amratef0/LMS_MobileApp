import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/utils/date_utils.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final user = context.read<AuthCubit>().state.user;
    context.read<DashboardCubit>().load(isStudent: user?.isStudent ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.name.split(' ').first ?? ''} 👋'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading ||
                state.status == DashboardStatus.initial) {
              return const LoadingView();
            }
            if (state.status == DashboardStatus.error) {
              return ErrorView(message: state.errorMessage ?? '', onRetry: _load);
            }
            if (state.status == DashboardStatus.studentReady && state.student != null) {
              return _StudentDashboard(data: state.student!);
            }
            if (state.status == DashboardStatus.staffReady && state.staff != null) {
              return _StaffDashboard(data: state.staff!);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _StudentDashboard extends StatelessWidget {
  const _StudentDashboard({required this.data});
  final dynamic data; // StudentDashboard

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SectionHeader(
          title: 'Performance Report',
          subtitle: 'Track your progress, grades and upcoming deadlines in one place',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _ProgressRing(
                  label: 'Attendance Rate',
                  percent: data.attendanceRate / 100,
                  centerText: '${data.attendanceRate}%',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProgressRing(
                  label: 'Overall Score',
                  percent: data.scorePercentage / 100,
                  centerText: '${data.scorePercentage}%',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              StatCard(
                label: 'Sessions Attended',
                value: '${data.attendanceAttended}/${data.attendanceTotal}',
                icon: Icons.event_available,
                color: AppColors.success,
              ),
              StatCard(
                label: 'Quizzes Taken',
                value: '${data.quizzesTaken}/${data.quizzesTotal}',
                icon: Icons.quiz_outlined,
                color: AppColors.primary,
              ),
              StatCard(
                label: 'Assignments Submitted',
                value: '${data.assignmentsSubmitted}/${data.assignmentsTotal}',
                icon: Icons.assignment_outlined,
                color: AppColors.info,
              ),
              StatCard(
                label: 'Support Tickets',
                value: '${data.ticketsOpen} in progress',
                icon: Icons.support_agent_outlined,
                color: AppColors.warning,
              ),
            ],
          ),
        ),
        if (data.upcomingDeadlines.isNotEmpty) ...[
          const SectionHeader(title: 'Upcoming Deadlines'),
          ...data.upcomingDeadlines.map<Widget>((d) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                d.type == 'quiz' ? Icons.quiz_outlined : Icons.assignment_outlined,
                color: AppColors.primary,
              ),
              title: Text(d.title),
              subtitle: Text(d.sessionName ?? ''),
              trailing: Text(
                AppDateUtils.dueLabel(d.dueDate),
                style: const TextStyle(color: AppColors.warning, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          )),
        ],
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.label,
    required this.percent,
    required this.centerText,
    required this.color,
  });

  final double percent;
  final String label;
  final String centerText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = percent.isNaN ? 0.0 : percent.clamp(0, 1).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                        value: p * 100,
                        color: color,
                        radius: 12,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: 100 - p * 100,
                        color: AppColors.surface2,
                        radius: 12,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Text(centerText,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _StaffDashboard extends StatelessWidget {
  const _StaffDashboard({required this.data});
  final dynamic data; // StaffDashboard

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SectionHeader(title: 'Overview'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              StatCard(
                label: 'Total Students',
                value: '${data.totalStudents}',
                icon: Icons.groups_outlined,
                color: AppColors.primary,
              ),
              StatCard(
                label: 'Quizzes',
                value: '${data.totalQuizzes}',
                icon: Icons.quiz_outlined,
                color: AppColors.info,
              ),
              StatCard(
                label: 'Average Rating',
                value: data.avgRating.toStringAsFixed(2),
                icon: Icons.star_outline,
                color: AppColors.warning,
              ),
              StatCard(
                label: 'Attendance Rate',
                value: '${data.attendanceJoinRate}%',
                icon: Icons.event_available,
                color: AppColors.success,
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Sessions Status'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _MiniStat(label: 'Total', value: data.sessionsTotal, color: AppColors.textMuted),
              _MiniStat(label: 'Finished', value: data.sessionsFinished, color: AppColors.success),
              _MiniStat(label: 'Pending', value: data.sessionsPending, color: AppColors.warning),
              _MiniStat(label: 'Running', value: data.sessionsRunning, color: AppColors.info),
            ],
          ),
        ),
        const SectionHeader(title: 'Assignments'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Submitted ${data.assignmentsSubmitted} of ${data.assignmentsTotal}'),
                  ),
                  Text('${data.assignmentsRate}%',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ),
        const SectionHeader(title: 'Demographics'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _MiniStat(label: 'Male', value: data.genderMale, color: AppColors.primary),
              _MiniStat(label: 'Female', value: data.genderFemale, color: AppColors.danger),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}