part of 'main.dart';

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
