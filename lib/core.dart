part of 'main.dart';

// ═════════════ Constants ═════════════
const kApp = 'নূরনামা';
const kAzan = bool.fromEnvironment('AZAN');
const kVersion = '2.1.0';
const kBuild = 3;
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
  final DateTime sunrise, nextFajr, asrHanafi, asrShafi;
  Day(this.five, this.sunrise, this.nextFajr, this.asrHanafi, this.asrShafi);
  DateTime get fajr => five[0];
  DateTime get sunset => five[3];
  DateTime endOf(int i) => i == 0 ? sunrise : i == 1 ? five[2] : i == 2 ? five[3] : i == 3 ? five[4] : nextFajr;
}

Day timesFor(DateTime d, AppState s) {
  final comp = DateComponents.from(d);
  final t = PrayerTimes(s.c, comp, s.params());
  final n = PrayerTimes(s.c, DateComponents.from(d.add(const Duration(days: 1))), s.params());
  final ah = PrayerTimes(s.c, comp, s.params(hanafiOverride: true));
  final asf = PrayerTimes(s.c, comp, s.params(hanafiOverride: false));
  DateTime l(DateTime x) => x.toLocal();
  return Day([l(t.fajr), l(t.dhuhr), l(t.asr), l(t.maghrib), l(t.isha)], l(t.sunrise), l(n.fajr), l(ah.asr), l(asf.asr));
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
