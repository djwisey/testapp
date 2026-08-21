import 'package:flutter_test/flutter_test.dart';
import 'package:emn_plant/providers/business_provider.dart';
import 'package:emn_plant/services/pocketbase_service.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('BusinessProvider authentication', () {
    test(
      'successful login remains authenticated when jobs fail to load',
      () async {
        final _FakePocketBaseService backend = _FakePocketBaseService(
          failJobs: true,
        );
        final BusinessProvider provider = BusinessProvider(backend: backend);

        final bool signedIn = await provider.signInWithCredentials(
          'manager@example.com',
          'correct-password',
        );

        expect(signedIn, isTrue);
        expect(provider.isAuthenticated, isTrue);
        expect(provider.currentUser.roleId, 'manager');
        expect(
          provider.authenticationState,
          AuthenticationState.authenticatedDataError,
        );
        expect(provider.dataLoadErrors, contains('jobs'));
      },
    );

    test(
      'invalid credentials remain unauthenticated with a safe message',
      () async {
        final BusinessProvider provider = BusinessProvider(
          backend: _FakePocketBaseService(invalidLogin: true),
        );

        final bool signedIn = await provider.signInWithCredentials(
          'worker@example.com',
          'wrong-password',
        );

        expect(signedIn, isFalse);
        expect(provider.isAuthenticated, isFalse);
        expect(
          provider.authenticationState,
          AuthenticationState.unauthenticated,
        );
        expect(provider.lastError, 'Incorrect email or password.');
      },
    );

    test('sign out clears authentication and loaded data', () async {
      final _FakePocketBaseService backend = _FakePocketBaseService();
      final BusinessProvider provider = BusinessProvider(backend: backend);
      await provider.signInWithCredentials(
        'manager@example.com',
        'correct-password',
      );

      provider.signOut();

      expect(backend.didSignOut, isTrue);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.authenticationState, AuthenticationState.unauthenticated);
      expect(provider.jobs, isEmpty);
      expect(provider.timesheetEntries, isEmpty);
    });
  });

  test('manual shift subtracts break duration from worked hours', () async {
    final _FakePocketBaseService backend = _FakePocketBaseService();
    final BusinessProvider provider = BusinessProvider(backend: backend);
    final DateTime date = DateTime(2026, 8, 21);

    await provider.addManualEntry(
      date: date,
      startTime: DateTime(2026, 8, 21, 8),
      endTime: DateTime(2026, 8, 21, 17),
      breakHours: 1,
      jobId: 'job-1',
    );

    expect(backend.lastTimesheetBody?['hours'], 8);
    expect(backend.lastTimesheetBody?['break_hours'], 1);
    expect(provider.timesheetEntries.single.quantityHours, 8);
  });
}

class _FakePocketBaseService extends PocketBaseService {
  _FakePocketBaseService({this.failJobs = false, this.invalidLogin = false});

  final bool failJobs;
  final bool invalidLogin;
  bool didSignOut = false;
  Map<String, dynamic>? lastTimesheetBody;

  @override
  Future<RecordModel> signIn(String email, String password) async {
    if (invalidLogin) {
      throw ClientException(
        statusCode: 400,
        response: const <String, dynamic>{'message': 'Failed to authenticate.'},
      );
    }
    return RecordModel(<String, dynamic>{
      'id': 'manager-1',
      'name': 'Test Manager',
      'email': email,
      'role': 'manager',
      'active': true,
    });
  }

  @override
  Future<List<RecordModel>> getJobs() async {
    if (failJobs) throw StateError('jobs unavailable');
    return <RecordModel>[];
  }

  @override
  Future<List<RecordModel>> getTimesheets() async => <RecordModel>[];

  @override
  Future<List<RecordModel>> getUsers() async => <RecordModel>[];

  @override
  Future<RecordModel> createTimesheet(Map<String, dynamic> body) async {
    lastTimesheetBody = body;
    return RecordModel(<String, dynamic>{
      'id': 'timesheet-1',
      ...body,
      'created': DateTime.now().toUtc().toIso8601String(),
      'updated': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  void signOut() {
    didSignOut = true;
  }
}
