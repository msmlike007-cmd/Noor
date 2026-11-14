part of 'main.dart';

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
          FilledButton.icon(onPressed: () => s.gps(), icon: const Icon(Icons.my_location), label: const Text('GPS থেকে লোকেশন নিন (থানা পর্যন্ত, বিদেশেও চলবে)')),
          const SizedBox(height: 8),
          DropdownButton<String>(
            isExpanded: true,
            value: dists.any((d) => d.n == s.place) ? s.place : null,
            hint: const Text('অথবা বাংলাদেশের জেলা বেছে নিন'),
            items: [for (final d in dists) DropdownMenuItem(value: d.n, child: Text(d.n))],
            onChanged: (v) {
              final d = dists.firstWhere((x) => x.n == v);
              s.setLoc(d.la, d.lo, d.n, manual: true);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('স্বয়ংক্রিয় লোকেশন'),
            subtitle: const Text('অ্যাপ খুললে GPS থেকে নিজে নিজে হালনাগাদ হবে। জেলা বেছে নিলে এটি বন্ধ হয়ে যায়।'),
            value: s.autoLoc,
            onChanged: s.setAutoLoc,
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
          const Text('আসরের সময় (অ্যালার্ম ও যোহরের শেষ সময় এই অনুযায়ী)', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          SegmentedButton<bool>(
            segments: const [ButtonSegment(value: true, label: Text('হানাফি')), ButtonSegment(value: false, label: Text('আহলে হাদিস/জমহুর'))],
            selected: {s.hanafi},
            onSelectionChanged: (v) => s.setHanafi(v.first),
          ),
          const SizedBox(height: 4),
          Text('হোম পেজে দুই সময়ই দেখানো হয়; ✓ চিহ্ন নির্বাচিতটির পাশে থাকে।', style: TextStyle(fontSize: 12, color: mute(context))),
          Row(children: [
            const Expanded(child: Text('হিজরি তারিখ সমন্বয় (দিন)')),
            IconButton(onPressed: () => s.setAdj(s.adj - 1), icon: const Icon(Icons.remove_circle_outline)),
            Text(bn(s.adj), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            IconButton(onPressed: () => s.setAdj(s.adj + 1), icon: const Icon(Icons.add_circle_outline)),
          ]),
        ]),
        sec('আজান ও রিমাইন্ডার', [
          Text(kAzan ? 'আজানের শব্দ: অ্যাপে যুক্ত' : 'আজানের শব্দ: ফোনের অ্যালার্ম সাউন্ড (azan.mp3 যুক্ত করে বিল্ড করলে আজান বাজবে)', style: const TextStyle(fontSize: 13)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('প্রতি ওয়াক্তের ১৫ মিনিট পর "নামাজ পড়েছেন তো?"'), value: s.remind, onChanged: s.setRemind),
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
          child: Center(child: Icon(i, color: Colors.white, size: 28)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Center(child: Logo(size: 96)),
      const SizedBox(height: 10),
      const Center(child: Text(kApp, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: gold))),
      Center(child: Text('সংস্করণ ${bn(kVersion)}')),
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
            social(Icons.facebook, const Color(0xFF1877F2), linkFb),
            social(Icons.camera_alt_rounded, const Color(0xFFD62976), linkIg),
            social(Icons.send_rounded, const Color(0xFF229ED9), linkTg),
          ]),
          const SizedBox(height: 10),
          const Text('আমার পরিচয় জানতে আইকনে ট্যাপ করুন', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
      const SizedBox(height: 16),
      Center(child: OutlinedButton.icon(onPressed: () async {
        await s.checkUpdate();
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.update != null ? 'নতুন আপডেট পাওয়া গেছে, নামাজ পেজে দেখুন' : 'আপনার অ্যাপ সর্বশেষ সংস্করণে আছে')));
      }, icon: const Icon(Icons.system_update), label: const Text('আপডেট খুঁজুন'))),
      const SizedBox(height: 10),
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
        child: Text('কুরআনের আরবি ও বাংলা অনুবাদ: alquran.cloud (অনুবাদ: মুহিউদ্দীন খান)। হাদিস (ডাউনলোডকৃত): Hadith API।', style: TextStyle(fontSize: 12, color: mute(context)), textAlign: TextAlign.center),
      ),
    ]);
  }
}
