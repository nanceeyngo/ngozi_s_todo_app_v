import 'package:workmanager/workmanager.dart';
import 'notification_callbacks.dart';

class WorkmanagerGuard {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await Workmanager().initialize(notificationCallbackDispatcher);
    _initialized = true;
  }
}