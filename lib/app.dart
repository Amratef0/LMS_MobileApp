import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/loading_view.dart';

import 'features/auth/auth_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_repository.dart';
import 'features/sessions/sessions_repository.dart';
import 'features/groups/groups_repository.dart';
import 'features/students/students_repository.dart';
import 'features/instructors/instructors_repository.dart';
import 'features/coordinators/coordinators_repository.dart';
import 'features/quizzes/quizzes_repository.dart';
import 'features/assignments/assignments_repository.dart';
import 'features/tickets/tickets_repository.dart';
import 'features/reports/reports_repository.dart';
import 'features/shell/main_shell.dart';

/// Root widget: wires up every repository once (all sharing one [ApiClient]
/// / [TokenStorage]), then an [AuthCubit] that decides whether to show the
/// login screen or the role-based [MainShell].
class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TokenStorage>(create: (_) => TokenStorage()),
        RepositoryProvider<ApiClient>(
          create: (ctx) => ApiClient(tokenStorage: ctx.read<TokenStorage>()),
        ),
        RepositoryProvider<AuthRepository>(
          create: (ctx) => AuthRepository(
            apiClient: ctx.read<ApiClient>(),
            tokenStorage: ctx.read<TokenStorage>(),
          ),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (ctx) => DashboardRepository(ctx.read<ApiClient>()),
        ),
        RepositoryProvider<SessionsRepository>(
          create: (ctx) => SessionsRepository(ctx.read<ApiClient>()),
        ),
        RepositoryProvider<GroupsRepository>(
          create: (ctx) => GroupsRepository(ctx.read<ApiClient>()),
        ),
        RepositoryProvider<StudentsRepository>(
          create: (ctx) => StudentsRepository(ctx.read<ApiClient>()),
        ),
        RepositoryProvider<InstructorsRepository>(
          create: (ctx) => InstructorsRepository(ctx.read<ApiClient>()),
        ),
        RepositoryProvider<CoordinatorsRepository>(
          create: (ctx) => CoordinatorsRepository(ctx.read<ApiClient>()),
        ),
        RepositoryProvider<QuizzesRepository>(
          create: (ctx) => QuizzesRepository(ctx.read<ApiClient>()),
        ),
        RepositoryProvider<AssignmentsRepository>(
          create: (ctx) => AssignmentsRepository(ctx.read<ApiClient>()),
        ),
        RepositoryProvider<TicketsRepository>(
          create: (ctx) => TicketsRepository(ctx.read<ApiClient>()),
        ),
        RepositoryProvider<ReportsRepository>(
          create: (ctx) => ReportsRepository(ctx.read<ApiClient>()),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (ctx) => AuthCubit(
          repository: ctx.read<AuthRepository>(),
          apiClient: ctx.read<ApiClient>(),
        )..appStarted(),
        child: MaterialApp(
          title: 'LMS Pro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: child!,
          ),
          home: const _RootRouter(),
        ),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const Scaffold(body: LoadingView());
          case AuthStatus.authenticated:
            return const MainShell();
          case AuthStatus.authenticating:
          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}
