import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  PocketBaseService({PocketBase? client, AuthStore? authStore})
    : client =
          client ??
          PocketBase('https://emnapi.dylanwiseman.com', authStore: authStore);

  final PocketBase client;

  bool get isAuthenticated => client.authStore.isValid;

  RecordModel? get authenticatedRecord => client.authStore.record;

  Future<RecordModel> signIn(String email, String password) async {
    final auth = await client
        .collection('users')
        .authWithPassword(email.trim().toLowerCase(), password);
    final RecordModel record = auth.record;
    if (!record.getBoolValue('active', true)) {
      client.authStore.clear();
      throw StateError('This account has been disabled.');
    }
    return record;
  }

  void signOut() => client.authStore.clear();

  Future<List<RecordModel>> getUsers() =>
      client.collection('users').getFullList(sort: 'name');

  Future<RecordModel> createWorker({
    required String name,
    required String email,
    required String password,
    String jobTitle = '',
  }) {
    return client
        .collection('users')
        .create(
          body: <String, dynamic>{
            'name': name.trim(),
            'email': email.trim().toLowerCase(),
            'emailVisibility': false,
            'password': password,
            'passwordConfirm': password,
            'role': 'employee',
            'active': true,
            'job_title': jobTitle.trim(),
          },
        );
  }

  Future<RecordModel> updateWorker({
    required String id,
    required String name,
    required String email,
    required bool active,
    String jobTitle = '',
  }) {
    return client
        .collection('users')
        .update(
          id,
          body: <String, dynamic>{
            'name': name.trim(),
            'email': email.trim().toLowerCase(),
            'active': active,
            'job_title': jobTitle.trim(),
          },
        );
  }

  Future<void> resetWorkerPassword(String id, String password) async {
    await client
        .collection('users')
        .update(
          id,
          body: <String, dynamic>{
            'password': password,
            'passwordConfirm': password,
          },
        );
  }

  Future<void> deleteWorker(String id) => client.collection('users').delete(id);

  Future<List<RecordModel>> getJobs() =>
      client.collection('jobs').getFullList(sort: '-scheduled_date,reference');

  Future<RecordModel> createJob(Map<String, dynamic> body) =>
      client.collection('jobs').create(body: body);

  Future<RecordModel> updateJob(String id, Map<String, dynamic> body) =>
      client.collection('jobs').update(id, body: body);

  Future<void> deleteJob(String id) => client.collection('jobs').delete(id);

  // Sort locally after parsing. Keeping the list request schema-neutral avoids
  // PocketBase rejecting the entire request when a production collection has
  // an older/mismatched sortable-field definition.
  Future<List<RecordModel>> getTimesheets() =>
      client.collection('timesheets').getFullList();

  Future<RecordModel> createTimesheet(Map<String, dynamic> body) =>
      client.collection('timesheets').create(body: body);

  Future<RecordModel> updateTimesheet(String id, Map<String, dynamic> body) =>
      client.collection('timesheets').update(id, body: body);
}
