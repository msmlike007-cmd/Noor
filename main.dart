import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

// ═════════════ Constants ═════════════
const kApp = 'নূরনামা';
const kAzan = bool.fromEnvironment('AZAN');
const green = Color(0xFF0B3D2E);
const green2 = Color(0xFF14604A);
const gold = Color(0xFFD4AF37);
const cream = Color(0xFFFFF8E7);
const linkFb = 'https://www.facebook.com/share/1E6ypLt8tZ/';
const linkIg = 'https://www.instagram.com/md.masum366';
const linkTg = 'https://t.me/MasumNoornama';

const prayers = ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'এশা'];
const prayerIcons = [Icons.wb_twilight, Icons.wb_sunny, Icons.wb_sunny_outlined, Icons.nightlight_round, Icons.bedtime];
const bnMonths = ['বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন', 'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র'];
const hijriBn = ['মুহাররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জমাদিউল আউয়াল', 'জমাদিউস সানি', 'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ'];
const hijriAr = ['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];
const enMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const wdBn = ['রবিবার', 'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার'];

class Dist {
  final String n;
  final double la, lo;
  const Dist(this.n, this.la, this.lo);
}

const dists = [
  Dist('ঢাকা', 23.81, 90.41), Dist('গাজীপুর', 23.99, 90.42), Dist('নারায়ণগঞ্জ', 23.63, 90.50), Dist('নরসিংদী', 23.92, 90.72),
  Dist('মানিকগঞ্জ', 23.86, 90.00), Dist('মুন্সিগঞ্জ', 23.55, 90.53), Dist('টাঙ্গাইল', 24.25, 89.92), Dist('কিশোরগঞ্জ', 24.43, 90.78),
  Dist('ফরিদপুর', 23.61, 89.84), Dist('রাজবাড়ী', 23.76, 89.64), Dist('গোপালগঞ্জ', 23.01, 89.83), Dist('মাদারীপুর', 23.17, 90.20),
  Dist('শরীয়তপুর', 23.22, 90.35), Dist('চট্টগ্রাম', 22.36, 91.78), Dist('কক্সবাজার', 21.43, 92.01), Dist('কুমিল্লা', 23.46, 91.18),
  Dist('ব্রাহ্মণবাড়িয়া', 23.96, 91.11), Dist('চাঁদপুর', 23.23, 90.66), Dist('ফেনী', 23.02, 91.40), Dist('লক্ষ্মীপুর', 22.94, 90.84),
  Dist('নোয়াখালী', 22.82, 91.10), Dist('খাগড়াছড়ি', 23.12, 91.98), Dist('রাঙামাটি', 22.65, 92.17), Dist('বান্দরবান', 22.20, 92.22),
  Dist('সিলেট', 24.90, 91.87), Dist('মৌলভীবাজার', 24.48, 91.77), Dist('হবিগঞ্জ', 24.37, 91.42), Dist('সুনামগঞ্জ', 25.07, 91.40),
  Dist('রাজশাহী', 24.37, 88.60), Dist('বগুড়া', 24.85, 89.37), Dist('পাবনা', 24.00, 89.23), Dist('সিরাজগঞ্জ', 24.45, 89.70),
  Dist('নাটোর', 24.42, 89.00), Dist('নওগাঁ', 24.80, 88.94), Dist('চাঁপাইনবাবগঞ্জ', 24.60, 88.28), Dist('জয়পুরহাট', 25.10, 89.02),
  Dist('খুলনা', 22.82, 89.55), Dist('যশোর', 23.17, 89.21), Dist('সাতক্ষীরা', 22.72, 89.07), Dist('বাগেরহাট', 22.65, 89.79),
  Dist('নড়াইল', 23.17, 89.50), Dist('মাগুরা', 23.49, 89.42), Dist('ঝিনাইদহ', 23.54, 89.17), Dist('কুষ্টিয়া', 23.90, 89.12),
  Dist('চুয়াডাঙ্গা', 23.64, 88.84), Dist('মেহেরপুর', 23.76, 88.63), Dist('বরিশাল', 22.70, 90.37), Dist('ভোলা', 22.69, 90.65),
  Dist('পটুয়াখালী', 22.36, 90.33), Dist('পিরোজপুর', 22.58, 89.97), Dist('ঝালকাঠি', 22.64, 90.20), Dist('বরগুনা', 22.15, 90.12),
  Dist('রংপুর', 25.75, 89.25), Dist('দিনাজপুর', 25.63, 88.64), Dist('কুড়িগ্রাম', 25.81, 89.64), Dist('গাইবান্ধা', 25.33, 89.53),
  Dist('নীলফামারী', 25.93, 88.86), Dist('লালমনিরহাট', 25.99, 89.45), Dist('ঠাকুরগাঁও', 26.03, 88.46), Dist('পঞ্চগড়', 26.34, 88.55),
  Dist('ময়মনসিংহ', 24.75, 90.41), Dist('জামালপুর', 24.92, 89.94), Dist('শেরপুর', 25.02, 90.02), Dist('নেত্রকোণা', 24.87, 90.73),
];

bool inBdAt(double la, double lo) => la >= 20.5 && la <= 26.7 && lo >= 88.0 && lo <= 92.8;

Dist nearest(double la, double lo) {
  var best = dists.first;
  var bd = double.infinity;
  for (final d in dists) {
    final x = (d.la - la) * (d.la - la) + (d.lo - lo) * (d.lo - lo);
    if (x < bd) {
      bd = x;
      best = d;
    }
  }
  return best;
}

// ═════════════ Helpers ═════════════
String digits(Object o, String set) => o.toString().split('').map((c) {
      final i = '0123456789'.indexOf(c);
      return i < 0 ? c : set[i];
    }).join();
String bn(Object o) => digits(o, '০১২৩৪৫৬৭৮৯');
String ar(Object o) => digits(o, '٠١٢٣٤٥٦٧٨٩');

DateTime now0() => DateTime.now();
DateTime dOnly(DateTime t) => DateTime(t.year, t.month, t.day);
bool leap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
String dateKey(DateTime d) => '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
int daysBetween(DateTime a, DateTime b) => DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

Color cardC(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF1B2B25) : Colors.white;
Color mute(BuildContext c) => Theme.of(c).colorScheme.onSurface.withOpacity(.65);
Color pri(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF7BD8B0) : green;

class BnDate {
  final int y, m, d;
  BnDate(this.y, this.m, this.d);
}

/// বাংলাদেশের সংশোধিত বাংলা সন (১৪ এপ্রিল = ১ বৈশাখ)
BnDate toBangla(DateTime g) {
  final day = DateTime.utc(g.year, g.month, g.day);
  var gy = g.year;
  var start = DateTime.utc(gy, 4, 14);
  if (day.isBefore(start)) {
    gy--;
    start = DateTime.utc(gy, 4, 14);
  }
  var diff = day.difference(start).inDays;
  final lens = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, leap(gy + 1) ? 30 : 29, 30];
  var m = 0;
  while (m < 11 && diff >= lens[m]) {
    diff -= lens[m];
    m++;
  }
  return BnDate(gy - 593, m, diff + 1);
}

HijriCalendar hijri(DateTime g, int adj) => HijriCalendar.fromDate(dOnly(g).add(Duration(days: adj)));
DateTime hijriToG(int y, int m, int d, int adj) {
  final x = HijriCalendar.now().hijriToGregorian(y, m, d);
  return DateTime(x.year, x.month, x.day).subtract(Duration(days: adj));
}

String enStr(DateTime g) => '${g.day} ${enMonths[g.month - 1]} ${g.year}';
String bnStr(DateTime g) {
  final b = toBangla(g);
  return '${bn(b.d)} ${bnMonths[b.m]} ${bn(b.y)} বঙ্গাব্দ';
}

String hiBn(DateTime g, int adj) {
  final h = hijri(g, adj);
  return '${bn(h.hDay)} ${hijriBn[h.hMonth - 1]} ${bn(h.hYear)} হিজরি';
}

String hiAr(DateTime g, int adj) {
  final h = hijri(g, adj);
  return '${ar(h.hDay)} ${hijriAr[h.hMonth - 1]} ${ar(h.hYear)} هـ';
}

