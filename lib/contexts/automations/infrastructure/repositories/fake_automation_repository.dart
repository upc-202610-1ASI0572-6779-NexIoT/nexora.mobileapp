import 'package:nexoraiot/contexts/automations/domain/entities/automation.dart';
import 'package:nexoraiot/contexts/automations/domain/repositories/automation_repository.dart';
import 'package:nexoraiot/contexts/properties/infrastructure/datasources/fake_nexora_api.dart';

class FakeAutomationRepository implements AutomationRepository {
  final FakeNexoraApi _api;

  FakeAutomationRepository({
    FakeNexoraApi? api,
  }) : _api = api ?? FakeNexoraApi();

  @override
  Future<Automation> createAutomation(Automation draft) {
    return _api.createAutomation(draft);
  }
}
