import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/repositories/commission_repository.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_periods_screen.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/commission_settings_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCommissionRepository extends Mock implements CommissionRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// Widget-test harness for the commissions screens (spec 078): a mocktail
/// [CommissionRepository], a session user holding SystemObject 112
/// (`commissionsBySalesPerson`) at a chosen right, and a router with the
/// commissions routes.
///
/// A test stubs [repo] before [pump]. [extraRoutes] go in front of the
/// commissions routes.
class CommissionHarness {
  final repo = MockCommissionRepository();

  /// The last [pump]'s providers, for reading the formatters in a test.
  late ProviderContainer container;

  /// The session user. [commissions] is the raw SystemObject 112 right
  /// (15 = create, read, update and delete; 2 = read only; 0 = none).
  static User user({
    int commissions = 15,
    bool administrator = false,
    int? facilityId = 2,
  }) => User(
    userId: 'clerk',
    email: 'clerk@example.com',
    administrator: administrator,
    status: EntityStatus.active,
    sessionVersion: 1,
    privileges: [
      if (commissions != 0)
        Privilege(
          systemObject: SystemObject.commissionsBySalesPerson,
          rawValue: commissions,
        ),
    ],
  );

  /// A user who may only read.
  static User readOnlyUser() => user(commissions: 2);

  /// Pumps the app at [location] on a wide surface. [namesFail] makes every
  /// employee-name lookup fail (the `#id` fallback). [settle] false leaves
  /// the first frames unsettled, to see a loading state.
  Future<GoRouter> pump(
    WidgetTester tester, {
    User? who,
    String location = commissionsPath,
    Size surface = const Size(1400, 1000),
    bool namesFail = false,
    bool settle = true,
    List<RouteBase> extraRoutes = const [],
    List<Override> extraOverrides = const [],
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: who ?? user()),
          ),
        ),
        commissionRepositoryProvider.overrideWithValue(repo),
        employeeDisplayNameProvider.overrideWith(
          (ref, id) async => namesFail ? null : 'Empleado $id',
        ),
        ...extraOverrides,
      ],
    );
    addTearDown(container.dispose);
    await container.read(authProvider.future);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        ...extraRoutes,
        GoRoute(
          path: commissionsPath,
          builder: (_, _) => const Scaffold(body: CommissionPeriodsScreen()),
        ),
        // Declared before the month route, as in the app.
        commissionSettingsRoute(),
        commissionMonthRoute(),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
    return router;
  }
}

Finder key(String k) => find.byKey(Key(k));

/// A coded refusal carrying English server text that must never be shown.
AppError aRefusal(
  api.ErrorCode code,
  String codeName, [
  Map<String, Object?> params = const {},
]) => AppError.validation(
  [],
  'SERVER TEXT',
  ApiProblem(
    codeName: codeName,
    code: code,
    params: params,
    detail: 'SERVER TEXT',
  ),
);