String fmt(DateTime t) {
  final b = t.toLocal();
  final h = b.hour;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  final p = h < 4 ? 'রাত' : h < 6 ? 'ভোর' : h < 12 ? 'সকাল' : h < 15 ? 'দুপুর' : h < 17 ? 'বিকাল' : h < 19 ? 'সন্ধ্যা' : 'রাত';
  return '${bn(h12)}:${bn(b.minute.toString().padLeft(2, '0'))} $p';
}

class Day {
  final List<DateTime> five; // ফজর, যোহর, আসর, মাগরিব, এশা
  final DateTime sunrise, nextFajr;
  Day(this.five, this.sunrise, this.nextFajr);
  DateTime get fajr => five[0];
  DateTime get sunset => five[3];
  DateTime endOf(int i) => i == 0 ? sunrise : i == 1 ? five[2] : i == 2 ? five[3] : i == 3 ? five[4] : nextFajr;
}

Day timesFor(DateTime d, AppState s) {
  final t = PrayerTimes(s.c, DateComponents.from(d), s.params());
  final n = PrayerTimes(s.c, DateComponents.from(d.add(const Duration(days: 1))), s.params());
  DateTime l(DateTime x) => x.toLocal();
  return Day([l(t.fajr), l(t.dhuhr), l(t.asr), l(t.maghrib), l(t.isha)], l(t.sunrise), l(n.fajr));
}

Future<void> openUrl(String u) async {
  try {
    await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
  } catch (_) {}
}

void openPage(BuildContext ctx, String title, Widget page) =>
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: Text(title)), body: SafeArea(child: page))));

// ═════════════ Quran data (alquran.cloud, cached on phone) ═════════════
class QS {
  final List<String> ar, bn;
  QS(this.ar, this.bn);
}

class Api {
  static const base = 'https://api.alquran.cloud/v1';

  static Future<dynamic> _json(String url, String cache) async {
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/$cache');
    if (await f.exists()) {
      try {
        return jsonDecode(await f.readAsString());
      } catch (_) {}
    }
    final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 40));
    if (r.statusCode != 200) throw Exception('http ${r.statusCode}');
    final body = utf8.decode(r.bodyBytes);
    final j = jsonDecode(body);
    if (j['code'] != 200) throw Exception('api');
    await f.writeAsString(body);
    return j;
  }

  static Future<List<dynamic>> surahList() async => (await _json('$base/surah', 'surahs.json'))['data'] as List;

  static QS _pack(List data, {bool single = false}) {
    var a = <String>[], b = <String>[];
    for (final e in data) {
      final id = e['edition']['identifier'];
      final list = e['ayahs'] != null ? (e['ayahs'] as List).map((x) => x['text'] as String).toList() : [e['text'] as String];
      if (id == 'quran-uthmani') {
        a = list;
      } else {
        b = list;
      }
    }
    return QS(a, b);
  }

  static Future<QS> surah(int n) async {
    final j = await _json('$base/surah/$n/editions/quran-uthmani,bn.bengali', 's$n.json');
    return _pack(j['data'] as List);
  }

  static Future<QS> ayah(String ref) async {
    final j = await _json('$base/ayah/$ref/editions/quran-uthmani,bn.bengali', 'a_${ref.replaceAll(':', '_')}.json');
    return _pack(j['data'] as List);
  }
}

// ═════════════ Notifications ═════════════
class Notif {
  static final p = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    await p.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
  }

  static AndroidFlutterLocalNotificationsPlugin? get _a =>
      p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  static Future<void> ask() async {
    await _a?.requestNotificationsPermission();
  }

  static Future<bool> enabled() async => (await _a?.areNotificationsEnabled()) ?? true;

  static NotificationDetails azanDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          kAzan ? 'azan_v2' : 'azan_alarm_v2',
          'আজান',
          channelDescription: 'নামাজের ওয়াক্তে আজান',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: kAzan
              ? const RawResourceAndroidNotificationSound('azan')
              : const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
        ),
      );

  static NotificationDetails remindDetails() => const NotificationDetails(
        android: AndroidNotificationDetails('remind_v2', 'রিমাইন্ডার',
            channelDescription: 'নামাজের রিমাইন্ডার', importance: Importance.high, priority: Priority.high),
      );

  static Future<bool> _at(int id, String title, String body, DateTime when, NotificationDetails d) async {
    final z = tz.TZDateTime.from(when, tz.UTC);
    for (final mode in [AndroidScheduleMode.alarmClock, AndroidScheduleMode.exactAllowWhileIdle, AndroidScheduleMode.inexactAllowWhileIdle]) {
      try {
        await p.zonedSchedule(id, title, body, z, d,
            androidScheduleMode: mode, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
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
      final t = timesFor(base.add(Duration(days: d)), s);
      for (var i = 0; i < 5; i++) {
        if (s.on[i] && t.five[i].isAfter(now)) {
          await _at(100 + d * 10 + i, 'আজান - ${prayers[i]}', '${prayers[i]} নামাজের ওয়াক্ত হয়েছে', t.five[i], azanDetails());
        }
      }
      if (s.remind && s.name.isNotEmpty) {
        final w = t.fajr.add(const Duration(minutes: 20));
        if (w.isAfter(now)) await _at(5000 + d, 'নামাজ', '${s.addr}, আপনি আজকে নামাজ পড়েছেন তো?', w, remindDetails());
      }
    }
  }

  static Future<bool> test() => _at(9999, 'আজান পরীক্ষা', 'এটি একটি পরীক্ষামূলক আজান', DateTime.now().add(const Duration(seconds: 10)), azanDetails());
}

// ═════════════ State ═════════════
class AppState extends ChangeNotifier {
  double lat = 23.81, lon = 90.41;
  String place = 'ঢাকা';
  List<bool> on = List.filled(5, true);
  int adj = 0, themeMode = 0;
  bool hanafi = true, remind = true, loaded = false;
  String method = 'auto', name = '', title = 'ভাই', note = '', lastPopup = '';
  double arSize = 26;
  late SharedPreferences sp;

  Coordinates get c => Coordinates(lat, lon);
  String get addr => title.isEmpty ? name : '$name $title';

  CalculationParameters params() {
    CalculationMethod m;
    switch (method) {
      case 'karachi':
        m = CalculationMethod.karachi;
        break;
      case 'mwl':
        m = CalculationMethod.muslim_world_league;
        break;
      case 'umm':
        m = CalculationMethod.umm_al_qura;
        break;
      case 'egypt':
        m = CalculationMethod.egyptian;
        break;
      default:
        m = inBdAt(lat, lon) ? CalculationMethod.karachi : CalculationMethod.muslim_world_league;
    }
    final p = m.getParameters();
    p.madhab = hanafi ? Madhab.hanafi : Madhab.shafi;
    return p;
  }

  Future<void> load() async {
    sp = await SharedPreferences.getInstance();
    adj = sp.getInt('adj') ?? 0;
    themeMode = sp.getInt('theme') ?? 0;
    hanafi = sp.getBool('hanafi') ?? true;
    remind = sp.getBool('remind') ?? true;
    method = sp.getString('method') ?? 'auto';
    name = sp.getString('name') ?? '';
    title = sp.getString('title') ?? 'ভাই';
    lastPopup = sp.getString('popup') ?? '';
    arSize = sp.getDouble('arSize') ?? 26;
    final s = sp.getString('on');
    if (s != null && s.length == 5) on = s.split('').map((e) => e == '1').toList();
    if (sp.containsKey('lat')) {
      lat = sp.getDouble('lat')!;
      lon = sp.getDouble('lon')!;
      place = sp.getString('place') ?? place;
    }
    loaded = true;
    notifyListeners();
    if (!sp.containsKey('lat')) await gps();
  }

  Future<String> _label(double la, double lo) async {
    try {
      try {
        await setLocaleIdentifier('bn_BD');
      } catch (_) {}
      final pm = await placemarkFromCoordinates(la, lo);
      if (pm.isNotEmpty) {
        final p = pm.first;
        final parts = <String>[];
        for (final x in [p.subLocality, p.locality, p.subAdministrativeArea]) {
          final v = x?.trim() ?? '';
          if (v.isNotEmpty && !parts.contains(v)) parts.add(v);
        }
        final cn = p.country?.trim() ?? '';
        if (cn.isNotEmpty && !inBdAt(la, lo)) parts.add(cn);
        if (parts.isNotEmpty) return parts.take(3).join(', ');
      }
    } catch (_) {}
    if (inBdAt(la, lo)) return nearest(la, lo).n;
    return '${la.toStringAsFixed(2)}, ${lo.toStringAsFixed(2)}';
  }

  Future<void> gps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        note = 'ফোনের লোকেশন (GPS) চালু করুন';
        notifyListeners();
        return;
      }
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
        note = 'লোকেশনের অনুমতি দিন, অথবা সেটিংসে জেলা বেছে নিন';
        notifyListeners();
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 25));
      note = '';
      await setLoc(pos.latitude, pos.longitude, await _label(pos.latitude, pos.longitude));
    } catch (_) {
      note = 'লোকেশন পাওয়া যায়নি, সেটিংসে জেলা বেছে নিন';
      notifyListeners();
    }
  }

  Future<void> setLoc(double la, double lo, String nm) async {
    lat = la;
    lon = lo;
    place = nm;
    await sp.setDouble('lat', la);
    await sp.setDouble('lon', lo);
    await sp.setString('place', nm);
    notifyListeners();
    await resched();
  }

  Future<void> resched() => Notif.schedule(this);

  Future<void> toggle(int i) async {
    on[i] = !on[i];
    await sp.setString('on', on.map((e) => e ? '1' : '0').join());
    notifyListeners();
    await resched();
  }

  Future<void> setAdj(int v) async {
    adj = v.clamp(-2, 2);
    await sp.setInt('adj', adj);
    notifyListeners();
  }

  Future<void> setName(String n, String t) async {
    name = n;
    title = t;
    await sp.setString('name', n);
    await sp.setString('title', t);
    notifyListeners();
    await resched();
  }

  Future<void> setTheme(int v) async {
    themeMode = v;
    await sp.setInt('theme', v);
    notifyListeners();
  }

  Future<void> setHanafi(bool v) async {
    hanafi = v;
    await sp.setBool('hanafi', v);
    notifyListeners();
    await resched();
  }

  Future<void> setMethod(String v) async {
    method = v;
    await sp.setString('method', v);
    notifyListeners();
    await resched();
  }

  Future<void> setRemind(bool v) async {
    remind = v;
    await sp.setBool('remind', v);
    notifyListeners();
    await resched();
  }

  Future<void> setPopup(String k) async {
    lastPopup = k;
    await sp.setString('popup', k);
  }

  Future<void> setArSize(double v) async {
    arSize = v.clamp(18, 44);
    await sp.setDouble('arSize', arSize);
    notifyListeners();
  }

  List<bool> trk(DateTime d) => (sp.getString('trk_${dateKey(d)}') ?? '00000').split('').map((e) => e == '1').toList();

  Future<void> setTrk(DateTime d, int i, bool v) async {
    final l = trk(d);
    l[i] = v;
    await sp.setString('trk_${dateKey(d)}', l.map((e) => e ? '1' : '0').join());
    notifyListeners();
  }
}

