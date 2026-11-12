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

/// \u09AA\u09CD\u09B0\u09A5\u09AE \u0986\u09AF\u09BC\u09BE\u09A4 \u09A5\u09C7\u0995\u09C7 \u09AC\u09BF\u09B8\u09AE\u09BF\u09B2\u09CD\u09B2\u09BE\u09B9 \u09AC\u09BE\u09A6 \u09A6\u09C7\u09AF\u09BC (\u09B8\u09C2\u09B0\u09BE \u09E7 \u0993 \u09EF \u099B\u09BE\u09A1\u09BC\u09BE)
List<String> noBis(int n, List<String> a) {
  final r = List<String>.from(a);
  if (n != 1 && n != 9 && r.isNotEmpty) {
    final w = r[0].split(' ');
    if (w.length > 4 && _plain(w[0]).startsWith('\u0628\u0633\u0645')) r[0] = w.skip(4).join(' ');
  }
  return r;
}

class AyahTile extends StatelessWidget {
  final AppState s;
  final String arText, bnText, ucc;
  final int? no;
  const AyahTile(this.s, this.arText, this.bnText, {super.key, this.no, this.ucc = ''});

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
          if (ucc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('উচ্চারণ: $ucc', style: TextStyle(fontSize: 15, height: 1.6, color: pri(context))),
          ],
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
  final List<String> ucc; // আয়াত অনুযায়ী বাংলা উচ্চারণ (ক্রম একই)
  final int? inlineSurah, openSurah;
  const Item(this.title, this.benefit, this.source, {this.refs = const [], this.ucc = const [], this.inlineSurah, this.openSurah});
}

class ItemCard extends StatelessWidget {
  final AppState s;
  final Item it;
  const ItemCard(this.s, this.it, {super.key});

