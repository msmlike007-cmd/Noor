part of 'main.dart';

// ═════════════ Hadith: একবার ডাউনলোড করলে অফলাইনে পড়া যায় ═════════════
// হাদিসের ডেটা অ্যাপের ভেতরে বান্ডেল করা নেই। ব্যবহারকারী ডাউনলোড করলে ফোনে সংরক্ষিত হয়।
// উৎস: Hadith API (github.com/fawazahmed0/hadith-api), আরবি ও বাংলা এডিশন hadithnumber ধরে মেলানো হয়।
class HadithBook {
  final String id, title, sub, ara, ben;
  const HadithBook(this.id, this.title, this.sub, this.ara, this.ben);
}

const hadithBooks = <HadithBook>[
  HadithBook('bukhari', 'সহিহ আল-বুখারি', 'ইমাম মুহাম্মদ ইবন ইসমাঈল আল-বুখারি (রহ.)', 'ara-bukhari', 'ben-bukhari'),
  HadithBook('muslim', 'সহিহ মুসলিম', 'ইমাম মুসলিম ইবন আল-হাজ্জাজ (রহ.)', 'ara-muslim', 'ben-muslim'),
  HadithBook('abudawud', 'সুনান আবু দাউদ', 'ইমাম আবু দাউদ (রহ.)', 'ara-abudawud', 'ben-abudawud'),
  HadithBook('tirmidhi', 'জামে আত-তিরমিজি', 'ইমাম আত-তিরমিজি (রহ.)', 'ara-tirmidhi', 'ben-tirmidhi'),
  HadithBook('nasai', 'সুনান আন-নাসাঈ', 'ইমাম আন-নাসাঈ (রহ.)', 'ara-nasai', 'ben-nasai'),
  HadithBook('ibnmajah', 'সুনান ইবন মাজাহ', 'ইমাম ইবন মাজাহ (রহ.)', 'ara-ibnmajah', 'ben-ibnmajah'),
  HadithBook('malik', 'মুয়াত্তা ইমাম মালিক', 'ইমাম মালিক ইবন আনাস (রহ.)', 'ara-malik', 'ben-malik'),
  HadithBook('nawawi', 'আন-নওয়াবীর ৪০ হাদিস', 'ইমাম ইয়াহইয়া আন-নওয়াবী (রহ.) সংকলিত', 'ara-nawawi', 'ben-nawawi'),
];

class HadithData {
  final List<List<String>> items; // [নম্বর, আরবি, বাংলা, মান]
  final bool hasBn;
  HadithData(this.items, this.hasBn);
}

dynamic _decodeJson(String s) => jsonDecode(s);

/// আরবি ও বাংলা এডিশন মিলিয়ে ছোট একটি ফাইল বানায় (আলাদা isolate-এ চলে)
String _mergeHadith(List<String> a) {
  final ar = jsonDecode(a[0]) as Map;
  final bnMap = <String, String>{};
  if (a[1].isNotEmpty) {
    final b = jsonDecode(a[1]) as Map;
    for (final h in (b['hadiths'] as List)) {
      final t = '${h['text'] ?? ''}'.trim();
      if (t.isNotEmpty) bnMap['${h['hadithnumber']}'] = t;
    }
  }
  final items = <List<String>>[];
  for (final h in (ar['hadiths'] as List)) {
    final n = '${h['hadithnumber']}';
    final text = '${h['text'] ?? ''}'.trim();
    if (text.isEmpty) continue;
    var g = '';
    final gr = h['grades'];
    if (gr is List && gr.isNotEmpty && gr[0] is Map) {
      final x = gr[0] as Map;
      final nm = '${x['name'] ?? ''}'.trim();
      g = '${x['grade'] ?? ''}'.trim();
      if (g.isNotEmpty && nm.isNotEmpty) g = '$g ($nm)';
    }
    items.add([n, text, bnMap[n] ?? '', g]);
  }
  return jsonEncode({'bn': bnMap.isNotEmpty, 'items': items});
}

String _gradeBn(String g) => g
    .replaceAll('Sahih', 'সহীহ')
    .replaceAll('Hasan', 'হাসান')
    .replaceAll("Da'if", 'যঈফ')
    .replaceAll('Daif', 'যঈফ')
    .replaceAll('Maudu', 'মাওযু');

class HadithStore {
  static const hosts = [
    'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/',
    'https://raw.githubusercontent.com/fawazahmed0/hadith-api/1/editions/',
  ];

