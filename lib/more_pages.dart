part of 'main.dart';

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
      [Icons.alarm_add, 'আমার অ্যালার্ম', () => openPage(context, 'আমার অ্যালার্ম', CustomAlarmPage(s))],
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
  static const fNames = ['সুবহানাল্লাহ', 'আলহামদুলিল্লাহ', 'আল্লাহু আকবার'];
  static const fTargets = [33, 33, 34];
  int count = 0, target = 33, stage = 0;
  bool fatimi = true, done = false;
  String dhikr = 'সুবহানাল্লাহ';

  void tap() {
    if (fatimi) {
      if (done) return;
      setState(() => count++);
      if (count >= fTargets[stage]) {
        HapticFeedback.heavyImpact();
        if (stage == 2) {
          setState(() => done = true);
        } else {
          setState(() {
            stage++;
            count = 0;
          });
        }
      } else {
        HapticFeedback.lightImpact();
      }
      return;
    }
    setState(() => count++);
    if (target > 0 && count % target == 0) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void reset() => setState(() {
        count = 0;
        stage = 0;
        done = false;
      });

  @override
  Widget build(BuildContext context) {
    final name = fatimi ? fNames[stage] : dhikr;
    final tgt = fatimi ? fTargets[stage] : target;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Center(
        child: SegmentedButton<bool>(
          segments: const [ButtonSegment(value: true, label: Text('৩৩-৩৩-৩৪')), ButtonSegment(value: false, label: Text('নিজের মতো'))],
          selected: {fatimi},
          onSelectionChanged: (v) {
            fatimi = v.first;
            reset();
          },
        ),
      ),
      const SizedBox(height: 10),
      if (!fatimi) ...[
        Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [
          for (final d in ['সুবহানাল্লাহ', 'আলহামদুলিল্লাহ', 'আল্লাহু আকবার', 'লা ইলাহা ইল্লাল্লাহ', 'আস্তাগফিরুল্লাহ'])
            ChoiceChip(label: Text(d), selected: dhikr == d, onSelected: (_) => setState(() => dhikr = d)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, alignment: WrapAlignment.center, children: [
          for (final t in [33, 99, 100, 0])
            ChoiceChip(label: Text(t == 0 ? 'সীমাহীন' : bn(t)), selected: target == t, onSelected: (_) => setState(() => target = t)),
        ]),
      ],
      if (fatimi)
        Center(child: Text('ধাপ ${bn(stage + 1)}/${bn(3)}', style: TextStyle(color: mute(context)))),
      const SizedBox(height: 18),
      Center(child: Text(done ? 'আলহামদুলিল্লাহ, তাসবিহ পূর্ণ হয়েছে' : name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: gold))),
      const SizedBox(height: 14),
      Center(
        child: GestureDetector(
          onTap: tap,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: done ? [Colors.green, green2] : [green2, green], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Center(
              child: done
                  ? const Icon(Icons.check, color: Colors.white, size: 90)
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(bn(count), style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w700)),
                      if (tgt > 0) Text('/ ${bn(tgt)}', style: const TextStyle(color: gold, fontSize: 18)),
                    ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Center(child: OutlinedButton.icon(onPressed: reset, icon: const Icon(Icons.refresh), label: const Text('শূন্য করুন'))),
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
        var streak = 0;
        var d = today;
        if (!s.trk(d).every((e) => e)) d = d.subtract(const Duration(days: 1));
        while (streak < 400 && s.trk(d).every((e) => e)) {
          streak++;
          d = d.subtract(const Duration(days: 1));
        }
        var monthDone = 0;
        for (var k = 1; k <= today.day; k++) {
          monthDone += s.trk(DateTime(today.year, today.month, k)).where((e) => e).length;
        }
        final monthTotal = today.day * 5;
        final pct = monthTotal == 0 ? 0 : (monthDone * 100 / monthTotal).round();
        return ListView(padding: const EdgeInsets.all(12), children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('আজ: ${bn(done)}/${bn(5)} ওয়াক্ত', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: done / 5, minHeight: 8),
                for (var i = 0; i < 5; i++)
                  CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(prayers[i]), value: t[i], onChanged: (v) => s.setTrk(today, i, v ?? false)),
              ]),
            ),
          ),
          Row(children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    Text('${bn(streak)} দিন', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: gold)),
                    const Text('টানা ৫ ওয়াক্ত', style: TextStyle(fontSize: 12)),
                  ]),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    Text('${bn(monthDone)}/${bn(monthTotal)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: gold)),
                    Text('এই মাসে (${bn(pct)}%)', style: const TextStyle(fontSize: 12)),
                  ]),
                ),
              ),
            ),
          ]),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                const Align(alignment: Alignment.centerLeft, child: Text('গত ৭ দিন (ট্যাপ করে বদলানো যায়)', style: TextStyle(fontWeight: FontWeight.w700))),
                const SizedBox(height: 8),
                for (var k = 0; k < 7; k++)
                  Builder(builder: (_) {
                    final day = today.subtract(Duration(days: k));
                    final x = s.trk(day);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        SizedBox(width: 90, child: Text(k == 0 ? 'আজ' : wdBn[day.weekday % 7], style: const TextStyle(fontSize: 13))),
                        for (var i = 0; i < 5; i++)
                          Expanded(
                            child: InkWell(
                              onTap: () => s.setTrk(day, i, !x[i]),
                              child: Icon(x[i] ? Icons.check_circle : Icons.circle_outlined, size: 24, color: x[i] ? Colors.green : Colors.grey),
                            ),
                          ),
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('প্রতি ওয়াক্তের ১৫ মিনিট পর নোটিফিকেশন আসে, সেখান থেকেই "হ্যাঁ, পড়েছি" চাপলে এখানে টিক পড়ে যায়।', style: TextStyle(fontSize: 12, color: mute(context))),
          ),
        ]);
      },
    );
  }
}

