part of 'main.dart';

// ═════════════ Hadith library directory ═════════════
// Links to publishers/maintainers; no protected database is copied into the app.
class HadithCollection {
  final String title;
  final String subtitle;
  final String source;
  final String url;
  const HadithCollection({required this.title, required this.subtitle, required this.source, required this.url});
}

const hadithCollections = <HadithCollection>[
  HadithCollection(title: 'সহিহ আল-বুখারি', subtitle: 'ইমাম মুহাম্মদ ইবন ইসমাঈল আল-বুখারি (রহ.)', source: 'Sunnah.com', url: 'https://sunnah.com/bukhari'),
  HadithCollection(title: 'সহিহ মুসলিম', subtitle: 'ইমাম মুসলিম ইবন আল-হাজ্জাজ (রহ.)', source: 'Sunnah.com', url: 'https://sunnah.com/muslim'),
  HadithCollection(title: 'সুনান আবু দাউদ', subtitle: 'ইমাম আবু দাউদ (রহ.)', source: 'Sunnah.com', url: 'https://sunnah.com/abudawud'),
  HadithCollection(title: 'জামে আত-তিরমিজি', subtitle: 'ইমাম আত-তিরমিজি (রহ.)', source: 'Sunnah.com', url: 'https://sunnah.com/tirmidhi'),
  HadithCollection(title: 'সুনান আন-নাসাঈ', subtitle: 'ইমাম আন-নাসাঈ (রহ.)', source: 'Sunnah.com', url: 'https://sunnah.com/nasai'),
  HadithCollection(title: 'সুনান ইবন মাজাহ', subtitle: 'ইমাম ইবন মাজাহ (রহ.)', source: 'Sunnah.com', url: 'https://sunnah.com/ibnmajah'),
  HadithCollection(title: 'মুয়াত্তা ইমাম মালিক', subtitle: 'ইমাম মালিক ইবন আনাস (রহ.)', source: 'Sunnah.com', url: 'https://sunnah.com/malik'),
  HadithCollection(title: 'আন-নওয়াবীর ৪০ হাদিস', subtitle: 'ইমাম ইয়াহইয়া আন-নওয়াবী (রহ.) সংকলিত', source: 'Sunnah.com', url: 'https://sunnah.com/nawawi40'),
];

class HadithPage extends StatelessWidget {
  final AppState s;
  const HadithPage(this.s, {super.key});

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ওয়েবসাইট খোলা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করুন।')),
      );
    }
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
                  'নিচের গ্রন্থগুলো তাদের অনলাইন পাঠে খুলবে। হাদিস পড়ার সময় গ্রন্থ, অধ্যায়, হাদিস নম্বর এবং উল্লেখিত মান মিলিয়ে নিন।',
                  style: TextStyle(height: 1.55),
                ),
                const SizedBox(height: 8),
                Text(
                  'এই সংস্করণে পূর্ণ বাংলা হাদিস ডেটাবেস অ্যাপের ভেতরে নেই। তালিকাটি অফলাইনে দেখা যাবে, কিন্তু মূল হাদিস পড়তে ইন্টারনেট লাগবে।',
                  style: TextStyle(fontSize: 12, color: mute(context), height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        for (final book in hadithCollections)
          Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: green2, child: const Icon(Icons.auto_stories, color: Colors.white)),
              title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${book.subtitle}\nউৎস: ${book.source}', style: const TextStyle(height: 1.45)),
              isThreeLine: true,
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _open(context, book.url),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('বাংলা ইসলামিক পাঠ', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                  'HadithBD-তে বাংলা হাদিস ও ব্যাখ্যা পাওয়া যায়। তাদের ডিজিটাল কনটেন্ট লিখিত অনুমতি ছাড়া ব্যাপকভাবে কপি বা অ্যাপে সংরক্ষণ করা যাবে না।',
                  style: TextStyle(height: 1.5),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _open(context, 'https://www.hadithbd.com/'),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('HadithBD ওয়েবসাইট খুলুন'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