// ═════════════ App ═════════════
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notif.init();
  final s = AppState();
  runApp(App(s));
  s.load();
}

ThemeData mkTheme(Brightness b) {
  final d = b == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: b, secondary: gold),
    scaffoldBackgroundColor: d ? const Color(0xFF0D1713) : cream,
  );
}

class App extends StatelessWidget {
  final AppState s;
  const App(this.s, {super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: kApp,
          theme: mkTheme(Brightness.light),
          darkTheme: mkTheme(Brightness.dark),
          themeMode: [ThemeMode.system, ThemeMode.light, ThemeMode.dark][s.themeMode],
          home: Shell(s),
        ),
      );
}

Future<void> askName(BuildContext ctx, AppState s) async {
  final c = TextEditingController(text: s.name);
  var t = s.name.isEmpty ? 'ভাই' : s.title;
  await showDialog(
    context: ctx,
    barrierDismissible: s.name.isNotEmpty,
    builder: (_) => StatefulBuilder(
      builder: (ctx2, set) => AlertDialog(
        title: const Text('আপনার নাম লিখুন'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: c, decoration: const InputDecoration(hintText: 'যেমন: মাসুম')),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            for (final x in ['ভাই', 'আপু', 'কিছু না'])
              ChoiceChip(
                label: Text(x),
                selected: x == 'কিছু না' ? t == '' : t == x,
                onSelected: (_) => set(() => t = x == 'কিছু না' ? '' : x),
              ),
          ]),
        ]),
        actions: [
          FilledButton(
            onPressed: () {
              if (c.text.trim().isEmpty) return;
              s.setName(c.text.trim(), t);
              Navigator.pop(ctx2);
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    ),
  );
}

Future<void> prayPopup(BuildContext ctx, AppState s) => showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(s.addr),
        content: const Text('আপনি আজকে নামাজ পড়েছেন তো?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('পরে')),
          FilledButton(
            onPressed: () {
              Navigator.pop(c);
              openPage(ctx, 'নামাজ ট্র্যাকার', TrackerPage(s));
            },
            child: const Text('ট্র্যাকারে দেখুন'),
          ),
        ],
      ),
    );

