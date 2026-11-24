import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService instance = NotificationService();

  static const String prefEventsKey = 'redepatas_notif_events';
  static const String prefStaleKey = 'redepatas_notif_stale';
  static const String prefCriticalKey = 'redepatas_notif_critical';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxSettings =
          LinuxInitializationSettings(defaultActionName: 'Abrir RedePatas');
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );
      await _plugin.initialize(settings: settings);
      _initialized = true;
    } catch (_) {
      // Ambiente de teste ou plataforma sem suporte
    }
  }

  Future<bool> showReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return false;
    try {
      await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'redepatas_lembretes',
          'Lembretes RedePatas',
          channelDescription: 'Alertas de eventos e pedidos em atendimento',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, bool>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      prefEventsKey: prefs.getBool(prefEventsKey) ?? true,
      prefStaleKey: prefs.getBool(prefStaleKey) ?? true,
      prefCriticalKey: prefs.getBool(prefCriticalKey) ?? true,
    };
  }

  Future<void> setPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
