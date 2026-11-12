part of 'main.dart';

// ═════════════ State ═════════════
class AppState extends ChangeNotifier {
  double lat = 23.81, lon = 90.41;
  String place = 'ঢাকা';
  List<bool> on = List.filled(5, true);
  int adj = 0, themeMode = 0;
  bool hanafi = true, remind = true, loaded = false;
  String method = 'auto', name = '', title = 'ভাই', note = '', lastPopup = '';
  double arSize = 26;
  List<Map<String, dynamic>> customs = [];
  Map<String, dynamic>? update;
  late SharedPreferences sp;

  Coordinates get c => Coordinates(lat, lon);
  String get addr => title.isEmpty ? name : '$name $title';

  CalculationParameters params({bool? hanafiOverride}) {
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
    p.madhab = (hanafiOverride ?? hanafi) ? Madhab.hanafi : Madhab.shafi;
    return p;
  }

  Future<void> load() async {
    sp = await SharedPreferences.getInstance();
    adj = (sp.getInt('adj') ?? 0).clamp(-2, 2).toInt();
    themeMode = (sp.getInt('theme') ?? 0).clamp(0, 2).toInt();
    hanafi = sp.getBool('hanafi') ?? true;
    remind = sp.getBool('remind') ?? true;
    method = sp.getString('method') ?? 'auto';
    name = sp.getString('name') ?? '';
    title = sp.getString('title') ?? 'ভাই';
    lastPopup = sp.getString('popup') ?? '';
    arSize = (sp.getDouble('arSize') ?? 26).clamp(18, 44).toDouble();
    final cj = sp.getString('customs');
    if (cj != null) {
      try {
        customs = (jsonDecode(cj) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {}
    }
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
      final r = await http
          .get(Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&zoom=14&accept-language=bn&lat=$la&lon=$lo'),
              headers: {'User-Agent': 'NurNama/2.0 (Android prayer times app)'})
          .timeout(const Duration(seconds: 12));
      if (r.statusCode == 200) {
        final a = (jsonDecode(utf8.decode(r.bodyBytes))['address'] ?? {}) as Map;
        final parts = <String>[];
        for (final k in ['suburb', 'neighbourhood', 'village', 'town', 'city', 'municipality', 'county', 'state_district']) {
          final v = (a[k] ?? '').toString().trim();
          if (v.isNotEmpty && !parts.contains(v)) parts.add(v);
        }
        final out = parts.take(3).toList();
        final cn = (a['country'] ?? '').toString().trim();
        if (cn.isNotEmpty && !inBdAt(la, lo)) out.add(cn);
        if (out.isNotEmpty) return out.join(', ');
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
    adj = v.clamp(-2, 2).toInt();
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
    themeMode = v.clamp(0, 2).toInt();
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
    arSize = v.clamp(18, 44).toDouble();
    await sp.setDouble('arSize', arSize);
    notifyListeners();
  }

  Future<void> refresh() async {
    if (!loaded) return;
    await sp.reload();
    notifyListeners();
  }

  Future<void> _saveCustoms() async {
    await sp.setString('customs', jsonEncode(customs));
    notifyListeners();
    await resched();
  }

  Future<void> addCustom(String label, int h, int m) async {
    if (customs.length >= 10) return;
    customs.add({'l': label, 'h': h, 'm': m, 'on': true});
    await _saveCustoms();
  }

  Future<void> toggleCustom(int i) async {
    customs[i]['on'] = !(customs[i]['on'] == true);
    await _saveCustoms();
  }

  Future<void> delCustom(int i) async {
    customs.removeAt(i);
    await _saveCustoms();
  }

  Future<void> checkUpdate() async {
    try {
      final r = await http
          .get(Uri.parse('https://raw.githubusercontent.com/msmlike007-cmd/Nurnama/main/version.json'))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return;
      final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      if ((j['build'] as num) > kBuild) {
        update = j;
        notifyListeners();
      }
    } catch (_) {}
  }

  List<bool> trk(DateTime d) => (sp.getString('trk_${dateKey(d)}') ?? '00000').split('').map((e) => e == '1').toList();

  Future<void> setTrk(DateTime d, int i, bool v) async {
    final l = trk(d);
    l[i] = v;
    await sp.setString('trk_${dateKey(d)}', l.map((e) => e ? '1' : '0').join());
    notifyListeners();
  }
}