// ═════════════ Custom alarms ═════════════
class CustomAlarmPage extends StatelessWidget {
  final AppState s;
  const CustomAlarmPage(this.s, {super.key});

  Future<void> add(BuildContext context) async {
    final tm = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 4, minute: 0));
    if (tm == null || !context.mounted) return;
    final c = TextEditingController(text: 'নামাজের অ্যালার্ম');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('অ্যালার্মের নাম'),
        content: TextField(controller: c, decoration: const InputDecoration(hintText: 'যেমন: তাহাজ্জুদ, ইশরাক, চাশত')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('বাতিল')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('সংরক্ষণ')),
        ],
      ),
    );
    if (ok == true) await s.addCustom(c.text.trim().isEmpty ? 'অ্যালার্ম' : c.text.trim(), tm.hour, tm.minute);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (_, __) => ListView(padding: const EdgeInsets.all(12), children: [
        FilledButton.icon(onPressed: () => add(context), icon: const Icon(Icons.add_alarm), label: const Text('নতুন অ্যালার্ম যোগ করুন')),
        const SizedBox(height: 8),
        if (s.customs.isEmpty)
          Padding(padding: const EdgeInsets.all(20), child: Text('কোনো অ্যালার্ম নেই। তাহাজ্জুদ, ইশরাক, চাশত বা যেকোনো নামাজের জন্য নিজের সময়ে অ্যালার্ম সেট করুন। অ্যালার্ম প্রতিদিন বাজবে এবং "বন্ধ করুন" চাপলে থামবে।', style: TextStyle(color: mute(context)))),
        for (var i = 0; i < s.customs.length; i++)
          Card(
            child: ListTile(
              leading: Icon(Icons.alarm, color: pri(context)),
              title: Text('${s.customs[i]['l']}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(fmt(DateTime(2000, 1, 1, s.customs[i]['h'] as int, s.customs[i]['m'] as int))),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Switch(value: s.customs[i]['on'] == true, onChanged: (_) => s.toggleCustom(i)),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => s.delCustom(i)),
              ]),
            ),
          ),
      ]),
    );
  }
}