class Shell extends StatefulWidget {
  final AppState s;
  const Shell(this.s, {super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  bool _boot = false;

  @override
  void initState() {
    super.initState();
    widget.s.addListener(_maybeBoot);
    _maybeBoot();
  }

  @override
  void dispose() {
    widget.s.removeListener(_maybeBoot);
    super.dispose();
  }

  void _maybeBoot() {
    if (_boot || !widget.s.loaded) return;
    _boot = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final s = widget.s;
    if (!mounted) return;
    if (s.name.isEmpty) await askName(context, s);
    await Notif.ask();
    await s.resched();
    if (!mounted) return;
    final en = await Notif.enabled();
    final k = dateKey(now0());
    if (!en && s.lastPopup != k) {
      await s.setPopup(k);
      if (mounted) await prayPopup(context, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return ListenableBuilder(
      listenable: s,
      builder: (_, __) => Scaffold(
        body: SafeArea(child: IndexedStack(index: i, children: [HomePage(s), CalPage(s), QuranListPage(s), MorePage(s)])),
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: (v) => setState(() => i = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.access_time), label: 'নামাজ'),
            NavigationDestination(icon: Icon(Icons.calendar_month), label: 'ক্যালেন্ডার'),
            NavigationDestination(icon: Icon(Icons.menu_book), label: 'কুরআন'),
            NavigationDestination(icon: Icon(Icons.apps), label: 'আরও'),
          ],
        ),
      ),
    );
  }
}

// ═════════════ Logo ═════════════
class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 48});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _LogoPainter()));
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size z) {
    final s = z.width;
    c.drawCircle(Offset(s / 2, s / 2), s / 2,
        Paint()..shader = const RadialGradient(colors: [green2, green]).createShader(Rect.fromLTWH(0, 0, s, s)));
    final g = Paint()..color = gold;
    final a = Path()..addOval(Rect.fromCircle(center: Offset(.5 * s, .36 * s), radius: .22 * s));
    final b = Path()..addOval(Rect.fromCircle(center: Offset(.57 * s, .32 * s), radius: .19 * s));
    c.drawPath(Path.combine(PathOperation.difference, a, b), g);
    final d = Path()
      ..moveTo(.30 * s, .80 * s)
      ..quadraticBezierTo(.30 * s, .62 * s, .5 * s, .60 * s)
      ..quadraticBezierTo(.70 * s, .62 * s, .70 * s, .80 * s)
      ..close();
    c.drawPath(d, g);
    c.drawRect(Rect.fromLTRB(.28 * s, .80 * s, .72 * s, .84 * s), g);
    final st = Path();
    for (var i = 0; i < 10; i++) {
      final r = (i % 2 == 0 ? .05 : .02) * s;
      final ang = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(.60 * s + r * math.cos(ang), .30 * s + r * math.sin(ang));
      i == 0 ? st.moveTo(p.dx, p.dy) : st.lineTo(p.dx, p.dy);
    }
    c.drawPath(st..close(), g);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═════════════ Home ═════════════
class HomePage extends StatefulWidget {
  final AppState s;
  const HomePage(this.s, {super.key});
  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  Widget chip(BuildContext ctx, IconData i, String a, String b) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(color: cardC(ctx), borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Icon(i, size: 20, color: gold),
            const SizedBox(height: 3),
            Text(a, style: TextStyle(fontSize: 11, color: mute(ctx))),
            Text(b, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final now = DateTime.now();
    final today = dOnly(now);
    final tt = timesFor(today, s);
    DateTime? nx;
    var ni = 0;
    for (var i = 0; i < 5; i++) {
      if (tt.five[i].isAfter(now)) {
        nx = tt.five[i];
        ni = i;
        break;
      }
    }
    nx ??= tt.nextFajr;
    final left = nx.difference(now);
    String two(int n) => bn(n.toString().padLeft(2, '0'));
    final cd = '${two(left.inHours)}:${two(left.inMinutes % 60)}:${two(left.inSeconds % 60)}';
    const w = TextStyle(color: Colors.white);
    const w7 = TextStyle(color: Colors.white70, fontSize: 14);

    return ListView(padding: const EdgeInsets.all(12), children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [green, green2]), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Logo(size: 44),
            const SizedBox(width: 10),
            const Text(kApp, style: TextStyle(color: gold, fontSize: 26, fontWeight: FontWeight.w700)),
            const Spacer(),
            const Icon(Icons.location_on, color: gold, size: 16),
            Flexible(child: Text(s.place, style: w, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 12),
          Text('${wdBn[today.weekday % 7]}, ${enStr(today)}', style: w.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(bnStr(today), style: w7),
          Text(hiBn(today, s.adj), style: w7),
          Text(hiAr(today, s.adj), style: w7, textDirection: TextDirection.rtl),
        ]),
      ),
      if (s.note.isNotEmpty) Card(color: Colors.orange.shade100, child: Padding(padding: const EdgeInsets.all(12), child: Text(s.note, style: const TextStyle(color: Colors.black87)))),
      const SizedBox(height: 10),
      Row(children: [
        chip(context, Icons.wb_twilight, 'সূর্যোদয়', fmt(tt.sunrise)),
        chip(context, Icons.wb_sunny, 'সূর্যাস্ত', fmt(tt.sunset)),
        chip(context, Icons.free_breakfast, 'সেহরি শেষ', fmt(tt.fajr)),
        chip(context, Icons.restaurant, 'ইফতার', fmt(tt.five[3])),
      ]),
      Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(children: [
              Text('পরবর্তী ওয়াক্ত: ${prayers[ni]}', style: const TextStyle(fontSize: 16)),
              Text(fmt(nx), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: pri(context))),
              const SizedBox(height: 4),
              Text(cd, style: const TextStyle(fontSize: 22, color: gold, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
      Card(
        child: Column(children: [
          for (var i = 0; i < 5; i++)
            ListTile(
              tileColor: i == ni ? gold.withOpacity(.15) : null,
              leading: Icon(prayerIcons[i], color: pri(context)),
              title: Text(prayers[i], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              subtitle: Text('শুরু ${fmt(tt.five[i])}  •  শেষ ${fmt(tt.endOf(i))}'),
              trailing: IconButton(
                tooltip: 'আজান অ্যালার্ম',
                icon: Icon(s.on[i] ? Icons.notifications_active : Icons.notifications_off, color: s.on[i] ? pri(context) : Colors.grey),
                onPressed: () => s.toggle(i),
              ),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Text('গণনা: ${s.method == 'auto' ? (inBdAt(s.lat, s.lon) ? 'করাচি' : 'মুসলিম ওয়ার্ল্ড লীগ') : s.method} পদ্ধতি, ${s.hanafi ? 'হানাফি' : 'শাফেয়ি'} আসর। স্থানীয় ক্যালেন্ডারের সাথে ১-২ মিনিট পার্থক্য হতে পারে।',
            style: TextStyle(fontSize: 12, color: mute(context))),
      ),
    ]);
  }
}

// ═════════════ Calendar ═════════════
class CalPage extends StatefulWidget {
  final AppState s;
  const CalPage(this.s, {super.key});
  @override
  State<CalPage> createState() => _CalState();
}

class _CalState extends State<CalPage> {
  late DateTime month = DateTime(now0().year, now0().month, 1);
  late DateTime sel = dOnly(now0());
  void go(int d) => setState(() => month = DateTime(month.year, month.month + d, 1));

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final today = dOnly(now0());
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final last = DateTime(month.year, month.month, days);
    final lead = month.weekday % 7;
    final b1 = toBangla(month), b2 = toBangla(last);
    final h1 = hijri(month, s.adj), h2 = hijri(last, s.adj);
    final bnR = b1.m == b2.m ? bnMonths[b1.m] : '${bnMonths[b1.m]} – ${bnMonths[b2.m]}';
    final hiR = h1.hMonth == h2.hMonth ? hijriBn[h1.hMonth - 1] : '${hijriBn[h1.hMonth - 1]} – ${hijriBn[h2.hMonth - 1]}';
    final arR = h1.hMonth == h2.hMonth ? hijriAr[h1.hMonth - 1] : '${hijriAr[h1.hMonth - 1]} – ${hijriAr[h2.hMonth - 1]}';
    final p = pri(context);

    Widget cell(int d) {
      final g = DateTime(month.year, month.month, d);
      final isT = g == today, isS = g == sel, fri = g.weekday == 5;
      final h = hijri(g, s.adj);
      return InkWell(
        onTap: () => setState(() => sel = g),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: isS ? green2 : isT ? gold.withOpacity(.35) : cardC(context), borderRadius: BorderRadius.circular(10)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$d', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: isS ? Colors.white : fri ? Colors.red.shade400 : null)),
            Text(bn(toBangla(g).d), style: TextStyle(fontSize: 11, color: isS ? Colors.white70 : p)),
            Text(bn(h.hDay), style: TextStyle(fontSize: 11, color: isS ? gold : Colors.amber.shade700)),
          ]),
        ),
      );
    }

    final tt = timesFor(sel, s);
    return ListView(padding: const EdgeInsets.all(12), children: [
      Row(children: [
        IconButton(onPressed: () => go(-1), icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Column(children: [
            Text('${enMonths[month.month - 1]} ${month.year}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text('বাংলা: $bnR ${bn(b1.y)}', style: TextStyle(color: p)),
            Text('হিজরি: $hiR ${bn(h1.hYear)}', style: TextStyle(color: Colors.amber.shade700)),
            Text('$arR ${ar(h1.hYear)}', style: TextStyle(color: Colors.amber.shade700), textDirection: TextDirection.rtl),
          ]),
        ),
        IconButton(onPressed: () => go(1), icon: const Icon(Icons.chevron_right)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        for (final d in ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি'])
          Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)))),
      ]),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: .72,
        children: [for (var i = 0; i < lead; i++) const SizedBox(), for (var d = 1; d <= days; d++) cell(d)],
      ),
      Text('  বড়: ইংরেজি • সবুজ: বাংলা • সোনালি: হিজরি', style: TextStyle(fontSize: 11, color: mute(context))),
      Card(
        margin: const EdgeInsets.only(top: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${wdBn[sel.weekday % 7]}, ${enStr(sel)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text(bnStr(sel)),
            Text(hiBn(sel, s.adj)),
            Text(hiAr(sel, s.adj), textDirection: TextDirection.rtl),
            const Divider(),
            for (var i = 0; i < 5; i++) Text('${prayers[i]}: ${fmt(tt.five[i])} – ${fmt(tt.endOf(i))}'),
            Text('সূর্যোদয়: ${fmt(tt.sunrise)}'),
          ]),
        ),
      ),
    ]);
  }
}

// ═════════════ More menu ═════════════
class MorePage extends StatelessWidget {
  final AppState s;
  const MorePage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final items = <List<Object>>[
      [Icons.nights_stay, 'রমজান সূচি', () => openPage(context, 'রমজান সূচি', RamPage(s))],
      [Icons.event, 'ইসলামি দিবস', () => openPage(context, 'গুরুত্বপূর্ণ ইসলামি দিন', DaysPage(s))],
      [Icons.explore, 'কিবলা', () => openPage(context, 'কিবলা কম্পাস', QiblaPage(s))],
      [Icons.touch_app, 'তসবিহ', () => openPage(context, 'তসবিহ', TasbihPage(s))],
      [Icons.checklist, 'নামাজ ট্র্যাকার', () => openPage(context, 'নামাজ ট্র্যাকার', TrackerPage(s))],
      [Icons.favorite, 'দোয়া', () => openPage(context, 'কুরআনের দোয়া', DuaPage(s))],
      [Icons.shield, 'রুকইয়াহ', () => openPage(context, 'রুকইয়াহ', RuqyahPage(s))],
      [Icons.settings, 'সেটিংস', () => openPage(context, 'সেটিংস', SetPage(s))],
      [Icons.info, 'অ্যাবাউট', () => openPage(context, 'অ্যাবাউট', AboutPage(s))],
    ];
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(12),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        for (final it in items)
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: it[2] as VoidCallback,
            child: Container(
              decoration: BoxDecoration(color: cardC(context), borderRadius: BorderRadius.circular(18)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(it[0] as IconData, size: 34, color: pri(context)),
                const SizedBox(height: 8),
                Text(it[1] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
      ],
    );
  }
}

