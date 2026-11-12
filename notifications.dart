part of 'main.dart';

// ═════════════ Notifications ═════════════
@pragma('vm:entry-point')
Future<void> notifBg(NotificationResponse r) async => handleNotifAction(r);

Future<void> handleNotifAction(NotificationResponse r) async {
  try {
    final pl = r.payload ?? '';
    if (r.actionId == 'prayed' && pl.startsWith('trk|')) {
      final parts = pl.split('|');
      final i = int.parse(parts[1]);
      final k = parts[2];
      final sp = await SharedPreferences.getInstance();
      await sp.reload();
      final cur = (sp.getString('trk_$k') ?? '00000').split('');
      cur[i] = '1';
      await sp.setString('trk_$k', cur.join());
    }
    if (r.id != null && (r.actionId == 'prayed' || r.actionId == 'later' || r.actionId == 'stop')) {
      await Notif.p.cancel(r.id!);
    }
  } catch (_) {}
}

class Notif {
  static final p = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    await p.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: handleNotifAction,
      onDidReceiveBackgroundNotificationResponse: notifBg,
    );
  }

  static AndroidFlutterLocalNotificationsPlugin? get _a =>
      p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  static Future<void> ask() async {
    await _a?.requestNotificationsPermission();
  }

  static Future<bool> enabled() async => (await _a?.areNotificationsEnabled()) ?? true;

  static const _stop = AndroidNotificationAction('stop', 'বন্ধ করুন', cancelNotification: true, showsUserInterface: false);

  static AndroidNotificationSound _alarmSound() =>
      kAzan ? const RawResourceAndroidNotificationSound('azan') : const UriAndroidNotificationSound('content://settings/system/alarm_alert');

  // আজান: স্পর্শ করলে বা সোয়াইপ করলে বন্ধ হয় না, শুধু "বন্ধ করুন" বাটনে বন্ধ হবে (৫ মিনিট পর নিজে সরে যাবে)
  static NotificationDetails azanDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          kAzan ? 'azan_v3' : 'azan_alarm_v3',
          'আজান',
          channelDescription: 'নামাজের ওয়াক্তে আজান',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: _alarmSound(),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ongoing: true,
          autoCancel: false,
          timeoutAfter: 300000,
          additionalFlags: kAzan ? null : Int32List.fromList(<int>[4]),
          actions: const [_stop],
        ),
      );

  static NotificationDetails customDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_alarm_v3',
          'আমার অ্যালার্ম',
          channelDescription: 'আপনার সেট করা অ্যালার্ম',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          ongoing: true,
          autoCancel: false,
          timeoutAfter: 300000,
          additionalFlags: Int32List.fromList(<int>[4]),
          actions: const [_stop],
        ),
      );

  static NotificationDetails prayedDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'remind_v3',
          'নামাজ রিমাইন্ডার',
          channelDescription: 'নামাজ পড়েছেন কিনা জানতে চাওয়া',
          importance: Importance.high,
          priority: Priority.high,
          actions: [
            AndroidNotificationAction('prayed', 'হ্যাঁ, পড়েছি', cancelNotification: true, showsUserInterface: false),
            AndroidNotificationAction('later', 'পরে', cancelNotification: true, showsUserInterface: false),
          ],
        ),
      );

  static Future<bool> _at(int id, String title, String body, DateTime when, NotificationDetails d, {String? payload}) async {
    final z = tz.TZDateTime.from(when, tz.UTC);
    for (final mode in [AndroidScheduleMode.alarmClock, AndroidScheduleMode.exactAllowWhileIdle, AndroidScheduleMode.inexactAllowWhileIdle]) {
      try {
        await p.zonedSchedule(id, title, body, z, d,
            payload: payload,
            androidScheduleMode: mode,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
        return true;
      } catch (_) {}
    }
    return false;
  }

  static Future<void> schedule(AppState s) async {
    await p.cancelAll();
    final now = DateTime.now();
    final base = dOnly(now);
    for (var d = 0; d < 10; d++) {
      final day = base.add(Duration(days: d));
      final t = timesFor(day, s);
      for (var i = 0; i < 5; i++) {
        if (s.on[i] && t.five[i].isAfter(now)) {
          await _at(100 + d * 10 + i, 'আজান - ${prayers[i]}', '${prayers[i]} নামাজের ওয়াক্ত হয়েছে', t.five[i], azanDetails());
        }
        if (s.remind && s.name.isNotEmpty) {
          final w = t.five[i].add(const Duration(minutes: 15));
          if (w.isAfter(now)) {
            await _at(6000 + d * 10 + i, 'নামাজের খোঁজ', '${s.addr}, ${prayers[i]} নামাজ পড়েছেন তো?', w, prayedDetails(),
                payload: 'trk|$i|${dateKey(day)}');
          }
        }
      }
      for (var c = 0; c < s.customs.length; c++) {
        final a = s.customs[c];
        if (a['on'] != true) continue;
        final w = DateTime(day.year, day.month, day.day, a['h'] as int, a['m'] as int);
        if (w.isAfter(now)) await _at(8000 + c * 10 + d, '${a['l']}', 'আপনার অ্যালার্ম', w, customDetails());
      }
    }
  }

  static Future<bool> test() => _at(9999, 'আজান পরীক্ষা', 'এটি একটি পরীক্ষামূলক আজান', DateTime.now().add(const Duration(seconds: 10)), azanDetails());
}
