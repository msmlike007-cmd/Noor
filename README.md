# নূরনামা — Play Store প্রস্তুতি প্যাকেজ

এই প্যাকেজে আপনার আপলোড করা Flutter সোর্স ফাইলগুলো `lib/`-এ সাজানো হয়েছে। মূল আপলোড করা ফাইলগুলো আলাদা ও অপরিবর্তিত রাখা হয়েছে।

## কী আছে
- `lib/` — অ্যাপের Dart সোর্স; `হাদিস` নামে নতুন পাঠাগার সূচি যুক্ত
- `pubspec.yaml` — Flutter dependencies, version 2.1.1+4
- `setup.py` — launcher assets ও Android notification configuration
- `scripts/set_android_sdk.py` — Android compile/target SDK 36 সেট করে
- `codemagic.yaml` — Google Play-এর জন্য signed AAB build workflow
- `docs/` — Privacy Policy draft, Play Store listing এবং release checklist

## Codemagic build
1. প্যাকেজটি নিজের private Git repository-তে রাখুন অথবা Codemagic-এ upload করুন।
2. প্রকৃত Play Console account owner-এর release keystore Codemagic-এ `nurnama_keystore` নামে configure করতে হবে।
3. Codemagic-এ `nurnama-play-store` workflow চালান।
4. সফল হলে `build/app/outputs/bundle/release/` থেকে `.aab` artifact পাবেন।

**এই ZIP-এ AAB নেই।** এই পরিবেশে Flutter/Dart SDK নেই, তাই এখানে compile বা device test করা যায়নি। Build সফল হওয়া এবং বাস্তব ফোনে পরীক্ষা করা বাধ্যতামূলক।

আজানের অডিও প্যাকেজে নেই। পরে নিজের অনুমোদিত অডিও ফাইল `azan.mp3` বা `audio/azan.mp3` নামে যোগ করে rebuild করা যাবে।
