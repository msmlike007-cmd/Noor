part of 'main.dart';

// ═════════════ Logo ═════════════
class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 48});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => CustomPaint(painter: _LogoPainter())),
        ),
      );
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
      if (s.update != null)
        Card(
          color: gold.withOpacity(.2),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('নতুন আপডেট এসেছে: ${s.update!['version']}', style: const TextStyle(fontWeight: FontWeight.w700)),
              if ((s.update!['notes'] ?? '').toString().isNotEmpty) Text('${s.update!['notes']}'),
              TextButton.icon(onPressed: () => openUrl('${s.update!['url']}'), icon: const Icon(Icons.download), label: const Text('ডাউনলোড করুন')),
            ]),
          ),
        ),
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
              subtitle: Text(i == 2
                  ? 'হানাফি ${fmt(tt.asrHanafi)}${s.hanafi ? ' ✓' : ''}  •  আহলে হাদিস ${fmt(tt.asrShafi)}${s.hanafi ? '' : ' ✓'}\nশেষ ${fmt(tt.endOf(i))}  (✓ = অ্যালার্মে নির্বাচিত)'
                  : 'শুরু ${fmt(tt.five[i])}  •  শেষ ${fmt(tt.endOf(i))}'),
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
        child: Text('গণনা: ${s.method == 'auto' ? (inBdAt(s.lat, s.lon) ? 'করাচি' : 'মুসলিম ওয়ার্ল্ড লীগ') : s.method} পদ্ধতি, আসর: হানাফি ও আহলে হাদিস/জমহুর দুই সময়ই দেখানো হয় (অ্যালার্ম ও যোহরের শেষ সময় ${s.hanafi ? 'হানাফি' : 'আহলে হাদিস'} অনুযায়ী)। স্থানীয় ক্যালেন্ডারের সাথে ১-২ মিনিট পার্থক্য হতে পারে।',
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
            Text('আসর: হানাফি ${fmt(tt.asrHanafi)} • আহলে হাদিস ${fmt(tt.asrShafi)}'),
            Text('সূর্যোদয়: ${fmt(tt.sunrise)}'),
          ]),
        ),
      ),
    ]);
  }
}