// ═════════════ Ramadan ═════════════
class RamPage extends StatelessWidget {
  final AppState s;
  const RamPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final today = dOnly(now0());
    var hy = hijri(today, s.adj).hYear;
    var st = hijriToG(hy, 9, 1, s.adj), en = hijriToG(hy, 10, 1, s.adj);
    if (!today.isBefore(en)) {
      hy++;
      st = hijriToG(hy, 9, 1, s.adj);
      en = hijriToG(hy, 10, 1, s.adj);
    }
    final n = daysBetween(st, en);
    final toStart = daysBetween(today, st);
    const hd = TextStyle(fontWeight: FontWeight.w700);

    return ListView(padding: const EdgeInsets.all(12), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [green, green2]), borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          Text('রমজান ${bn(hy)} হিজরি', style: const TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('প্রথম রোজা: ${bn(st.day)} ${enMonths[st.month - 1]} ${bn(st.year)} (${wdBn[st.weekday % 7]})', style: const TextStyle(color: Colors.white)),
          Text(toStart > 0 ? 'আর ${bn(toStart)} দিন বাকি' : 'রমজান চলছে', style: const TextStyle(color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(children: [
          SizedBox(width: 44, child: Text('রোজা', style: hd)),
          Expanded(flex: 3, child: Text('তারিখ', style: hd)),
          Expanded(flex: 2, child: Text('সেহরি শেষ', style: hd)),
          Expanded(flex: 2, child: Text('ইফতার', style: hd)),
        ]),
      ),
      for (var i = 0; i < n; i++)
        Builder(builder: (_) {
          final d = st.add(Duration(days: i));
          final t = timesFor(d, s);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(color: d == today ? gold.withOpacity(.3) : cardC(context), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              SizedBox(width: 44, child: Text(bn(i + 1), style: hd)),
              Expanded(flex: 3, child: Text('${wdBn[d.weekday % 7]}\n${d.day} ${enMonths[d.month - 1].substring(0, 3)}', style: const TextStyle(fontSize: 12))),
              Expanded(flex: 2, child: Text(fmt(t.fajr), style: const TextStyle(fontSize: 13))),
              Expanded(flex: 2, child: Text(fmt(t.five[3]), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
            ]),
          );
        }),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Text('চাঁদ দেখা সাপেক্ষে তারিখ ১ দিন আগে-পরে হতে পারে। সেটিংসে হিজরি তারিখ সমন্বয় করা যায়।', style: TextStyle(fontSize: 12, color: mute(context))),
      ),
    ]);
  }
}

// ═════════════ Important Islamic days ═════════════
class Ev {
  final int m, d;
  final String n;
  const Ev(this.m, this.d, this.n);
}

const evs = [
  Ev(1, 1, 'ইসলামি নববর্ষ'),
  Ev(1, 10, 'আশুরা'),
  Ev(3, 12, '১২ রবিউল আউয়াল (সরকারি ছুটি)'),
  Ev(7, 27, 'শবে মিরাজ'),
  Ev(8, 15, 'শবে বরাত'),
  Ev(9, 1, 'রমজানের প্রথম রোজা'),
  Ev(9, 27, 'শবে কদর (২৭ রমজানের রাত)'),
  Ev(10, 1, 'ঈদুল ফিতর'),
  Ev(12, 9, 'আরাফার দিন'),
  Ev(12, 10, 'ঈদুল আযহা'),
];

class DaysPage extends StatelessWidget {
  final AppState s;
  const DaysPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final today = dOnly(now0());
    final hy = hijri(today, s.adj).hYear;
    final out = <MapEntry<DateTime, Ev>>[];
    for (final y in [hy, hy + 1]) {
      for (final e in evs) {
        final g = hijriToG(y, e.m, e.d, s.adj);
        if (!g.isBefore(today)) out.add(MapEntry(g, e));
      }
    }
    out.sort((a, b) => a.key.compareTo(b.key));
    return ListView(padding: const EdgeInsets.all(12), children: [
      for (final x in out.take(14))
        Card(
          child: ListTile(
            leading: Icon(Icons.event_available, color: pri(context)),
            title: Text(x.value.n, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${bn(x.value.d)} ${hijriBn[x.value.m - 1]} • ${enStr(x.key)}\n${wdBn[x.key.weekday % 7]}'),
            isThreeLine: true,
            trailing: Text(x.key == today ? 'আজ' : '${bn(daysBetween(today, x.key))} দিন', style: const TextStyle(fontWeight: FontWeight.w700, color: gold)),
          ),
        ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Text('চাঁদ দেখা সাপেক্ষে ১-২ দিন পার্থক্য হতে পারে। শবে বরাত ও শবে মিরাজ পালনের ব্যাপারে আলেমদের মতভেদ আছে; এখানে বাংলাদেশে প্রচলিত তারিখ দেখানো হয়েছে।',
            style: TextStyle(fontSize: 12, color: mute(context))),
      ),
    ]);
  }
}

// ═════════════ Qibla ═════════════
double qiblaBearing(double lat, double lon) {
  const kLat = 21.4225, kLon = 39.8262;
  final p1 = lat * math.pi / 180, p2 = kLat * math.pi / 180, dl = (kLon - lon) * math.pi / 180;
  final y = math.sin(dl) * math.cos(p2);
  final x = math.cos(p1) * math.sin(p2) - math.sin(p1) * math.cos(p2) * math.cos(dl);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

class _CompassPainter extends CustomPainter {
  final double heading, qibla;
  final Color ink;
  _CompassPainter(this.heading, this.qibla, this.ink);

  void label(Canvas c, String t, Offset o, Color col) {
    final tp = TextPainter(text: TextSpan(text: t, style: TextStyle(color: col, fontWeight: FontWeight.w700, fontSize: 18)), textDirection: TextDirection.ltr)..layout();
    tp.paint(c, o - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas c, Size size) {
    final r = size.width / 2;
    c.save();
    c.translate(r, r);
    c.rotate(-heading * math.pi / 180);
    c.drawCircle(Offset.zero, r - 4, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = green2);
    const names = ['N', 'E', 'S', 'W'];
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      label(c, names[i], Offset(math.sin(a), -math.cos(a)) * (r - 26), i == 0 ? Colors.red : ink);
    }
    final qa = qibla * math.pi / 180;
    final end = Offset(math.sin(qa), -math.cos(qa)) * (r - 46);
    c.drawLine(Offset.zero, end, Paint()..color = gold..strokeWidth = 6..strokeCap = StrokeCap.round);
    c.drawCircle(end, 17, Paint()..color = gold);
    c.drawRect(Rect.fromCenter(center: end, width: 14, height: 14), Paint()..color = Colors.black87);
    c.drawCircle(Offset.zero, 7, Paint()..color = gold);
    c.restore();
    c.drawPath(Path()..moveTo(r - 11, 0)..lineTo(r + 11, 0)..lineTo(r, 20)..close(), Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter o) => o.heading != heading || o.qibla != qibla;
}

class QiblaPage extends StatelessWidget {
  final AppState s;
  const QiblaPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final q = qiblaBearing(s.lat, s.lon);
    final stream = FlutterCompass.events;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Center(child: Text('কিবলার দিক: ${bn(q.toStringAsFixed(1))}° (উত্তর থেকে ঘড়ির কাঁটার দিকে)', style: const TextStyle(fontSize: 15))),
      const SizedBox(height: 16),
      if (stream == null)
        const Center(child: Text('এই ফোনে কম্পাস সেন্সর পাওয়া যায়নি।'))
      else
        StreamBuilder<CompassEvent>(
          stream: stream,
          builder: (ctx, snap) {
            final h = snap.data?.heading;
            if (h == null) return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
            final diff = ((q - h + 540) % 360) - 180;
            final ok = diff.abs() < 4;
            return Column(children: [
              SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(painter: _CompassPainter(h, q, Theme.of(ctx).colorScheme.onSurface)),
              ),
              const SizedBox(height: 14),
              Text(ok ? 'কিবলা সামনে ✓' : 'ফোন ঘুরান, সোনালি কাবা-চিহ্ন ওপরের লাল তীরের দিকে আনুন',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ok ? Colors.green : null)),
            ]);
          },
        ),
      const SizedBox(height: 16),
      Text('ফোন সমতলে ধরুন এবং ধাতব বস্তু বা চুম্বক থেকে দূরে রাখুন। দিক ভুল মনে হলে ফোনটি ৮ (আট) আকারে ঘুরিয়ে কম্পাস ক্যালিব্রেট করুন। কিবলার কোণ আপনার লোকেশন থেকে হিসাব করা।',
          style: TextStyle(fontSize: 12, color: mute(context))),
    ]);
  }
}

