# Tumdak ~ Tamak

Flutter project for the Santal drum-instrument app: **Tumdak**, **Tamak**,
**Octapad**, and **Group Music**. Built to be opened directly as a
FlutLab (flutlab.io) project — and now also GitHub-ready with an automatic
build pipeline (see **"GitHub-এ বিল্ড করা"** below), since FlutLab itself
only does live edit/preview and doesn't produce an installable APK.

## এই আপডেটে যা যোগ হলো
- **EQ এখন সাইড-প্যানেল, পপ-আপ না** (Tumdak ও Tamak): EQ বাটনে চাপ দিলে
  আগের মতো পুরো স্ক্রিন ঢেকে দেওয়া bottom-sheet খোলে না — বরং ডান পাশে
  একটা সরু কন্ট্রোল প্যানেল স্লাইড করে খোলে, আর টাচপ্যাড(গুলো) ছোট হয়ে
  বাম দিকে চলে যায়। যেহেতু এটা আর কিছু ব্লক করে না, তাই একহাতে ফেডার
  (Volume/Tone/Echo/Hall) উপরে-নিচে টানতে টানতে সাথে সাথেই পাশের
  টাচপ্যাডে চেপে শব্দ শুনে টেস্ট করা যায় — ঠিক আসল সাউন্ড মিক্সারের মতো।
  Tumdak-এ দুইটা চ্যানেল (বাম/ডান প্যাড) থাকায় প্যানেলের উপরে একটা ছোট
  ট্যাব দিয়ে কোনটা এডজাস্ট করছেন বেছে নেওয়া যায়। বন্ধ করতে প্যানেলের ✕
  বা আবার EQ বাটনে চাপ দিন। (কোড: `lib/widgets/eq_side_panel.dart`)
