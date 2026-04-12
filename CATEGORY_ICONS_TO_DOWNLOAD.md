# 🎨 قائمة أيقونات التصنيفات للتنزيل

## 📋 الأيقونات الحالية (Material Icons)

هذه هي الأيقونات المستخدمة حالياً في `category_constants.dart`:

| التصنيف | الأيقونة الحالية | اسم الأيقونة للبحث في FontAwesome |
|---------|------------------|-----------------------------------|
| **مطاعم وكافيهات** | `Icons.fastfood` | `utensils`, `burger`, `coffee` |
| **أزياء وموضة** | `Icons.checkroom` | `shirt`, `tshirt`, `clothes-hanger` |
| **سوبر ماركت** | `Icons.shopping_cart` | `cart-shopping`, `basket-shopping` |
| **إلكترونيات** | `Icons.devices` | `laptop`, `mobile`, `tv` |
| **صيدليات** | `Icons.local_pharmacy` | `pills`, `prescription-bottle`, `capsules` |
| **جمال وعناية** | `Icons.face_retouching_natural` | `spa`, `face-smile`, `heart-pulse` |
| **سفر** | `Icons.flight` | `plane`, `plane-departure`, `suitcase-rolling` |
| **غير ذلك** | `Icons.category` | `grid`, `th-large`, `border-all` |

---

## 🔗 روابط التنزيل

### FontAwesome Free SVG Icons
1. اذهب إلى: https://fontawesome.com/search?o=r&m=free&s=solid
2. ابحث عن الأيقونة باستخدام الاسم من الجدول أعلاه
3. اضغط على الأيقونة → Download → SVG

### أمثلة مباشرة:
- **Utensils (مطاعم)**: https://fontawesome.com/icons/utensils?f=classic&s=solid
- **Shirt (أزياء)**: https://fontawesome.com/icons/shirt?f=classic&s=solid
- **Cart Shopping (سوبر ماركت)**: https://fontawesome.com/icons/cart-shopping?f=classic&s=solid
- **Laptop (إلكترونيات)**: https://fontawesome.com/icons/laptop?f=classic&s=solid
- **Pills (صيدليات)**: https://fontawesome.com/icons/pills?f=classic&s=solid
- **Spa (جمال)**: https://fontawesome.com/icons/spa?f=classic&s=solid
- **Plane (سفر)**: https://fontawesome.com/icons/plane?f=classic&s=solid
- **Grid (غير ذلك)**: https://fontawesome.com/icons/grid?f=classic&s=solid

---

## 📝 ملاحظات

### بعد التنزيل:
1. ✅ احفظ كل SVG باسم واضح (مثل: `restaurants.svg`, `fashion.svg`)
2. ✅ ارفعها من الداشبورد لكل تصنيف
3. ✅ تأكد من أن الـ API يرجع `icon_url` صحيح

### الأيقونات الافتراضية (Fallback):
- إذا كان `icon_url: null`، سيتم عرض أيقونة افتراضية (category icon)
- يمكنك تغيير الأيقونة الافتراضية من الكود

---

## 🎯 التصنيفات من API

حسب الـ API Response الذي أرسلته:

```json
{
  "id": 1,
  "name": "إلكترونيات",
  "name_ar": "إلكترونيات",
  "name_en": "Electronics",
  "slug": "electronics",
  "icon_path": "store-categories/1/icon/...",
  "icon_url": "https://api.coupony.shop/storage/store-categories/1/icon/..."
}
```

### التصنيفات الموجودة:
1. إلكترونيات (Electronics) - ✅ لديها icon
2. أزياء وملابس (Fashion & Clothing) - ❌ بدون icon
3. أطعمة ومشروبات (Food & Beverages) - ❌ بدون icon
4. المنزل والحديقة (Home & Garden) - ❌ بدون icon
5. الجمال والصحة (Beauty & Health) - ❌ بدون icon
6. الرياضة والأنشطة الخارجية (Sports & Outdoors) - ❌ بدون icon
7. كتب ووسائط (Books & Media) - ❌ بدون icon
8. ألعاب وترفيه (Toys & Games) - ❌ بدون icon
9. سيارات (Automotive) - ❌ بدون icon
10. مجوهرات وإكسسوارات (Jewelry & Accessories) - ❌ بدون icon
11. مستلزمات الحيوانات الأليفة (Pet Supplies) - ❌ بدون icon
12. مستلزمات مكتبية (Office Supplies) - ❌ بدون icon
13. الأطفال والرضع (Baby & Kids) - ❌ بدون icon
14. أثاث (Furniture) - ❌ بدون icon
15. بقالة (Grocery) - ❌ بدون icon
16. تيشيرت (T-shirts) - ✅ لديها icon

---

## 🚀 الخطوات التالية

1. ✅ نزّل الأيقونات من FontAwesome
2. ✅ ارفعها من الداشبورد لكل تصنيف
3. ✅ تأكد من أن API يرجع `icon_url` صحيح
4. ✅ اختبر التطبيق - الأيقونات ستظهر تلقائياً!

---

**ملاحظة:** الكود الجديد يدعم عرض الصور من API تلقائياً، مع fallback icon إذا لم تكن الصورة متوفرة.
