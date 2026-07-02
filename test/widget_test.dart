import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_test_app/app.dart';
import 'package:new_test_app/models/company_state.dart';
import 'package:new_test_app/repositories/game_repository.dart';
import 'package:new_test_app/services/save_service.dart';

class FakeGameRepository extends GameRepository {
  FakeGameRepository() : super(saveService: SaveService());

  @override
  Future<CompanyState> loadState() async {
    return CompanyState.initial();
  }

  @override
  Future<void> saveState(CompanyState state) async {}
}

void main() {
  testWidgets('Game shell renders dashboard controls', (WidgetTester tester) async {
    await tester.pumpWidget(
      StartupEmpireApp(
        gameRepository: FakeGameRepository(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Startup Empire'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