  Future<QS> load() async {
    if (it.inlineSurah != null) {
      final n = it.inlineSurah!;
      final x = await Api.surah(n);
      return QS(noBis(n, x.ar), x.bn);
    }
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
                return Column(children: [
                  for (var i = 0; i < d.ar.length; i++) AyahTile(s, d.ar[i], i < d.bn.length ? d.bn[i] : '', ucc: i < it.ucc.length ? it.ucc[i] : ''),
                ]);
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
  Item('রাব্বানা আতিনা', 'দুনিয়া ও আখিরাতের কল্যাণ চাওয়ার দোয়া। নবী (সা.) সবচেয়ে বেশি এই দোয়াটি করতেন।', 'সহীহ বুখারি, সহীহ মুসলিম',
      refs: ['2:201'], ucc: ['রাব্বানা আতিনা ফিদ্দুনইয়া হাসানাতাঁও ওয়া ফিল আখিরাতি হাসানাতাঁও ওয়া ক্বিনা আযাবান্নার।']),
  Item('ইউনুস (আ.)-এর দোয়া', 'বিপদ ও কষ্টের সময়ের দোয়া। নবী (সা.) বলেছেন, কোনো মুসলিম এই দোয়ার মাধ্যমে যে বিষয়েই আল্লাহর কাছে চায়, আল্লাহ তা কবুল করেন।', 'জামে তিরমিযি',
      refs: ['21:87'], ucc: ['ওয়া যান-নূনি ইয যাহাবা মুগাযিবান ফাযান্না আল লান নাক্বদিরা আলাইহি ফানাদা ফিজ্জুলুমাতি আল লা ইলাহা ইল্লা আনতা সুবহানাকা ইন্নী কুনতু মিনায যালিমীন।']),
  Item('জ্ঞান বৃদ্ধির দোয়া', 'আল্লাহ তাআলা নবী (সা.)-কে এই দোয়া শিখিয়েছেন। ইলম বৃদ্ধির জন্য পড়া হয়।', 'সূরা ত্বহা',
      refs: ['20:114'], ucc: ['ফাতা\'আলাল্লাহুল মালিকুল হাক্ক, ওয়া লা তা\'জাল বিল কুরআনি মিন ক্বাবলি আই ইউক্বদা ইলাইকা ওয়াহইয়ুহূ, ওয়া কুর রাব্বি যিদনী ইলমা।']),
  Item('গুনাহ মাফের দোয়া', 'আদম ও হাওয়া (আ.)-এর তওবার দোয়া।', 'সূরা আরাফ',
      refs: ['7:23'], ucc: ['ক্বালা রাব্বানা যালামনা আনফুসানা ওয়া ইল্লাম তাগফির লানা ওয়া তারহামনা লানাকূনান্না মিনাল খাসিরীন।']),
  Item('পরিবারের জন্য দোয়া', 'স্ত্রী-সন্তানদের নেক ও চোখের শীতলতা হওয়ার জন্য মুমিনদের দোয়া।', 'সূরা ফুরকান',
      refs: ['25:74'], ucc: ['ওয়াল্লাযীনা ইয়াকূলূনা রাব্বানা হাব লানা মিন আযওয়াজিনা ওয়া যুর্রিইয়াতিনা কুররাতা আ\'ইউনিঁও ওয়াজ\'আলনা লিল মুত্তাক্বীনা ইমামা।']),
  Item('নামাজে অবিচল থাকার দোয়া', 'ইবরাহিম (আ.)-এর দোয়া।', 'সূরা ইবরাহিম',
      refs: ['14:40'], ucc: ['রাব্বিজ\'আলনী মুক্বীমাস সালাতি ওয়া মিন যুর্রিইয়্যাতী, রাব্বানা ওয়া তাক্বাব্বাল দু\'আ।']),
  Item('পিতা-মাতার জন্য দোয়া', 'পিতা-মাতার প্রতি রহমতের দোয়া।', 'সূরা বনি ইসরাইল',
      refs: ['17:24'], ucc: ['ওয়াখফিদ লাহুমা জানাহায যুল্লি মিনার রাহমাতি ওয়া কুর রাব্বির হামহুমা কামা রাব্বাইয়ানী সাগীরা।']),
  Item('নিজের ও পিতা-মাতার ক্ষমার দোয়া', 'ইবরাহিম (আ.)-এর দোয়া: নিজের, পিতা-মাতার ও সব মুমিনের ক্ষমার জন্য।', 'সূরা ইবরাহিম',
      refs: ['14:41'], ucc: ['রাব্বানাগফির লী ওয়া লিওয়ালিদাইয়্যা ওয়া লিলমু\'মিনীনা ইয়াওমা ইয়াকূমুল হিসাব।']),
  Item('অন্তর হেদায়েতের ওপর রাখার দোয়া', 'হেদায়েত পাওয়ার পর অন্তর যেন বাঁকা না হয়, সেই দোয়া।', 'সূরা আলে ইমরান',
      refs: ['3:8'], ucc: ['রাব্বানা লা তুযিগ কুলূবানা বা\'দা ইয হাদাইতানা ওয়া হাব লানা মিল লাদুনকা রাহমাহ, ইন্নাকা আনতাল ওয়াহহাব।']),
  Item('কাজ সহজ হওয়ার দোয়া (মূসা আ.)', 'মূসা (আ.)-এর দোয়া: অন্তর প্রশস্ত, কাজ সহজ এবং কথা বোঝানোর সক্ষমতার জন্য।', 'সূরা ত্বহা',
      refs: ['20:25', '20:26', '20:27', '20:28'],
      ucc: ['ক্বালা রাব্বিশরাহ লী সাদরী', 'ওয়া ইয়াসসির লী আমরী', 'ওয়াহলুল উকদাতাম মিল লিসানী', 'ইয়াফক্বাহূ ক্বাওলী']),
  Item('সঠিক পথ ও রহমতের দোয়া', 'আসহাবে কাহফের যুবকদের দোয়া।', 'সূরা কাহফ',
      refs: ['18:10'], ucc: ['ইয আওয়াল ফিতইয়াতু ইলাল কাহফি ফাক্বালূ রাব্বানা আতিনা মিল লাদুনকা রাহমাতাঁও ওয়া হাইয়্যি\' লানা মিন আমরিনা রাশাদা।']),
  Item('আল্লাহর কাছে কল্যাণ চাওয়ার দোয়া (মূসা আ.)', 'মূসা (আ.) অসহায় অবস্থায় আল্লাহর কাছে যে দোয়া করেছিলেন।', 'সূরা কাসাস',
      refs: ['28:24'], ucc: ['ফাসাক্বা লাহুমা সুম্মা তাওয়াল্লা ইলায যিল্লি ফাক্বালা রাব্বি ইন্নী লিমা আনযালতা ইলাইয়্যা মিন খাইরিন ফাক্বীর।']),
  Item('অসুস্থতা ও কষ্টের দোয়া (আইয়ূব আ.)', 'আইয়ূব (আ.) কঠিন অসুখের সময় আল্লাহকে এভাবে ডেকেছিলেন।', 'সূরা আম্বিয়া',
      refs: ['21:83'], ucc: ['ওয়া আইয়ূবা ইয নাদা রাব্বাহূ আন্নী মাসসানিয়ায যুররু ওয়া আনতা আরহামুর রাহিমীন।']),
  Item('কবুল ও ক্ষমার দোয়া', 'ইবরাহিম ও ইসমাইল (আ.) কাবা নির্মাণের সময় আমল কবুলের জন্য এই দোয়া করেছিলেন।', 'সূরা বাকারা',
      refs: ['2:127'], ucc: ['ওয়া ইয ইয়ারফা\'উ ইবরাহীমুল ক্বাওয়াইদা মিনাল বাইতি ওয়া ইসমাঈল, রাব্বানা তাক্বাব্বাল মিন্না, ইন্নাকা আনতাস সামীউল আলীম।']),
  Item('রহম ও মাফের দোয়া', 'আল্লাহ তাআলা নিজে নবী (সা.)-কে এই দোয়া করতে বলেছেন।', 'সূরা মুমিনুন',
      refs: ['23:118'], ucc: ['ওয়া কুর রাব্বিগফির ওয়ারহাম ওয়া আনতা খাইরুর রাহিমীন।']),
  Item('আল্লাহর ওপর ভরসার দোয়া', 'আল্লাহই যথেষ্ট, তাঁর ওপরই ভরসা, এই ঘোষণা।', 'সূরা তাওবা',
      refs: ['9:129'], ucc: ['ফা ইন তাওয়াল্লাউ ফাকুল হাসবিয়াল্লাহু লা ইলাহা ইল্লা হুওয়া, আলাইহি তাওয়াক্কালতু ওয়া হুওয়া রাব্বুল আরশিল আযীম।']),
  Item('সূরা বাকারার শেষ দুই আয়াত', 'নবী (সা.) বলেছেন, যে ব্যক্তি রাতে এই দুই আয়াত পড়বে, তার জন্য এটাই যথেষ্ট।', 'সহীহ বুখারি, সহীহ মুসলিম',
      refs: ['2:285', '2:286'],
      ucc: [
        'আমানার রাসূলু বিমা উনযিলা ইলাইহি মির রাব্বিহী ওয়াল মু\'মিনূন, কুল্লুন আমানা বিল্লাহি ওয়া মালাইকাতিহী ওয়া কুতুবিহী ওয়া রুসুলিহ, লা নুফাররিকু বাইনা আহাদিম মির রুসুলিহ, ওয়া ক্বালূ সামি\'না ওয়া আত্বা\'না গুফরানাকা রাব্বানা ওয়া ইলাইকাল মাসীর।',
        'লা ইউকাল্লিফুল্লাহু নাফসান ইল্লা উসআহা, লাহা মা কাসাবাত ওয়া আলাইহা মাকতাসাবাত, রাব্বানা লা তুআখিযনা ইন নাসীনা আও আখত্বা\'না, রাব্বানা ওয়া লা তাহমিল আলাইনা ইসরান কামা হামালতাহূ আলাল্লাযীনা মিন ক্বাবলিনা, রাব্বানা ওয়া লা তুহাম্মিলনা মা লা ত্বাক্বাতা লানা বিহ, ওয়া\'ফু আন্না ওয়াগফির লানা ওয়ারহামনা, আনতা মাওলানা ফানসুরনা আলাল ক্বাওমিল কাফিরীন।',
      ]),
  Item('সূরা কাহফ', 'জুমার দিনে পড়লে দুই জুমার মাঝে নূর (আলো) থাকে। প্রথম দশ আয়াত মুখস্থ থাকলে দাজ্জালের ফিতনা থেকে নিরাপদ থাকা যায়।', 'মুস্তাদরাক হাকিম (সহীহ), সহীহ মুসলিম', openSurah: 18),
  Item('সূরা মুলক', 'নবী (সা.) বলেছেন, ত্রিশ আয়াতের একটি সূরা তার পাঠকারীর জন্য সুপারিশ করবে যতক্ষণ না তাকে ক্ষমা করা হয়। সেটি সূরা মুলক। কবরের আযাব থেকে রক্ষার কথাও এসেছে।', 'জামে তিরমিযি (হাসান)', openSurah: 67),
];

const ruqyahItems = [
  Item('সূরা ফাতিহা', 'একজন সাহাবি দংশনে আক্রান্ত ব্যক্তির ওপর সূরা ফাতিহা পড়ে ঝাড়ফুঁক করেছিলেন। নবী (সা.) তা অনুমোদন করেছেন।', 'সহীহ বুখারি, সহীহ মুসলিম', inlineSurah: 1,
      ucc: [
        'বিসমিল্লাহির রাহমানির রাহীম',
        'আলহামদু লিল্লাহি রাব্বিল আলামীন',
        'আর রাহমানির রাহীম',
        'মালিকি ইয়াওমিদ্দীন',
        'ইয়্যাকা না\'বুদু ওয়া ইয়্যাকা নাস্তা\'ঈন',
        'ইহদিনাস সিরাতাল মুস্তাক্বীম',
        'সিরাতাল্লাযীনা আন\'আমতা আলাইহিম, গাইরিল মাগদূবি আলাইহিম ওয়ালাদ দ্বাল্লীন',
      ]),
  Item('আয়াতুল কুরসি', 'ঘুমানোর আগে পড়লে আল্লাহর পক্ষ থেকে একজন রক্ষক নিযুক্ত থাকেন, সকাল পর্যন্ত শয়তান কাছে আসতে পারে না।', 'সহীহ বুখারি',
      refs: ['2:255'],
      ucc: ['আল্লাহু লা ইলাহা ইল্লা হুওয়াল হাইয়্যুল ক্বাইয়্যূম, লা তা\'খুযুহূ সিনাতুঁও ওয়া লা নাউম, লাহূ মা ফিস সামাওয়াতি ওয়া মা ফিল আরদ, মান যাল্লাযী ইয়াশফা\'উ ইনদাহূ ইল্লা বিইযনিহ, ইয়া\'লামু মা বাইনা আইদীহিম ওয়া মা খালফাহুম, ওয়া লা ইউহীত্বূনা বিশাইয়িম মিন ইলমিহী ইল্লা বিমা শা-আ, ওয়াসি\'আ কুরসিইয়্যুহুস সামাওয়াতি ওয়াল আরদ, ওয়া লা ইয়াঊদুহূ হিফযুহুমা, ওয়া হুওয়াল আলিইয়্যুল আযীম।']),
  Item('সূরা বাকারার শেষ দুই আয়াত', 'রাতে পড়লে তার জন্য যথেষ্ট।', 'সহীহ বুখারি, সহীহ মুসলিম',
      refs: ['2:285', '2:286'],
      ucc: [
        'আমানার রাসূলু বিমা উনযিলা ইলাইহি মির রাব্বিহী ওয়াল মু\'মিনূন, কুল্লুন আমানা বিল্লাহি ওয়া মালাইকাতিহী ওয়া কুতুবিহী ওয়া রুসুলিহ, লা নুফাররিকু বাইনা আহাদিম মির রুসুলিহ, ওয়া ক্বালূ সামি\'না ওয়া আত্বা\'না গুফরানাকা রাব্বানা ওয়া ইলাইকাল মাসীর।',
        'লা ইউকাল্লিফুল্লাহু নাফসান ইল্লা উসআহা, লাহা মা কাসাবাত ওয়া আলাইহা মাকতাসাবাত, রাব্বানা লা তুআখিযনা ইন নাসীনা আও আখত্বা\'না, রাব্বানা ওয়া লা তাহমিল আলাইনা ইসরান কামা হামালতাহূ আলাল্লাযীনা মিন ক্বাবলিনা, রাব্বানা ওয়া লা তুহাম্মিলনা মা লা ত্বাক্বাতা লানা বিহ, ওয়া\'ফু আন্না ওয়াগফির লানা ওয়ারহামনা, আনতা মাওলানা ফানসুরনা আলাল ক্বাওমিল কাফিরীন।',
      ]),
  Item('সূরা ইখলাস', 'সকাল-সন্ধ্যা তিনবার করে তিন কুল পড়লে সবকিছু থেকে যথেষ্ট হয়ে যায়। ঘুমানোর আগে হাতে ফুঁ দিয়ে শরীরে হাত বুলানো নবী (সা.)-এর আমল।', 'আবু দাউদ, তিরমিযি, সহীহ বুখারি', inlineSurah: 112,
      ucc: [
        'কুল হুওয়াল্লাহু আহাদ',
        'আল্লাহুস সামাদ',
        'লাম ইয়ালিদ ওয়া লাম ইউলাদ',
        'ওয়া লাম ইয়াকুল্লাহু কুফুওয়ান আহাদ',
      ]),
  Item('সূরা ফালাক', 'ইখলাস, ফালাক ও নাস একসাথে সকাল-সন্ধ্যা তিনবার করে পড়ার কথা এসেছে।', 'আবু দাউদ, তিরমিযি', inlineSurah: 113,
      ucc: [
        'কুল আউযু বিরাব্বিল ফালাক্ব',
        'মিন শাররি মা খালাক্ব',
        'ওয়া মিন শাররি গাসিক্বিন ইযা ওয়াক্বাব',
        'ওয়া মিন শাররিন নাফফাসাতি ফিল উক্বাদ',
        'ওয়া মিন শাররি হাসিদিন ইযা হাসাদ',
      ]),
  Item('সূরা নাস', 'ইখলাস, ফালাক ও নাস একসাথে সকাল-সন্ধ্যা তিনবার করে পড়ার কথা এসেছে।', 'আবু দাউদ, তিরমিযি', inlineSurah: 114,
      ucc: [
        'কুল আউযু বিরাব্বিন নাস',
        'মালিকিন নাস',
        'ইলাহিন নাস',
        'মিন শাররিল ওয়াসওয়াসিল খান্নাস',
        'আল্লাযী ইউওয়াসউইসু ফী সুদূরিন নাস',
        'মিনাল জিন্নাতি ওয়ান নাস',
      ]),
  Item('শয়তানের কুমন্ত্রণা থেকে আশ্রয়', 'শয়তানের কুমন্ত্রণা ও তাদের উপস্থিতি থেকে আল্লাহর আশ্রয় চাওয়ার দোয়া, যা আল্লাহ তাআলা নবী (সা.)-কে শিখিয়েছেন।', 'সূরা মুমিনুন',
      refs: ['23:97', '23:98'],
      ucc: ['ওয়া কুর রাব্বি আউযু বিকা মিন হামাযাতিশ শায়াতীন', 'ওয়া আউযু বিকা রাব্বি আই ইয়াহদুরূন']),
  Item('শয়তানের প্ররোচনায় আল্লাহর আশ্রয়', 'শয়তানের প্ররোচনা অনুভব করলে আল্লাহর কাছে আশ্রয় চাওয়ার নির্দেশ।', 'সূরা ফুসসিলাত',
      refs: ['41:36'], ucc: ['ওয়া ইম্মা ইয়ানযাগান্নাকা মিনাশ শাইত্বানি নাযগুন ফাসতাইয বিল্লাহ, ইন্নাহূ হুওয়াস সামীউল আলীম।']),
  Item('কুরআন শিফা ও রহমত', 'কুরআনকে মুমিনদের জন্য শিফা (আরোগ্য) ও রহমত বলা হয়েছে। অসুখে আল্লাহই আরোগ্য দেন।', 'সূরা বনি ইসরাইল ও সূরা শুআরা',
      refs: ['17:82', '26:80'],
      ucc: ['ওয়া নুনায্যিলু মিনাল কুরআনি মা হুওয়া শিফাউঁ ওয়া রাহমাতুল লিল মু\'মিনীনা ওয়া লা ইয়াযীদুয যালিমীনা ইল্লা খাসারা।', 'ওয়া ইযা মারিদতু ফাহুওয়া ইয়াশফীন।']),
];

class DuaPage extends StatelessWidget {
  final AppState s;
  const DuaPage(this.s, {super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(12), children: [
        Text('এখানকার আরবি ও অনুবাদ কুরআন থেকে সরাসরি নেওয়া (alquran.cloud, অনুবাদ: মুহিউদ্দীন খান)। প্রথমবার ইন্টারনেট লাগবে, পরে অফলাইনে চলবে।\nবাংলা উচ্চারণ আনুমানিক; সঠিক তিলাওয়াত যোগ্য ওস্তাদের কাছে শিখে নিন।', style: TextStyle(fontSize: 12, color: mute(context))),
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
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('বাংলা উচ্চারণ আনুমানিক; সঠিক তিলাওয়াত যোগ্য ওস্তাদের কাছে শিখে নিন।', style: TextStyle(fontSize: 12, color: mute(context)))),
        for (final it in ruqyahItems) ItemCard(s, it),
      ]);
}