// ═════════════ Tasbih ═════════════
class TasbihPage extends StatefulWidget {
  final AppState s;
  const TasbihPage(this.s, {super.key});
  @override
  State<TasbihPage> createState() => _TasbihState();
}

class _TasbihState extends State<TasbihPage> {
  int count = 0, target = 33;
  String dhikr = 'সুবহানাল্লাহ';

  @override
  void initState() {
    super.initState();
    count = widget.s.sp.getInt('tasbih') ?? 0;
  }

  void tap() {
    setState(() => count++);
    widget.s.sp.setInt('tasbih', count);
    if (target > 0 && count % target == 0) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [
        for (final d in ['সুবহানাল্লাহ', 'আলহামদুলিল্লাহ', 'আল্লাহু আকবার', 'লা ইলাহা ইল্লাল্লাহ', 'আস্তাগফিরুল্লাহ'])
          ChoiceChip(label: Text(d), selected: dhikr == d, onSelected: (_) => setState(() => dhikr = d)),
      ]),
      const SizedBox(height: 10),
      Wrap(spacing: 8, alignment: WrapAlignment.center, children: [
        for (final t in [33, 99, 100, 0])
          ChoiceChip(label: Text(t == 0 ? 'সীমাহীন' : bn(t)), selected: target == t, onSelected: (_) => setState(() => target = t)),
      ]),
      const SizedBox(height: 24),
      Center(child: Text(dhikr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: gold))),
      const SizedBox(height: 14),
      Center(
        child: GestureDetector(
          onTap: tap,
          child: Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [green2, green], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(bn(count), style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w700)),
                if (target > 0) Text('/ ${bn(target)}', style: const TextStyle(color: gold, fontSize: 18)),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Center(
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() => count = 0);
            widget.s.sp.setInt('tasbih', 0);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('শূন্য করুন'),
        ),
      ),
    ]);
  }
}

// ═════════════ Prayer tracker ═════════════
class TrackerPage extends StatelessWidget {
  final AppState s;
  const TrackerPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (_, __) {
        final today = dOnly(now0());
        final t = s.trk(today);
        final done = t.where((e) => e).length;
        return ListView(padding: const EdgeInsets.all(12), children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('আজ: ${bn(done)}/${bn(5)} ওয়াক্ত', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: done / 5, minHeight: 8),
                for (var i = 0; i < 5; i++)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(prayers[i]),
                    value: t[i],
                    onChanged: (v) => s.setTrk(today, i, v ?? false),
                  ),
              ]),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                const Align(alignment: Alignment.centerLeft, child: Text('গত ৭ দিন', style: TextStyle(fontWeight: FontWeight.w700))),
                const SizedBox(height: 8),
                for (var k = 0; k < 7; k++)
                  Builder(builder: (_) {
                    final d = today.subtract(Duration(days: k));
                    final x = s.trk(d);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        SizedBox(width: 90, child: Text(k == 0 ? 'আজ' : wdBn[d.weekday % 7], style: const TextStyle(fontSize: 13))),
                        for (var i = 0; i < 5; i++)
                          Expanded(child: Icon(x[i] ? Icons.check_circle : Icons.circle_outlined, size: 22, color: x[i] ? Colors.green : Colors.grey)),
                      ]),
                    );
                  }),
                Row(children: [
                  const SizedBox(width: 90),
                  for (final p in prayers) Expanded(child: Center(child: Text(p, style: const TextStyle(fontSize: 10)))),
                ]),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}

// ═════════════ Quran ═════════════
class QuranListPage extends StatefulWidget {
  final AppState s;
  const QuranListPage(this.s, {super.key});
  @override
  State<QuranListPage> createState() => _QuranListState();
}

class _QuranListState extends State<QuranListPage> {
  late Future<List<dynamic>> f = Api.surahList();
  String q = '';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: TextField(
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'সূরার নাম বা নম্বর (English)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
          onChanged: (v) => setState(() => q = v.trim().toLowerCase()),
        ),
      ),
      Expanded(
        child: FutureBuilder<List<dynamic>>(
          future: f,
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snap.hasError || snap.data == null) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Padding(padding: EdgeInsets.all(16), child: Text('সূরার তালিকা আনা যায়নি। প্রথমবার ইন্টারনেট লাগবে।', textAlign: TextAlign.center)),
                  FilledButton(onPressed: () => setState(() => f = Api.surahList()), child: const Text('আবার চেষ্টা করুন')),
                ]),
              );
            }
            final list = snap.data!.where((e) {
              if (q.isEmpty) return true;
              return '${e['number']}'.contains(q) || '${e['englishName']}'.toLowerCase().contains(q);
            }).toList();
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final e = list[i];
                final n = e['number'] as int;
                return ListTile(
                  leading: CircleAvatar(backgroundColor: green2, child: Text(bn(n), style: const TextStyle(color: Colors.white, fontSize: 13))),
                  title: Text('${e['englishName']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${bn(e['numberOfAyahs'])} আয়াত • ${e['revelationType'] == 'Meccan' ? 'মাক্কী' : 'মাদানী'}'),
                  trailing: Text('${e['name']}', style: const TextStyle(fontSize: 20), textDirection: TextDirection.rtl),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahPage(widget.s, n, '${e['englishName']}'))),
                );
              },
            );
          },
        ),
      ),
    ]);
  }
}

String _plain(String w) => w.replaceAll(RegExp('[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '');

class AyahTile extends StatelessWidget {
  final AppState s;
  final String arText, bnText;
  final int? no;
  const AyahTile(this.s, this.arText, this.bnText, {super.key, this.no});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (no != null) Align(alignment: Alignment.centerLeft, child: CircleAvatar(radius: 13, backgroundColor: green2, child: Text(bn(no!), style: const TextStyle(color: Colors.white, fontSize: 11)))),
          const SizedBox(height: 6),
          Text(arText, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: TextStyle(fontSize: s.arSize, height: 1.9)),
          const Divider(),
          Text(bnText, style: const TextStyle(fontSize: 16, height: 1.5)),
        ]),
      ),
    );
  }
}

class SurahPage extends StatelessWidget {
  final AppState s;
  final int n;
  final String nm;
  const SurahPage(this.s, this.n, this.nm, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (_, __) => Scaffold(
        appBar: AppBar(title: Text(nm), actions: [
          IconButton(onPressed: () => s.setArSize(s.arSize - 2), icon: const Icon(Icons.text_decrease)),
          IconButton(onPressed: () => s.setArSize(s.arSize + 2), icon: const Icon(Icons.text_increase)),
        ]),
        body: FutureBuilder<QS>(
          future: Api.surah(n),
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snap.hasError || snap.data == null || snap.data!.ar.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('সূরাটি আনা যায়নি। ইন্টারনেট চালু করে আবার চেষ্টা করুন (একবার নামালে পরে অফলাইনেও চলবে)।', textAlign: TextAlign.center)));
            }
            final d = snap.data!;
            var ar0 = List<String>.from(d.ar);
            String? bis;
            if (n != 1 && n != 9 && ar0.isNotEmpty) {
              final words = ar0[0].split(' ');
              if (words.length > 4 && _plain(words[0]).startsWith('بسم')) {
                bis = words.take(4).join(' ');
                ar0[0] = words.skip(4).join(' ');
              }
            }
            return ListView(padding: const EdgeInsets.all(10), children: [
              if (bis != null) Center(child: Padding(padding: const EdgeInsets.all(8), child: Text(bis, textDirection: TextDirection.rtl, style: TextStyle(fontSize: s.arSize + 2, color: gold)))),
              for (var i = 0; i < ar0.length; i++) AyahTile(s, ar0[i], i < d.bn.length ? d.bn[i] : '', no: i + 1),
              Padding(padding: const EdgeInsets.all(12), child: Text('আরবি: উসমানি লিপি • অনুবাদ: মুহিউদ্দীন খান • সূত্র: alquran.cloud', style: TextStyle(fontSize: 11, color: mute(context)), textAlign: TextAlign.center)),
            ]);
          },
        ),
      ),
    );
  }
}

