# LMS Pro — Mobile (Flutter)

تطبيق موبايل بـ Flutter لنفس نظام LMS Pro (نفس الـ .NET 8 API ونفس قاعدة البيانات بتاعة موقع Angular)، بيستخدم **Cubit** فقط لإدارة الحالة (من `flutter_bloc`)، واجهة **إنجليزي بالكامل**، وتنقل عن طريق **Sidebar (Drawer)** بدل الـ bottom bar.

## 1. الإعدادات اللي اتظبطت بالفعل على بيئتك

### أ) JDK
اتحلت خالص. الأوامر اللي شغالة عندك:
```
flutter config --jdk-dir="C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot"
```
لو غيّرت جهاز أو أعدت التثبيت، شغّل الأمر ده تاني بنفس المسار (أو استخدم `Get-ChildItem "C:\Program Files\Eclipse Adoptium" -Directory` عشان تعرف اسم الفولدر بالظبط).

### ب) Gradle / AGP / Kotlin
مظبوطين دلوقتي على نفس الإصدارات اللي شغالة عندك:
- Gradle **8.14.5**
- AGP (Android Gradle Plugin) **8.11.1**
- Kotlin **2.2.20**
- `buildTypes.release`: `isMinifyEnabled = true` و `isShrinkResources = true` (فيه `proguard-rules.pro` جاهز، لو حصل crash في release build بس مش في debug، ده أول مكان تدور فيه)

### ج) عنوان السيرفر (API Base URL)
`lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:53788/api';
```
ده مظبوط بالظبط على البورت اللي بتستخدمه إنت (53788 عن طريق الـ emulator). لو جربت على موبايل حقيقي على نفس الشبكة، غيّره لـ IP جهازك (مثلاً `http://192.168.1.50:53788/api`) وضيف نفس الـ IP في `android/app/src/main/res/xml/network_security_config.xml`.

## 2. تشغيل المشروع
```bash
cd lms_mobile
flutter pub get
flutter run
```

## 3. اللي اتضاف/اتصلح من آخر نسخة

- الإنجليزي بالكامل: مفيش عربي في الواجهة، الخط Inter بدل Cairo، الاتجاه LTR.
- Sidebar navigation: بدل الـ bottom bar، فيه Drawer (بيتفتح من أيقونة الـ hamburger في الـ AppBar أو بسحبة من الحافة) فيه كل الشاشات + زرار Log Out تحت.
- New Session: شاشة كاملة (اختيار المدرب والمجموعة من dropdown، تاريخ ووقت، نوع الجلسة، المحور، مكان/رابط اختياري) بتنادي فعليًا على POST /sessions.
- New Quiz: شاشة فيها question builder ديناميكي (اضافة/حذف أسئلة، اختيار من متعدد أو صح/خطأ، تحديد الإجابة الصحيحة) بتنادي POST /quizzes.
- New Assignment: شاشة بسيطة بتنادي POST /assignments.
- New Group: dialog بسيط (اسم، كود، تاريخ بداية/نهاية) بتنادي POST /groups.
- إصلاح باج التقييم (Grading): كان بيبعت gradeFeedback بدل feedback في PUT /assignments/{id}/submissions/{id}/grade، فكانت ملاحظات التصحيح مش بتتحفظ أبدًا. اتصلح دلوقتي.

## 4. البنية
```
lib/
  core/           # API client (dio + JWT)، تخزين التوكن، الثيم، الـ widgets المشتركة
  models/         # نفس شكل الـ JSON اللي بيرجعه كل Controller في الـ .NET API
  features/
    auth/         # تسجيل الدخول
    dashboard/    # لوحة التحكم (نسخة طالب / نسخة إداري)
    sessions/     # عرض، إنشاء، بدء/إنهاء/إلغاء، تسجيل حضور
    quizzes/      # إنشاء، أداء الاختبار (طالب)، عرض النتائج (إداري)
    assignments/  # إنشاء، تسليم ملف/رابط (طالب)، تصحيح (إداري)
    tickets/      # إنشاء ومحادثة
    groups/       # عرض + إنشاء
    students/     # عرض + إنشاء
    instructors/  # عرض + إنشاء
    profile/      # الحساب، تغيير كلمة المرور
    shell/        # MainShell (الصفحات) + AppSidebar (التنقل)
```

## 5. حاجات لسه مش متضافة (على علمي)
- تعديل جلسة/اختبار/واجب موجود (edit)، أو حذفهم.
- شاشة تعيين منسقين/فرق داخل المجموعة من الموبايل (متاح عرضهم بس).
- تقارير ReportsController التفصيلية (711 سطر منطق) — لسه بس من لوحة تحكم الموقع.

لو احتجت أي حاجة من دول، قولّي.

## 6. اللي اتضاف دلوقتي (تكملة)

- ✅ **Edit Session / Edit Quiz / Edit Assignment**: زرار تعديل (✏️) في الـ AppBar لكل شاشة تفاصيل، بيفتح فورم متعبي بالبيانات الحالية وبيعمل PUT فعلي.
- ✅ **Group management**: من شاشة تفاصيل المجموعة — تعيين/إزالة منسق (Admin بس)، وإنشاء فريق (Team) باختيار الأعضاء وقائد الفريق.
- ✅ **Coordinators**: شاشة كاملة (list + create) ظاهرة للـ Admin بس في الـ sidebar، عشان تقدر تضيف منسقين وبعدين تعينهم على مجموعات.
- ✅ **Reports**: شاشة جديدة في الـ sidebar — الإداري بيختار مجموعة وياخد تقرير حضور/درجات/ملخص (.xlsx)، والطالب بياخد تقرير تقدمه الشخصي (.pdf). الملفات بتتنزل وتتفتح عن طريق الـ share sheet بتاع الموبايل (تقدر تحفظها أو تفتحها في تطبيق تاني).

ملاحظة: لسه مفيش حذف (delete) لجلسة/اختبار/واجب — الباك اند نفسه مفيهوش endpoint حذف لهم أصلاً (بس تعديل/إنشاء)، فده مش نقص في التطبيق.