  static Future<File> _file(String id) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/hadith_$id.json');
  }

  static Future<bool> has(String id) async => (await _file(id)).exists();

  static Future<void> remove(String id) async {
    final f = await _file(id);
    if (await f.exists()) await f.delete();
  }

  /// null = সব জায়গায় 404 (এডিশনটি নেই); অন্য যেকোনো সমস্যায় exception
  static Future<String?> _get(String edition) async {
    var all404 = true;
    Object? last;
    for (final h in hosts) {
      for (final ext in ['.min.json', '.json']) {
        try {
          final r = await http.get(Uri.parse('$h$edition$ext')).timeout(const Duration(seconds: 180));
          if (r.statusCode == 200) return utf8.decode(r.bodyBytes);
          if (r.statusCode != 404) all404 = false;
          last = 'http ${r.statusCode}';
        } catch (e) {
          all404 = false;
          last = e;
        }
      }
    }
    if (all404) return null;
    throw Exception('$last');
  }

  /// ফেরত দেয়: বাংলা অনুবাদ পাওয়া গেছে কি না
  static Future<bool> download(HadithBook b, void Function(String) step) async {
    step('আরবি নামানো হচ্ছে…');
    final a = await _get(b.ara);
    if (a == null) throw Exception('গ্রন্থটি পাওয়া যায়নি');
    step('বাংলা অনুবাদ নামানো হচ্ছে…');
    final t = await _get(b.ben);
    step('সংরক্ষণ করা হচ্ছে…');
    final out = await compute(_mergeHadith, [a, t ?? '']);
    final f = await _file(b.id);
    await f.writeAsString(out);
    return t != null;
  }

  static Future<HadithData> load(String id) async {
    final f = await _file(id);
    final m = await compute(_decodeJson, await f.readAsString()) as Map;
    final items = (m['items'] as List).map((e) => (e as List).map((x) => '$x').toList()).toList();
    return HadithData(items, m['bn'] == true);
  }
}

class HadithPage extends StatefulWidget {
  final AppState s;
  const HadithPage(this.s, {super.key});
  @override
  State<HadithPage> createState() => _HadithState();
}