// ═════════════ Dua & Ruqyah (Quran-sourced text only) ═════════════
class Item {
  final String title, benefit, source;
  final List<String> refs;
  final int? inlineSurah, openSurah;
  const Item(this.title, this.benefit, this.source, {this.refs = const [], this.inlineSurah, this.openSurah});
}

class ItemCard extends StatelessWidget {
  final AppState s;
  final Item it;
  const ItemCard(this.s, this.it, {super.key});

  Future<QS> load() async {
    if (it.inlineSurah != null) return Api.surah(it.inlineSurah!);
    final ar0 = <String>[], b0 = <String>[];
    for (final r in it.refs) {
      final x = await Api.ayah(r);
      ar0.addAll(x.ar);
      b0.addAll(x.bn);
    }
    return QS(ar0, b0);
  }

  @override
  Widget build(BuildContext context) {
    final hasText = it.inlineSurah != null || it.refs.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(it.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(it.benefit, style: const TextStyle(fontSize: 14, height: 1.5)),
          if (it.source.isNotEmpty) Text('সূত্র: ${it.source}', style: TextStyle(fontSize: 12, color: mute(context))),
          if (hasText)
            FutureBuilder<QS>(
              future: load(),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
                if (snap.hasError || snap.data == null) return const Padding(padding: EdgeInsets.only(top: 10), child: Text('আয়াত আনা যায়নি, ইন্টারনেট চালু করে আবার খুলুন।', style: TextStyle(color: Colors.orange)));
                final d = snap.data!;
                return Column(children: [for (var i = 0; i < d.ar.length; i++) AyahTile(s, d.ar[i], i < d.bn.length ? d.bn[i] : '')]);
              },
            ),
          if (it.openSurah != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahPage(s, it.openSurah!, it.title))),
                icon: const Icon(Icons.menu_book),
                label: const Text('সম্পূর্ণ সূরা পড়ুন'),
              ),
            ),
        ]),
      ),
    );
  }
}

const duaItems = [
  Item('রাব্বানা আতিনা', 'দুনিয়া ও আখিরাতের কল্যাণ চাওয়ার দোয়া। নবী (সা.) সবচেয়ে বেশি এই দোয়াটি করতেন।', 'সহীহ বুখারি, সহীহ মুসলিম', refs: ['2:201']),
  Item('ইউনুস (আ.)-এর দোয়া', 'বিপদ ও কষ্টের সময়ের দোয়া। নবী (সা.) বলেছেন, কোনো মুসলিম এই দোয়ার মাধ্যমে যে বিষয়েই আল্লাহর কাছে চায়, আল্লাহ তা কবুল করেন।', 'জামে তিরমিযি', refs: ['21:87']),
  Item('জ্ঞান বৃদ্ধির দোয়া', 'আল্লাহ তাআলা নবী (সা.)-কে এই দোয়া শিখিয়েছেন। ইলম বৃদ্ধির জন্য পড়া হয়।', 'সূরা ত্বহা', refs: ['20:114']),
  Item('গুনাহ মাফের দোয়া', 'আদম ও হাওয়া (আ.)-এর তওবার দোয়া।', 'সূরা আরাফ', refs: ['7:23']),
  Item('পরিবারের জন্য দোয়া', 'স্ত্রী-সন্তানদের নেক ও চোখের শীতলতা হওয়ার জন্য মুমিনদের দোয়া।', 'সূরা ফুরকান', refs: ['25:74']),
  Item('নামাজে অবিচল থাকার দোয়া', 'ইবরাহিম (আ.)-এর দোয়া।', 'সূরা ইবরাহিম', refs: ['14:40']),
  Item('পিতা-মাতার জন্য দোয়া', 'পিতা-মাতার প্রতি রহমতের দোয়া।', 'সূরা বনি ইসরাইল', refs: ['17:24']),
  Item('সূরা বাকারার শেষ দুই আয়াত', 'নবী (সা.) বলেছেন, যে ব্যক্তি রাতে এই দুই আয়াত পড়বে, তার জন্য এটাই যথেষ্ট।', 'সহীহ বুখারি, সহীহ মুসলিম', refs: ['2:285', '2:286']),
  Item('সূরা কাহফ', 'জুমার দিনে পড়লে দুই জুমার মাঝে নূর (আলো) থাকে। প্রথম দশ আয়াত মুখস্থ থাকলে দাজ্জালের ফিতনা থেকে নিরাপদ থাকা যায়।', 'মুস্তাদরাক হাকিম (সহীহ), সহীহ মুসলিম', openSurah: 18),
  Item('সূরা মুলক', 'নবী (সা.) বলেছেন, ত্রিশ আয়াতের একটি সূরা তার পাঠকারীর জন্য সুপারিশ করবে যতক্ষণ না তাকে ক্ষমা করা হয়। সেটি সূরা মুলক। কবরের আযাব থেকে রক্ষার কথাও এসেছে।', 'জামে তিরমিযি (হাসান)', openSurah: 67),
];

const ruqyahItems = [
  Item('সূরা ফাতিহা', 'একজন সাহাবি দংশনে আক্রান্ত ব্যক্তির ওপর সূরা ফাতিহা পড়ে ঝাড়ফুঁক করেছিলেন। নবী (সা.) তা অনুমোদন করেছেন।', 'সহীহ বুখারি, সহীহ মুসলিম', inlineSurah: 1),
  Item('আয়াতুল কুরসি', 'ঘুমানোর আগে পড়লে আল্লাহর পক্ষ থেকে একজন রক্ষক নিযুক্ত থাকেন, সকাল পর্যন্ত শয়তান কাছে আসতে পারে না।', 'সহীহ বুখারি', refs: ['2:255']),
  Item('সূরা বাকারার শেষ দুই আয়াত', 'রাতে পড়লে তার জন্য যথেষ্ট।', 'সহীহ বুখারি, সহীহ মুসলিম', refs: ['2:285', '2:286']),
  Item('সূরা ইখলাস', 'সকাল-সন্ধ্যা তিনবার করে তিন কুল পড়লে সবকিছু থেকে যথেষ্ট হয়ে যায়। ঘুমানোর আগে হাতে ফুঁ দিয়ে শরীরে হাত বুলানো নবী (সা.)-এর আমল।', 'আবু দাউদ, তিরমিযি, সহীহ বুখারি', inlineSurah: 112),
  Item('সূরা ফালাক', 'ইখলাস, ফালাক ও নাস একসাথে সকাল-সন্ধ্যা তিনবার করে পড়ার কথা এসেছে।', 'আবু দাউদ, তিরমিযি', inlineSurah: 113),
  Item('সূরা নাস', 'ইখলাস, ফালাক ও নাস একসাথে সকাল-সন্ধ্যা তিনবার করে পড়ার কথা এসেছে।', 'আবু দাউদ, তিরমিযি', inlineSurah: 114),
];

