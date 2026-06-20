import 'package:nexoraiot/contexts/automations/domain/entities/automation.dart';

abstract class AutomationRepository {
  Future<Automation> createAutomation(Automation draft);
}
