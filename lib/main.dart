import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

part 'core.dart';
part 'notifications.dart';
part 'app_state.dart';
part 'home_page.dart';
part 'more_pages.dart';
part 'quran_dua.dart';
part 'hadith_page.dart';
part 'settings_about.dart';

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

class _ShellState extends State<Shell> with WidgetsBindingObserver {
  int i = 0;
  bool _boot = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.s.addListener(_maybeBoot);
    _maybeBoot();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.s.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    s.checkUpdate();
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
