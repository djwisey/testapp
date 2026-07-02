import '../models/company_state.dart';
import '../services/save_service.dart';

class GameRepository {
  GameRepository({required this.saveService});

  final SaveService saveService;

  Future<CompanyState> loadState() async {
    final Map<dynamic, dynamic>? savedState = await saveService.loadState();
    if (savedState == null) {
      return CompanyState.initial();
    }
    return CompanyState.fromMap(savedState);
  }

  Future<void> saveState(CompanyState state) {
    return saveService.saveState(state.toMap());
  }
}
