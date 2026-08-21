import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

import 'app.dart';
import 'services/pocketbase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final Box<String> authBox = await Hive.openBox<String>('pocketbase_auth');
  final AsyncAuthStore authStore = AsyncAuthStore(
    initial: authBox.get('auth'),
    save: (String data) => authBox.put('auth', data),
    clear: () => authBox.delete('auth'),
  );
  runApp(FieldFlowApp(backend: PocketBaseService(authStore: authStore)));
}