- **Octapad → "সাউন্ড প্যাকেজ বাছাই করুন" লিস্ট আরও স্পষ্ট**: এই বাটনটা
  (উপরের নেভিগেশন সারিতে prev/next তীরের পাশে "Tune" আইকন, বা মাঝের
  প্যাচ-নামের বক্সে চাপ দিলেও খোলে) আগে থেকেই ছিল, তবে এখন —
  - শিরোনামে মোট কতগুলো প্যাচ প্যাকেজ আছে তা দেখায় ("মোট ৬ ধরনের প্যাচ
    প্যাকেজ আছে"),
  - প্রতিটা প্যাকেজের পাশে একটা ▶ (শুনুন) বাটন আছে, যেটাতে চাপ দিলে
    পুরোপুরি সিলেক্ট না করেই ওই প্যাকেজের একটা নমুনা শব্দ বাজিয়ে শোনা
    যায় — তারপর পছন্দ হলে নামের উপর চাপ দিয়ে সিলেক্ট করুন।

## কীভাবে FlutLab-এ চালাবেন
1. flutlab.io তে নতুন প্রজেক্ট বানিয়ে, এই পুরো ফোল্ডারের কন্টেন্ট (lib/, assets/,
   pubspec.yaml) আপলোড/ইমপোর্ট করুন — অথবা zip ফাইলটা সরাসরি ইমপোর্ট অপশনে দিন।
2. `pubspec.yaml`-এ থাকা `audioplayers` প্যাকেজ পাওয়ার জন্য প্রথমবার
   "Get Packages" / build চালাতে হবে (ইন্টারনেট লাগবে)।
3. Run করলেই ল্যান্ডস্কেপ হোম পেজ আসবে।

## ফোল্ডার গঠন
```
lib/
  main.dart              -> app entry, landscape lock, sound preload
  theme.dart              -> colors, gradients, GoldText (shared gold title style)
  services/
    sound_service.dart    -> centralized low-latency sound playback
  widgets/
    app_top_bar.dart       -> reusable maroon+gold top bar (every page)
    app_side_drawer.dart   -> hamburger side menu
    emboss_square.dart     -> 3D embossed square block (home page + reused style)
    touch_pad.dart          -> tappable drum head image with instant sound
  pages/
    home_page.dart          -> 4 instrument blocks
    tumdak_page.dart        -> 2 touchpads over blurred tumdak_bg
    tamak_page.dart         -> 1 touchpad, dark maroon background
    octapad_page.dart       -> 8-pad grid
    group_music_page.dart   -> WiFi/Hotspot jam session UI (mocked networking)
assets/
  images/                 -> backgrounds, touchpads, icons (as you supplied)
  sounds/                 -> PLACEHOLDER synthesized .wav files
```

## এখন যেভাবে সাউন্ড কাজ করছে (গুরুত্বপূর্ণ)
এখনো বাস্তব মাদল/তুমদাক/তামাক রেকর্ডিং নেই, তাই `assets/sounds/` ফোল্ডারে আমি
সাধারণ সিন্থেসাইজড প্লেসহোল্ডার শব্দ বসিয়ে দিয়েছি, শুধু যাতে অ্যাপটা এখনই
টাচ-রেসপন্সিভভাবে টেস্ট করা যায়:

| ফাইল | ব্যবহার হয় |
|---|---|
| `tumdak_left.wav` | Tumdak পেজ, বাম (মোটা) টাচপ্যাড — প্লেসহোল্ডার (এখনো সিন্থেসাইজড) |
| `tumdak_right.wav` | Tumdak পেজ, ডান (চিকন) টাচপ্যাড — প্লেসহোল্ডার (এখনো সিন্থেসাইজড) |
| `tamak.wav` | Tamak পেজ — প্লেসহোল্ডার (এখনো সিন্থেসাইজড) |
| `santali_*.wav` | Octapad → **Santali** প্যাচ (`santali.Patch.mcn` থেকে) |
| `sohorai_*.wav` | Octapad → **Dong Sohorai** প্যাচ (`dong sohorai.mcn` থেকে) — ⚠️ নিচের নোট দেখুন |

**Octapad এখন মাল্টি-প্যাচ সাপোর্ট করে:** `lib/models/octapad_patch.dart`-এ
একটা `OctapadPatch` লিস্ট আছে। Tune বাটনে চাপলে প্যাচগুলোর একটা লিস্ট
দেখাবে, বাছাই করলেই সব ৮টা প্যাড নতুন সাউন্ডে বদলে যাবে। নতুন প্যাচ যোগ
করতে: (১) `assets/sounds/`-এ ৮টা wav ফাইল বসান, (২)
`sound_service.dart`-এর `_assetFor`-এ নাম যোগ করুন, (৩)
`octapad_patch.dart`-এর `kOctapadPatches` লিস্টে একটা নতুন `OctapadPatch`
এন্ট্রি যোগ করুন — কোনো UI কোড বদলাতে হবে না, Tune লিস্টে এমনিতেই দেখাবে।

**⚠️ `sohorai_*.wav` নিয়ে জরুরি নোট:** আপনার দেওয়া `dong sohorai.mcn`
ফোল্ডারের ভেতরের টেক্সট নোট (`Best Dhol patch Opms.txt` ইত্যাদি) থেকে
দেখা যায় এই প্যাচটা মূলত **"Octapad Master Sachin"** নামে একজন তৃতীয়
পক্ষ octapatch.in সাইটে পাবলিশ করেছিলেন — এটা আপনার নিজের রেকর্ড করা বা
লাইসেন্স করা সাউন্ড না। এখন টেস্টিংয়ের সুবিধার জন্য এটা যোগ করে দিয়েছি
(যেন সত্যিকারের ভিন্ন একটা সাউন্ড দিয়ে অ্যাপ টেস্ট করা যায়), কিন্তু
**অ্যাপ পাবলিশ করার আগে** হয় ওই ক্রিয়েটরের অনুমতি নিতে হবে, নয়তো
`assets/sounds/sohorai_*.wav` ফাইলগুলো আপনার নিজের অধিকার আছে এমন সাউন্ড
দিয়ে replace করতে হবে। zip-এ থাকা আরেকটা ফোল্ডার `DONG 73.mcn` বাদ
দিয়েছি — সেটা একই প্যাচ, কিন্তু hi-hat (chat/ohat) ফাইল দুটো ভাঙা/খালি
ছিল। zip-এর "Tutorial" নামের `.trk` ফাইলগুলো সব ০ বাইট (খালি) — ওখান
থেকে ব্যবহারযোগ্য কিছু ছিল না।

"বাংলাদেশ/ইন্ডিয়ান মিউজিকে বেশি ব্যবহৃত সব ধরনের প্রফেশনাল সাউন্ড
প্যাকেজ" যোগ করার ব্যাপারে — সাধারণ ফ্রি/রয়্যালটি-ফ্রি সাউন্ড লাইব্রেরিতে
authentic dhol/nagara/tabla অক্টাপ্যাড কিট প্রায় পাওয়াই যায় না; বাস্তবে
এগুলো হয় নিজে রেকর্ড করতে হয়, নয়তো (উপরের মতো) কোনো নির্দিষ্ট
প্রকাশকের কাছ থেকে লাইসেন্স নিয়ে ব্যবহার করতে হয়। আপনি চাইলে এই বিষয়ে
পরে আলাদা করে বসা যাবে।

Tumdak ও Tamak-এর সাউন্ড এখনো প্লেসহোল্ডার — আপনি বলেছিলেন সেগুলোর জন্য
আলাদা করে রেকর্ডিং জোগাড় করছেন।

**যখন আরও রিয়েল রেকর্ডিং রেডি হবে:** ঠিক এই একই নামে (.wav) ফাইল
`assets/sounds/`-এ বসিয়ে দিলেই হবে — কোনো কোড বদলাতে হবে না। কারণ
`sound_service.dart`-এ সাউন্ড আইডি থেকে ফাইলপাথ ম্যাপ করা আছে
(`_assetFor`), আসল ফাইল একই নামে replace করলেই চলবে।

`SoundService` `PlayerMode.lowLatency` ব্যবহার করে (Android-এ SoundPool
ভিত্তিক) যাতে টাচ করার সাথে সাথেই শব্দ বাজে, বিলম্ব ছাড়াই।

## নতুন যা যোগ হলো (এই আপডেটে)
- **আইকন বাটন থেকে গোল্ডেন সার্কেল বাদ** — টপ বারের সব আইকন (Edit/EQ/
  Music/Settings/Record/Profile/Share ইত্যাদি) এখন সরাসরি, বড়, স্পষ্ট
  দেখায় — কোনো বাইরের রিং/সার্কেল ফ্রেম ছাড়া (`app_top_bar.dart`)।
- **Tumdak → Edit**: বাম/ডান টাচপ্যাড ইচ্ছামতো swap করা যায়
  (`pad_edit_sheet.dart`), পছন্দ ফোনে সেভ থাকে — পরের বার অ্যাপ খুললেও
  মনে রাখে।
- **EQ (Tumdak ও Tamak)**: popup sheet-এ Volume, Tone (মোটা↔চিকন), Echo,
  Hall/Reverb — ৪টা স্লাইডার, টেনে ধরার সাথে সাথেই বাজিয়ে টেস্ট করা যায়
  (`eq_sheet.dart`, `sound_service.dart`)। `audioplayers`-এ সত্যিকারের
  multi-band DSP নেই, তাই Tone আসলে playback-rate বদলে (ধীরে = মোটা,
  দ্রুত = চিকন), আর Echo/Reverb কয়েকটা কমতে-থাকা repeat বাজিয়ে বাস্তবের
  কাছাকাছি অনুভূতি তৈরি করে — সত্যিকারের রুম-রিভার্ব না হলেও ফোনের
  স্পিকারে স্পষ্ট শোনা যায়। সব সেটিং সেভ থাকে (SharedPreferences)।
- **Settings**: নতুন সাউন্ড প্রজেক্ট add/select/delete করার পূর্ণাঙ্গ
  পেজ, প্লাস haptic টগল (`settings_page.dart`)।
- **Record**: মাইক দিয়ে সত্যিকারের রেকর্ডিং (`record` প্যাকেজ), প্রিভিউ
  শোনা, তারপর ফোনের যেকোনো ফোল্ডারে সেভ (`record_sheet.dart`) —
  Tumdak/Tamak/Octapad/Group Music সব জায়গায় কাজ করে। **Android ৬ +
  iOS-এ প্রথমবার চাইলে মাইক পারমিশন চাইবে** — অনুমতি দিতে হবে।
- **Music**: Tumdak ও Tamak-এ নতুন Music বাটন — গান বেছে নিয়ে বাজিয়ে/
  পজ করে সাথে বাজানো যায় (`music_sheet.dart`)।
- **Profile**: এখন সচল — নাম, auto-generated Unique ID (যেমন
  `TT-482913`), প্রিয় বাদ্যযন্ত্র, "সম্পর্কে" — সব ফোনে সেভ থাকে
  (`profile_page.dart`)।
- **Share**: হোম পেজ ও সাইড ড্রয়ার থেকে — ফোনের নেটিভ শেয়ার শিট খোলে,
  WhatsApp/Messenger/যেকোনো ইনস্টল করা অ্যাপে সরাসরি শেয়ার করা যায়
  (`share_plus` প্যাকেজ)।
- **Group Music**: "Find" চাপলে আশেপাশের ডিভাইস দেখায়, প্রতিটার পাশে
  টিকমার্ক (checkbox) দিয়ে বেছে "Connect" করা যায়; যে ফোন সেশন শুরু
  করে/সবাইকে কানেক্ট করে সেটাই "মেইন / OUTPUT" ব্যাজ পায়; Invite বাটন
  দিয়ে বন্ধুদের শেয়ার করে ডাকা যায়; প্রোফাইলের নাম এখানে দেখায়।
- সাইড ড্রয়ারের সব আইটেম (Home/Profile/Settings/Share/Help) এখন আসল
  পেজে নিয়ে যায় — আর শুধু ড্রয়ার বন্ধ করে না।

## এখনো যা বাকি / বাস্তবে করার আগে জানা দরকার
- **Group Music-এর real networking**: এখনো ডিভাইস discovery mock করা
  (`_startSearch()` ফাংশনে টাইমার দিয়ে ৩টা কাল্পনিক ফোন দেখানো হয়)।
  বাস্তব ডিভাইস-টু-ডিভাইস কানেকশন ও অডিও সিঙ্ক করতে
  `nearby_connections` বা `flutter_p2p_connection`-এর মতো প্যাকেজ লাগবে,
  আর সেটা আসল ফোনে টেস্ট করতে হবে (এমুলেটরে ঠিকমতো টেস্ট করা কঠিন)। UI
  ও পুরো ফ্লো (find → tick করে যোগ করা → main/output badge) রেডি আছে,
  শুধু ভেতরের নেটওয়ার্কিং অংশ বসাতে হবে।
- **EQ বাস্তবতা**: উপরে যেমন বলা হলো, Echo/Reverb আসল DSP effect না —
  আসল রুম-রিভার্বের জন্য native audio-effect প্লাগইন (যেমন
  `flutter_soloud` বা platform-channel দিয়ে) লাগবে। এখনকার সংস্করণ
  চেষ্টা/শুনতে ভালো লাগার মতো একটা কার্যকর approximation।
- **রেকর্ডিং সেভ (Android/iOS)** — যাচাই করা হয়েছে ও নিশ্চিত: Android-এ
  `bytes` না দিলে `saveFile()` ক্র্যাশ/null রিটার্ন করে (file_picker-এর
  known ইস্যু), তাই কোড bytes সহ কল করে। iOS-এ আবার `bytes`-এর কোনো
  প্রভাব নেই — শুধু path রিটার্ন করে, অ্যাপকেই bytes লিখতে হয়। কোড এই
  দুটো ক্ষেত্রেই সঠিকভাবে handle করে (`record_sheet.dart`-এ `_save()`
  ফাংশন)। `file_picker: ^8.1.2` পিন করা আছে যেন ভবিষ্যতে v12-এর
  breaking change (bytes বাধ্যতামূলক করা) হুট করে না চলে আসে।
- সাউন্ড ফাইল এখনো প্লেসহোল্ডার (উপরে যেমন আগে বলা হয়েছিল) — আসল
  রেকর্ডিং রেডি হলে একই নামে replace করলেই হবে।
- ছবিগুলো hi-res হওয়ায় প্রথমবার build একটু সময় নিতে পারে — চাইলে পরে
  compress করে দেওয়া যাবে।

## GitHub-এ বিল্ড করা (APK ডাউনলোড করার জন্য)

আপনি বলেছিলেন FlutLab দিয়ে শুধু এডিট/প্রিভিউ করবেন, আর আসল বিল্ড (APK)
GitHub দিয়ে করবেন — সেই জন্য এই প্রজেক্টে দুটো GitHub Actions workflow
যোগ করা হয়েছে (`.github/workflows/`), কোনো টাকা বা আলাদা সার্ভার লাগবে
না, GitHub নিজেই ফ্রি বিল্ড করে দেবে।

### ১. প্রথমবার GitHub-এ তোলা
```bash
cd tumdak_tamak_app
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<আপনার-ইউজারনেম>/<রিপো-নাম>.git
git push -u origin main
```
(GitHub-এ আগে থেকে একটা খালি রিপো বানিয়ে নিন — README/gitignore ছাড়া।)

### ২. প্রতিটা push-এ অটো বিল্ড (`build.yml`)
`main` ব্র্যাঞ্চে push বা Pull Request দিলেই GitHub নিজে থেকে APK বিল্ড
করবে। ম্যানুয়ালি চালাতে চাইলে: GitHub রিপোর **Actions** ট্যাব →
**Build Android APK** → **Run workflow**।

বিল্ড শেষ হলে সেই workflow run-এর পাতার নিচে **Artifacts** অংশে
`tumdak-tamak-debug-apk` ও `tumdak-tamak-release-apk` নামে দুটো ZIP
পাবেন — ডাউনলোড করে ভেতরের `.apk` ফাইলটা ফোনে ইনস্টল করতে পারবেন
(প্রথমবার "Unknown sources / Install unknown apps" অনুমতি দিতে হতে
পারে)।

### ৩. ভার্সন রিলিজ করে সরাসরি ডাউনলোড লিংক পাওয়া (`release.yml`)
কোনো ভার্সনকে "পাকা" করে GitHub Release হিসেবে APK-সহ পাবলিশ করতে চাইলে
একটা ট্যাগ push করুন:
```bash
git tag v1.0.0
git push origin v1.0.0
```
এতে GitHub Actions রিলিজ APK বানিয়ে সরাসরি রিপোর **Releases** পাতায়
জুড়ে দেবে — সেখান থেকে যে কেউ এক ক্লিকে `.apk` ডাউনলোড করতে পারবে, কোনো
GitHub লগইন বা Actions ট্যাব ঘাঁটাঘাঁটির দরকার নেই।

### গুরুত্বপূর্ণ কারিগরি নোট
- **Gradle wrapper**: FlutLab থেকে এক্সপোর্ট করা zip-এ
  `android/gradlew` / `gradlew.bat` / `gradle-wrapper.jar` (এক্সিকিউটেবল
  ফাইলগুলো) বাদ পড়ে যায় — এই জন্য দুটো workflow-ই বিল্ডের আগে
  `gradle wrapper --gradle-version 7.6.3` চালিয়ে সেগুলো নিজে থেকে আবার
  বানিয়ে নেয় (`android/gradle/wrapper/gradle-wrapper.properties`-এ
  ভার্সনটা আগে থেকেই ঠিক করা আছে)। নিজের কম্পিউটারে (GitHub ছাড়া) লোকাল
  বিল্ড করতে চাইলে একই কমান্ড একবার `android/` ফোল্ডারে গিয়ে চালিয়ে
  নিন, তারপর `flutter build apk` কাজ করবে।
- **Flutter ভার্সন পিন করা আছে** (`FLUTTER_VERSION: "3.19.6"`
  workflow ফাইলে) — যাতে ভবিষ্যতে নতুন Flutter ভার্সন এসে হঠাৎ বিল্ড
  ভেঙে না দেয়। পরে ইচ্ছাকৃতভাবে আপগ্রেড করতে চাইলে এই একটা জায়গায়
  ভার্সন নম্বর বদলে দিলেই হবে।
- **সাইনিং**: `android/app/build.gradle`-এ এখনো release বিল্ড ডিবাগ-কী
  দিয়ে সাইন হয় (নিজে টেস্ট করার জন্য এটা ঠিক আছে)। **Play Store-এ
  পাবলিশ করার আগে** নিজের একটা আপলোড-কিস্টোর বানিয়ে
  `android/key.properties` + `signingConfigs` সেটআপ করতে হবে — এটা
  এখনো করা হয়নি, চাইলে সেটাও পরে বসিয়ে দেওয়া যাবে।
- **iOS**: `build.yml`-এ একটা `build-ios-unsigned` job আছে যেটা শুধু
  যাচাই করে iOS সাইড কম্পাইল হচ্ছে কিনা (কোনো `.ipa` তৈরি করে না, কারণ
  তার জন্য পেইড Apple Developer সাইনিং সার্টিফিকেট লাগে যেটা আমার কাছে
  নেই)। এটা fail হলেও মূল Android বিল্ডে কোনো প্রভাব পড়বে না
  (`continue-on-error: true`)।

## রঙ ও ফন্ট
`lib/theme.dart`-এ সব রঙ (`AppColors`) ও গোল্ড টাইটেল স্টাইল (`GoldText`)
একজায়গায় রাখা, যাতে পুরো অ্যাপের লুক ধীরে ধীরে আরও প্রফেশনাল করার সময়
প্রতিটা পেজ আলাদা করে না ঘেঁটে শুধু এই একটা ফাইল বদলালেই চলে।