class _HadithState extends State<HadithPage> {
  final have = <String, bool>{};
  final busy = <String, String>{};
  final err = <String, String>{};

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    for (final b in hadithBooks) {
      have[b.id] = await HadithStore.has(b.id);
    }
    if (mounted) setState(() {});
  }

  Future<void> _download(HadithBook b) async {
    setState(() {
      busy[b.id] = 'শুরু হচ্ছে…';
      err.remove(b.id);
    });
    var bnOk = true;
    try {
      bnOk = await HadithStore.download(b, (t) {
        if (mounted) setState(() => busy[b.id] = t);
      });
      have[b.id] = true;
    } catch (_) {
      err[b.id] = 'ডাউনলোড হয়নি। ইন্টারনেট পরীক্ষা করে আবার চেষ্টা করুন।';
    }
    if (!mounted) return;
    setState(() => busy.remove(b.id));
    if (!bnOk && have[b.id] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('এই গ্রন্থের বাংলা অনুবাদ পাওয়া যায়নি, শুধু আরবি সংরক্ষিত হয়েছে।')));
    }
  }

  Future<void> _delete(HadithBook b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(b.title),
        content: const Text('ডাউনলোড করা হাদিস ফোন থেকে মুছে ফেলবেন? পরে আবার ডাউনলোড করা যাবে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('না')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('মুছুন')),
        ],
      ),
    );
    if (ok != true) return;
    await HadithStore.remove(b.id);
    if (mounted) setState(() => have[b.id] = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.menu_book, color: gold, size: 28),
                  SizedBox(width: 9),
                  Expanded(child: Text('হাদিস পাঠাগার', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 8),
                const Text(
                  'যে গ্রন্থ পড়তে চান তার পাশে "ডাউনলোড" চাপুন। একবার নামালে ইন্টারনেট ছাড়াই অ্যাপের ভেতরে পড়া যাবে। প্রতিটি হাদিসের আরবি ও অনুবাদ আলাদাভাবে কপি বা শেয়ার করা যায়।',
                  style: TextStyle(height: 1.55),
                ),
                const SizedBox(height: 8),
                Text(
                  'গ্রন্থগুলো বড়, তাই ওয়াইফাইতে ডাউনলোড করা ভালো। হাদিসের উচ্চারণ এই ডেটায় নেই। হাদিসের মান (সহীহ/হাসান/যঈফ) থাকলে দেখানো হয়; শেয়ার করার আগে মান ও সূত্র মিলিয়ে নিন।',
                  style: TextStyle(fontSize: 12, color: mute(context), height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        for (final b in hadithBooks)
          Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: green2, child: const Icon(Icons.auto_stories, color: Colors.white)),
              title: Text(b.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${b.sub}\n${busy[b.id] ?? err[b.id] ?? (have[b.id] == true ? 'ডাউনলোড করা আছে, অফলাইনে পড়ুন' : 'ডাউনলোড করা হয়নি')}', style: const TextStyle(height: 1.45)),
              isThreeLine: true,
              trailing: busy.containsKey(b.id)
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : have[b.id] == true
                      ? IconButton(tooltip: 'মুছুন', icon: const Icon(Icons.delete_outline), onPressed: () => _delete(b))
                      : FilledButton.tonalIcon(onPressed: () => _download(b), icon: const Icon(Icons.download, size: 18), label: const Text('ডাউনলোড')),
              onTap: have[b.id] == true && !busy.containsKey(b.id) ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => HadithReaderPage(widget.s, b))) : null,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('উৎস: Hadith API (github.com/fawazahmed0/hadith-api)। ডাউনলোড করা হাদিস শুধু আপনার ফোনে থাকে।', style: TextStyle(fontSize: 11, color: mute(context)), textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class HadithReaderPage extends StatefulWidget {
  final AppState s;
  final HadithBook book;
  const HadithReaderPage(this.s, this.book, {super.key});
  @override
  State<HadithReaderPage> createState() => _ReaderState();
}

class _ReaderState extends State<HadithReaderPage> {
  late final Future<HadithData> f = HadithStore.load(widget.book.id);
  String q = '';

  List<List<String>> _filter(List<List<String>> all) {
    final t = q.trim();
    if (t.isEmpty) return all;
    final numq = t.replaceAllMapped(RegExp('[০-৯]'), (m) => '${'০১২৩৪৫৬৭৮৯'.indexOf(m[0]!)}');
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(numq)) return all.where((e) => e[0] == numq).toList();
    if (RegExp('[؀-ۿ]').hasMatch(t)) {
      final pq = _plain(t);
      return all.where((e) => _plain(e[1]).contains(pq)).toList();
    }
    final lq = t.toLowerCase();
    return all.where((e) => e[2].toLowerCase().contains(lq)).toList();
  }

  Widget tile(AppState s, List<String> e) {
    final ref = '${widget.book.title}, হাদিস নং ${bn(e[0])}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: green2, borderRadius: BorderRadius.circular(12)),
              child: Text('হাদিস নং ${bn(e[0])}', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const Spacer(),
            if (e[3].isNotEmpty) Flexible(child: Text('মান: ${_gradeBn(e[3])}', style: TextStyle(fontSize: 12, color: pri(context)), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          SelectableText(e[1], textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: TextStyle(fontSize: s.arSize, height: 1.9)),
          if (e[2].isNotEmpty) ...[
            const Divider(),
            SelectableText(e[2], style: const TextStyle(fontSize: 16, height: 1.55)),
          ],
          CopyBar(ar: e[1], tr: e[2], ref: ref),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return ListenableBuilder(
      listenable: s,
      builder: (_, __) => Scaffold(
        appBar: AppBar(title: Text(widget.book.title), actions: [
          IconButton(onPressed: () => s.setArSize(s.arSize - 2), icon: const Icon(Icons.text_decrease)),
          IconButton(onPressed: () => s.setArSize(s.arSize + 2), icon: const Icon(Icons.text_increase)),
        ]),
        body: FutureBuilder<HadithData>(
          future: f,
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snap.hasError || snap.data == null) {
              return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('হাদিস পড়া যায়নি। হাদিস পাঠাগারে গিয়ে মুছে আবার ডাউনলোড করুন।', textAlign: TextAlign.center)));
            }
            final d = snap.data!;
            final list = _filter(d.items);
            return Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: TextField(
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'হাদিস নম্বর বা বাংলা/আরবি শব্দ খুঁজুন', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                  onChanged: (v) => setState(() => q = v),
                ),
              ),
              if (!d.hasBn)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text('এই গ্রন্থের বাংলা অনুবাদ পাওয়া যায়নি, শুধু আরবি আছে।', style: TextStyle(fontSize: 12, color: mute(context))),
                ),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('কিছু পাওয়া যায়নি'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: list.length,
                        itemBuilder: (_, i) => tile(s, list[i]),
                      ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
