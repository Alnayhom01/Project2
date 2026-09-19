# بلاغ

نسخة سطح مكتب (Windows) من نظام **بلاغ** مخصصة لموظفي البلدية، مبنية على نفس Flutter + GetX + Firebase/Firestore وتنظيم المشروع الخاص بتطبيق المواطن، مع توحيد الخط والألوان.

## الصفحات

- **الرئيسية:** تعرض البلاغات التي حالتها `جديد` مع البحث والفلترة وتغيير الحالة.
- **قيد المعالجة:** تعرض البلاغات التي حالتها `قيد المعالجة` مع البحث والفلترة.
- **التقارير:** تعرض ملخص أعداد البلاغات وقائمة البلاغات مع البحث والفلترة.
- **إنشاء تنبيه:** صفحة فارغة حالياً.
- **الأرشيف:** يعرض البلاغات التي حالتها `تم الحل` أو `تم الرفض` مع البحث والفلترة.
- **إضافة موظف:** تظهر لالمدير فقط.

## حالات البلاغ

```text
جديد
قيد المعالجة
تم الحل
تم الرفض
```

## الصلاحيات

الاسم الظاهر في قائمة الصلاحية داخل التطبيق:

```text
مدير
موظف (لا يمكنه إضافة موظف)
موظف (لا يمكنه إضافة موظف، إنشاء تنبيه، تغيير حالة بلاغ)
```

القيم المخزنة داخلياً في Firestore:

```text
admin
employee
simpleEmployee
```

## نفس قاعدة البيانات

يستخدم التطبيق **نفس مشروع Firebase/Firestore** الخاص بتطبيق المواطن، وبالتالي يقرأ نفس مجموعة:

```text
reports
```

ولا ينشئ نسخة ثانية من البلاغات.

يستخدم أيضاً مجموعة جديدة خاصة بموظفي البلدية:

```text
employees
```

شكل مستند الموظف:

```text
employees/{phone}
  name: String
  phone: String
  passwordHash: String       # SHA-256
  role: admin | employee | simpleEmployee
  active: true | false
  createdAt: Timestamp
```

## إنشاء أول مدير نظام

لأن صفحة إضافة الموظفين متاحة للـ `admin` فقط، يجب إنشاء أول مدير مرة واحدة يدوياً في Firestore.

1. شغل الأمر التالي من مجلد المشروع:

```powershell
dart run tools/hash_password.dart "كلمة_مرور_المدير"
```

2. انسخ الناتج وضعه في حقل `passwordHash`.
3. في Firestore أنشئ:

```text
employees/{رقم_هاتف_المدير}
```

مثال:

```text
employees/0912345678
```

4. ضع الحقول التالية:

```text
name          = اسم المدير
phone         = 0912345678
passwordHash  = ناتج الأمر السابق
role          = admin
active        = true
createdAt     = Server Timestamp
```

يوجد أيضاً ملف `firestore_employee_template.json` كمخطط مرجعي.

## التشغيل على Windows

```powershell
flutter pub get
flutter run -d windows
```

ولإنشاء نسخة Windows:

```powershell
flutter build windows
```
