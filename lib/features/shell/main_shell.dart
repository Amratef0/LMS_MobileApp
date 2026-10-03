import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/cubit/auth_cubit.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/dashboard_repository.dart';
import '../dashboard/cubit/dashboard_cubit.dart';
import '../sessions/sessions_list_screen.dart';
import '../sessions/sessions_repository.dart';
import '../sessions/cubit/sessions_list_cubit.dart';
import '../quizzes/quizzes_list_screen.dart';
import '../quizzes/quizzes_repository.dart';
import '../quizzes/cubit/quizzes_list_cubit.dart';
import '../assignments/assignments_list_screen.dart';
import '../assignments/assignments_repository.dart';
import '../assignments/cubit/assignments_list_cubit.dart';
import '../groups/groups_list_screen.dart';
import '../groups/groups_repository.dart';
import '../groups/cubit/groups_list_cubit.dart';
import '../students/students_list_screen.dart';
import '../students/students_repository.dart';
import '../students/cubit/students_list_cubit.dart';
import '../instructors/instructors_list_screen.dart';
import '../instructors/instructors_repository.dart';
import '../instructors/cubit/instructors_list_cubit.dart';
import '../coordinators/coordinators_list_screen.dart';
import '../coordinators/coordinators_repository.dart';
import '../coordinators/cubit/coordinators_list_cubit.dart';
import '../tickets/tickets_list_screen.dart';
import '../tickets/tickets_repository.dart';
import '../tickets/cubit/tickets_list_cubit.dart';
import '../reports/reports_screen.dart';
import '../reports/reports_repository.dart';
import '../reports/cubit/reports_cubit.dart';
import '../profile/profile_screen.dart';
import 'app_sidebar.dart';

/// Sidebar-driven shell (replaces the old bottom nav bar). Tabs differ by
/// role, same idea as the Angular app's role-aware sidebar
/// (`AuthService.currentUser.role`).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final isStudent = user?.isStudent ?? true;

    final entries = isStudent
        ? <(NavItem, Widget)>[
            (
              const NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
              const _KeepAlive(child: DashboardTab()),
            ),
            (
              const NavItem(label: 'Sessions', icon: Icons.event_outlined, activeIcon: Icons.event),
              const _KeepAlive(child: SessionsTab()),
            ),
            (
              const NavItem(label: 'Quizzes', icon: Icons.quiz_outlined, activeIcon: Icons.quiz),
              const _KeepAlive(child: QuizzesTab()),
            ),
            (
              const NavItem(label: 'Assignments', icon: Icons.assignment_outlined, activeIcon: Icons.assignment),
              const _KeepAlive(child: AssignmentsTab()),
            ),
            (
              const NavItem(label: 'Support Tickets', icon: Icons.support_agent_outlined, activeIcon: Icons.support_agent),
              const _KeepAlive(child: TicketsTab(isStudent: true)),
            ),
            (
              const NavItem(label: 'Reports', icon: Icons.description_outlined, activeIcon: Icons.description),
              const _KeepAlive(child: ReportsTab()),
            ),
            (
              const NavItem(label: 'My Account', icon: Icons.person_outline, activeIcon: Icons.person),
              const _KeepAlive(child: ProfileScreen()),
            ),
          ]
        : <(NavItem, Widget)>[
            (
              const NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
              const _KeepAlive(child: DashboardTab()),
            ),
            (
              const NavItem(label: 'Sessions', icon: Icons.event_outlined, activeIcon: Icons.event),
              const _KeepAlive(child: SessionsTab()),
            ),
            (
              const NavItem(label: 'Groups', icon: Icons.groups_outlined, activeIcon: Icons.groups),
              const _KeepAlive(child: GroupsTab()),
            ),
            (
              const NavItem(label: 'Students', icon: Icons.groups_2_outlined, activeIcon: Icons.groups_2),
              const _KeepAlive(child: StudentsTab()),
            ),
            (
              const NavItem(label: 'Instructors', icon: Icons.school_outlined, activeIcon: Icons.school),
              const _KeepAlive(child: InstructorsTab()),
            ),
            if (user?.isAdmin ?? false)
              (
                const NavItem(label: 'Coordinators', icon: Icons.badge_outlined, activeIcon: Icons.badge),
                const _KeepAlive(child: CoordinatorsTab()),
              ),
            (
              const NavItem(label: 'Quizzes', icon: Icons.quiz_outlined, activeIcon: Icons.quiz),
              const _KeepAlive(child: QuizzesTab()),
            ),
            (
              const NavItem(label: 'Assignments', icon: Icons.assignment_outlined, activeIcon: Icons.assignment),
              const _KeepAlive(child: AssignmentsTab()),
            ),
            (
              const NavItem(label: 'Support Tickets', icon: Icons.support_agent_outlined, activeIcon: Icons.support_agent),
              const _KeepAlive(child: TicketsTab(isStudent: false)),
            ),
            (
              const NavItem(label: 'Reports', icon: Icons.description_outlined, activeIcon: Icons.description),
              const _KeepAlive(child: ReportsTab()),
            ),
            (
              const NavItem(label: 'My Account', icon: Icons.person_outline, activeIcon: Icons.person),
              const _KeepAlive(child: ProfileScreen()),
            ),
          ];

    if (_index >= entries.length) _index = 0;

    return Scaffold(
      appBar: AppBar(title: Text(entries[_index].$1.label)),
      drawer: AppSidebar(
        items: entries.map((e) => e.$1).toList(),
        selectedIndex: _index,
        onSelect: (i) => setState(() => _index = i),
      ),
      body: IndexedStack(
        index: _index,
        children: entries.map((e) => e.$2).toList(),
      ),
    );
  }
}

/// Keeps each page's scroll position / cubit state alive when switching
/// between sidebar items.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => DashboardCubit(ctx.read<DashboardRepository>()),
        child: const DashboardScreen(),
      );
}

class SessionsTab extends StatelessWidget {
  const SessionsTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => SessionsListCubit(ctx.read<SessionsRepository>()),
        child: const SessionsListScreen(),
      );
}

class QuizzesTab extends StatelessWidget {
  const QuizzesTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => QuizzesListCubit(ctx.read<QuizzesRepository>()),
        child: const QuizzesListScreen(),
      );
}

class AssignmentsTab extends StatelessWidget {
  const AssignmentsTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => AssignmentsListCubit(ctx.read<AssignmentsRepository>()),
        child: const AssignmentsListScreen(),
      );
}

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => GroupsListCubit(ctx.read<GroupsRepository>()),
        child: const GroupsListScreen(),
      );
}

class StudentsTab extends StatelessWidget {
  const StudentsTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => StudentsListCubit(ctx.read<StudentsRepository>()),
        child: const StudentsListScreen(),
      );
}

class InstructorsTab extends StatelessWidget {
  const InstructorsTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => InstructorsListCubit(ctx.read<InstructorsRepository>()),
        child: const InstructorsListScreen(),
      );
}

class TicketsTab extends StatelessWidget {
  const TicketsTab({super.key, required this.isStudent});
  final bool isStudent;
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => TicketsListCubit(ctx.read<TicketsRepository>(), isStudent: isStudent),
        child: const TicketsListScreen(),
      );
}

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => ReportsCubit(
          reportsRepository: ctx.read<ReportsRepository>(),
          groupsRepository: ctx.read<GroupsRepository>(),
        ),
        child: const ReportsScreen(),
      );
}

class CoordinatorsTab extends StatelessWidget {
  const CoordinatorsTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (ctx) => CoordinatorsListCubit(ctx.read<CoordinatorsRepository>()),
        child: const CoordinatorsListScreen(),
      );
}