class DuaPage extends StatelessWidget {
  final AppState s;
  const DuaPage(this.s, {super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(12), children: [
        Text('এখানকার আরবি ও অনুবাদ কুরআন থেকে সরাসরি নেওয়া (alquran.cloud, অনুবাদ: মুহিউদ্দীন খান)। প্রথমবার ইন্টারনেট লাগবে, পরে অফলাইনে চলবে।', style: TextStyle(fontSize: 12, color: mute(context))),
        for (final it in duaItems) ItemCard(s, it),
      ]);
}

class RuqyahPage extends StatelessWidget {
  final AppState s;
  const RuqyahPage(this.s, {super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(12), children: [
        Card(
          color: Colors.amber.withOpacity(.15),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'রুকইয়াহ হলো কুরআনের আয়াত ও সহীহ দোয়া পড়ে আল্লাহর কাছে শিফা ও হেফাজত চাওয়া।\n\n'
              'বৈধ হওয়ার শর্ত:\n'
              '১. কুরআন বা সহীহ দোয়া দিয়ে হতে হবে।\n'
              '২. অর্থ বোধগম্য হতে হবে, অজানা ভাষা বা মন্ত্র নয়।\n'
              '৩. বিশ্বাস রাখতে হবে আরোগ্য একমাত্র আল্লাহর পক্ষ থেকে।\n\n'
              'নিজে পড়ার নিয়ম: তিন কুল (ইখলাস, ফালাক, নাস) পড়ে দুই হাতে ফুঁ দিয়ে মাথা ও চেহারা থেকে শুরু করে যতটুকু সম্ভব শরীরে হাত বুলানো (সহীহ বুখারি)।\n\n'
              'সতর্কতা: তাবিজ, শিরকি মন্ত্র বা জিনের সাহায্য চাওয়া থেকে দূরে থাকুন। অসুখ হলে ডাক্তারের চিকিৎসাও নিন। রুকইয়াহ চিকিৎসার বিকল্প নয়।',
              style: TextStyle(height: 1.5),
            ),
          ),
        ),
        for (final it in ruqyahItems) ItemCard(s, it),
      ]);
}

// ═════════════ Settings ═════════════
class SetPage extends StatelessWidget {
  final AppState s;
  const SetPage(this.s, {super.key});

  Widget sec(String t, List<Widget> c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ...c,
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (_, __) => ListView(padding: const EdgeInsets.all(12), children: [
        sec('আপনার নাম', [
          Text(s.name.isEmpty ? '—' : s.addr),
          const SizedBox(height: 6),
          OutlinedButton(onPressed: () => askName(context, s), child: const Text('নাম বদলান')),
        ]),
        sec('লোকেশন', [
          Text('বর্তমান: ${s.place}'),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: s.gps, icon: const Icon(Icons.my_location), label: const Text('GPS থেকে লোকেশন নিন (থানা পর্যন্ত, বিদেশেও চলবে)')),
          const SizedBox(height: 8),
          DropdownButton<String>(
            isExpanded: true,
            value: dists.any((d) => d.n == s.place) ? s.place : null,
            hint: const Text('অথবা বাংলাদেশের জেলা বেছে নিন'),
            items: [for (final d in dists) DropdownMenuItem(value: d.n, child: Text(d.n))],
            onChanged: (v) {
              final d = dists.firstWhere((x) => x.n == v);
              s.setLoc(d.la, d.lo, d.n);
            },
          ),
        ]),
        sec('নামাজের সময় গণনা', [
          DropdownButton<String>(
            isExpanded: true,
            value: s.method,
            items: const [
              DropdownMenuItem(value: 'auto', child: Text('স্বয়ংক্রিয় (বাংলাদেশে করাচি)')),
              DropdownMenuItem(value: 'karachi', child: Text('করাচি')),
              DropdownMenuItem(value: 'mwl', child: Text('মুসলিম ওয়ার্ল্ড লীগ')),
              DropdownMenuItem(value: 'umm', child: Text('উম্মুল কুরা (মক্কা)')),
              DropdownMenuItem(value: 'egypt', child: Text('মিশর')),
            ],
            onChanged: (v) => s.setMethod(v ?? 'auto'),
          ),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('আসর: হানাফি মাজহাব'), value: s.hanafi, onChanged: s.setHanafi),
          Row(children: [
            const Expanded(child: Text('হিজরি তারিখ সমন্বয় (দিন)')),
            IconButton(onPressed: () => s.setAdj(s.adj - 1), icon: const Icon(Icons.remove_circle_outline)),
            Text(bn(s.adj), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            IconButton(onPressed: () => s.setAdj(s.adj + 1), icon: const Icon(Icons.add_circle_outline)),
          ]),
        ]),
        sec('আজান ও রিমাইন্ডার', [
          Text(kAzan ? 'আজানের শব্দ: অ্যাপে যুক্ত' : 'আজানের শব্দ: ফোনের অ্যালার্ম সাউন্ড (azan.mp3 যুক্ত করে বিল্ড করলে আজান বাজবে)', style: const TextStyle(fontSize: 13)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('ফজরের পর "নামাজ পড়েছেন তো?" রিমাইন্ডার'), value: s.remind, onChanged: s.setRemind),
          Wrap(spacing: 8, children: [
            OutlinedButton(
              onPressed: () async {
                await Notif.ask();
                await s.resched();
                final en = await Notif.enabled();
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(en ? 'নোটিফিকেশন চালু আছে, অ্যালার্ম সেট হয়েছে' : 'নোটিফিকেশন বন্ধ! ফোনের সেটিংস থেকে নূরনামার নোটিফিকেশন চালু করুন')));
              },
              child: const Text('অনুমতি দিন ও অ্যালার্ম সেট করুন'),
            ),
            OutlinedButton(
              onPressed: () async {
                final ok = await Notif.test();
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? '১০ সেকেন্ড পর আজান বাজবে' : 'অ্যালার্ম সেট করা যায়নি, অনুমতি দিন')));
              },
              child: const Text('১০ সেকেন্ড পর পরীক্ষা'),
            ),
          ]),
          const SizedBox(height: 6),
          Text('অ্যালার্ম ঠিকমতো বাজতে ফোনের ব্যাটারি সেটিংসে নূরনামাকে "Unrestricted/No restrictions" করুন এবং "Alarms & reminders" অনুমতি দিন।', style: TextStyle(fontSize: 12, color: mute(context))),
        ]),
        sec('থিম', [
          SegmentedButton<int>(
            segments: const [ButtonSegment(value: 0, label: Text('সিস্টেম')), ButtonSegment(value: 1, label: Text('লাইট')), ButtonSegment(value: 2, label: Text('ডার্ক'))],
            selected: {s.themeMode},
            onSelectionChanged: (v) => s.setTheme(v.first),
          ),
        ]),
      ]),
    );
  }
}

// ═════════════ About ═════════════
class AboutPage extends StatelessWidget {
  final AppState s;
  const AboutPage(this.s, {super.key});

  Widget social(IconData i, Color col, String url) => InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => openUrl(url),
        child: Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(shape: BoxShape.circle, color: col),
          child: Center(child: FaIcon(i, color: Colors.white, size: 26)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Center(child: Logo(size: 96)),
      const SizedBox(height: 10),
      const Center(child: Text(kApp, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: gold))),
      const Center(child: Text('সংস্করণ ২.০.০')),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [green, green2]), borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          const Text('DEVELOPER', style: TextStyle(color: Colors.white70, letterSpacing: 4, fontSize: 12)),
          const SizedBox(height: 6),
          const Text('Masum', style: TextStyle(color: gold, fontSize: 34, fontWeight: FontWeight.w800)),
          Container(margin: const EdgeInsets.only(top: 6, bottom: 16), height: 3, width: 60, color: gold),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            social(FontAwesomeIcons.facebookF, const Color(0xFF1877F2), linkFb),
            social(FontAwesomeIcons.instagram, const Color(0xFFD62976), linkIg),
            social(FontAwesomeIcons.telegram, const Color(0xFF229ED9), linkTg),
          ]),
          const SizedBox(height: 10),
          const Text('আমার পরিচয় জানতে আইকনে ট্যাপ করুন', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const Text('এই অ্যাপে কোনো বিজ্ঞাপন নেই। আপনার নাম ও নামাজের হিসাব শুধু আপনার ফোনেই থাকে। চাইলে আপনার বন্ধুদের সাথে অ্যাপটি শেয়ার করতে পারেন।',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.6)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Share.share('নূরনামা: নামাজের সময়, আজান, কিবলা, কুরআন, দোয়া ও আরও অনেক কিছু। বিজ্ঞাপনমুক্ত ইসলামি অ্যাপ।\nডাউনলোড ও আপডেট: $linkTg'),
              icon: const Icon(Icons.share),
              label: const Text('বন্ধুদের সাথে শেয়ার করুন'),
            ),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Text('কুরআনের আরবি ও বাংলা অনুবাদ: alquran.cloud (অনুবাদ: মুহিউদ্দীন খান)।', style: TextStyle(fontSize: 12, color: mute(context)), textAlign: TextAlign.center),
      ),
    ]);
  }
}
