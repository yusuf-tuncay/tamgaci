# Dark Mode Düzeltme Kuralları

Bu doküman, uygulamadaki tüm ekranların dark mode'a uyumlu hale getirilmesi için takip edilmesi gereken kuralları içerir.

## 1. Kart Arkaplan Renkleri

### Kural
- **Dark Mode:** `Colors.grey[850]`
- **Light Mode:** `Colors.white`
- **Kullanım:** Tüm kartlar, container'lar ve card widget'ları için

### Örnek
```dart
Container(
  decoration: BoxDecoration(
    color: isDark ? Colors.grey[850] : Colors.white,
    // ...
  ),
)
```

### İstisnalar
- **Header kartları:** Marka renklerini korur (gradient: `TamgaciConstants.primaryColor`, `Color(0xFF4C6EF5)`, `TamgaciConstants.primaryColorDark`)
- **Son aktiviteler kartı:** `Colors.grey[850]` (dark mode için referans)

---

## 2. Border Renkleri

### Kural
- **Dark Mode:** `Colors.white12`
- **Light Mode:** `Colors.black12`
- **Genişlik:** `1`

### Örnek
```dart
border: Border.all(
  color: isDark ? Colors.white12 : Colors.black12,
  width: 1,
),
```

---

## 3. Shadow (Gölge) Renkleri

### Kural
- **Tüm modlar için:** `Colors.black.withValues(alpha: 0.12)`
- **Blur Radius:** `16`
- **Spread Radius:** `1`
- **Offset:** `Offset(0, 8)`

### Örnek
```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 16,
    spreadRadius: 1,
    offset: const Offset(0, 8),
  ),
],
```

---

## 4. Text Renkleri

### Ana Metinler
- **Dark Mode:** `Colors.white`
- **Light Mode:** `Colors.grey[800]`

### İkincil Metinler
- **Dark Mode:** `Colors.grey[400]`
- **Light Mode:** `Colors.grey[600]`

### Üçüncül Metinler
- **Dark Mode:** `Colors.grey[300]`
- **Light Mode:** `Colors.grey[600]`

### Örnek
```dart
Text(
  'Başlık',
  style: GoogleFonts.poppins(
    color: isDark ? Colors.white : Colors.grey[800],
  ),
)

Text(
  'Açıklama',
  style: GoogleFonts.poppins(
    color: isDark ? Colors.grey[400] : Colors.grey[600],
  ),
)
```

### Theme-Aware Alternatif
```dart
// Daha iyi yaklaşım
Text(
  'Başlık',
  style: GoogleFonts.poppins(
    color: Theme.of(context).colorScheme.onSurface,
  ),
)

Text(
  'Açıklama',
  style: GoogleFonts.poppins(
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
  ),
)
```

---

## 5. Header Arkaplan Renkleri

### Kural
**Header'lara dokunulmaz!** Header'lar her zaman marka renklerini kullanır.

### Marka Renkleri (Gradient)
```dart
gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    TamgaciConstants.primaryColor,        // Color(0xFF2196F3)
    Color(0xFF4C6EF5),
    TamgaciConstants.primaryColorDark,    // Color(0xFF64B5F6)
  ],
),
```

### Header İçi Text Renkleri
- **Tüm modlar için:** `Theme.of(context).colorScheme.onPrimary`
- **Veya:** `Colors.white` (gradient üzerinde okunabilirlik için)

### Örnek
```dart
Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        TamgaciConstants.primaryColor,
        Color(0xFF4C6EF5),
        TamgaciConstants.primaryColorDark,
      ],
    ),
    // ...
  ),
  child: Text(
    'Başlık',
    style: GoogleFonts.poppins(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)
```

---

## 6. Input Field'lar (TextField, DropdownButtonFormField)

### Arkaplan Rengi
- **Dark Mode:** `Colors.grey[800]`
- **Light Mode:** `Colors.grey[50]`

### Border Renkleri
- **Normal:** `isDark ? Colors.white12 : Colors.grey[300]`
- **Focused:** `Color(0xFF6366F1)` (primary color)

### Text Renkleri
- **Input Text:** `isDark ? Colors.white : Colors.grey[800]`
- **Hint Text:** `isDark ? Colors.grey[500] : Colors.grey[500]`
- **Icon:** `isDark ? Colors.grey[400] : Colors.grey`

### Örnek
```dart
TextField(
  style: TextStyle(
    color: isDark ? Colors.white : Colors.grey[800],
  ),
  decoration: InputDecoration(
    hintText: 'Ara...',
    hintStyle: GoogleFonts.poppins(
      color: isDark ? Colors.grey[500] : Colors.grey[500],
    ),
    prefixIcon: Icon(
      Icons.search,
      color: isDark ? Colors.grey[400] : Colors.grey,
    ),
    filled: true,
    fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDark ? Colors.white12 : Colors.grey[300]!,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDark ? Colors.white12 : Colors.grey[300]!,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF6366F1)),
    ),
  ),
)
```

---

## 7. Material Widget'ları (Card, ListTile, vb.)

### Material Color
```dart
Material(
  color: isDark ? Colors.grey[850] : Colors.white,
  // ...
)
```

### Card Widget
Card widget'ları genellikle theme-aware'dir, ancak içerikteki hardcoded renkleri kontrol edin.

---

## 8. Icon Renkleri

### Genel İkonlar
- **Dark Mode:** `Colors.grey[400]` veya `Theme.of(context).colorScheme.onSurface`
- **Light Mode:** `Colors.grey` veya `Colors.grey[600]`

### Header İçi İkonlar
- **Tüm modlar:** `Theme.of(context).colorScheme.onPrimary`

### Örnek
```dart
Icon(
  Icons.settings,
  color: isDark ? Colors.grey[400] : Colors.grey[600],
)
```

---

## 9. Divider ve Ayırıcılar

### Divider Renkleri
- **Dark Mode:** `Colors.grey[700]` veya `Colors.white12`
- **Light Mode:** `Colors.grey[200]`

### Örnek
```dart
Divider(
  color: isDark ? Colors.grey[700] : Colors.grey[200],
  height: 1,
)
```

---

## 10. Button Renkleri

### ElevatedButton
- Theme-aware renkler kullanılmalı
- `Theme.of(context).colorScheme.primary` (arkaplan)
- `Theme.of(context).colorScheme.onPrimary` (text)

### TextButton
- `Theme.of(context).colorScheme.primary` (text rengi)

### Örnek
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
  ),
  onPressed: () {},
  child: Text('Buton'),
)
```

---

## 11. Tablo (Table) Renkleri

### Tablo Container
- **Dark Mode:** `Colors.grey[850]`
- **Light Mode:** `Colors.white`

### Tablo Başlık Arkaplanı
- **Dark Mode:** `Colors.grey[800]`
- **Light Mode:** `Colors.grey[50]`

### Tablo Başlık Text
- **Dark Mode:** `Colors.white`
- **Light Mode:** `Colors.grey[800]`

### Tablo Satır Ayırıcıları
- **Dark Mode:** `Colors.grey[700]`
- **Light Mode:** `Colors.grey[200]`

---

## 12. Checkbox ve Radio Button

### Theme-aware kullanın
```dart
Checkbox(
  value: value,
  onChanged: onChanged,
  // Theme otomatik olarak uygulanır
)
```

---

## 13. Dialog ve BottomSheet

### Arkaplan
- **Dark Mode:** `Colors.grey[850]` veya `_surfaceDark`
- **Light Mode:** `Colors.white` veya `_surfaceLight`

### Text Renkleri
- **Dark Mode:** `Colors.white` veya `_onSurfaceDark`
- **Light Mode:** `Colors.grey[800]` veya `_onSurfaceLight`

---

## 14. Genel Kontrol Listesi

Her ekran için şunları kontrol edin:

- [ ] Tüm hardcoded `Colors.white` → `isDark ? Colors.grey[850] : Colors.white`
- [ ] Tüm hardcoded `Colors.black` → `isDark ? Colors.white : Colors.grey[800]`
- [ ] Tüm hardcoded `Colors.grey[XXX]` → Theme-aware alternatifler
- [ ] Border renkleri → `isDark ? Colors.white12 : Colors.black12`
- [ ] Shadow renkleri → `Colors.black.withValues(alpha: 0.12)`
- [ ] Input field'lar → Dark mode uyumlu fillColor ve border
- [ ] Header'lar → Marka renklerini koru (değiştirme!)
- [ ] Icon renkleri → Theme-aware
- [ ] Text renkleri → Theme-aware veya `isDark ? ... : ...`
- [ ] Material widget'ları → `color: isDark ? Colors.grey[850] : Colors.white`

---

## 15. İyi Pratikler

### 1. Theme.of(context) Kullanımı
Mümkün olduğunca `Theme.of(context).colorScheme` kullanın:
```dart
// ✅ İyi
color: Theme.of(context).colorScheme.onSurface

// ❌ Kötü (gerekmedikçe)
color: isDark ? Colors.white : Colors.grey[800]
```

### 2. isDark Kontrolü
```dart
// ✅ İyi
final isDark = Theme.of(context).brightness == Brightness.dark;

// ❌ Kötü
final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
```

### 3. Builder Widget Kullanımı
Eğer `context` erişimi yoksa:
```dart
Builder(
  builder: (context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.grey[850] : Colors.white,
    );
  },
)
```

### 4. Tutarlılık
Aynı ekrandaki tüm kartlar aynı arkaplan rengini kullanmalı:
- `Colors.grey[850]` (dark mode)
- `Colors.white` (light mode)

---

## 16. Özel Durumlar

### Placeholder/Error Image Container
```dart
Container(
  color: isDark ? Colors.grey[800] : Colors.grey[300],
  child: Icon(
    Icons.broken_image,
    color: isDark ? Colors.grey[400] : Colors.grey[600],
  ),
)
```

### Loading Indicator
```dart
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(
    Theme.of(context).colorScheme.primary,
  ),
)
```

---

## 17. Test Etme

Her düzeltmeden sonra:
1. Light mode'da kontrol edin
2. Dark mode'da kontrol edin
3. Her iki modda da tüm interaktif elemanları test edin
4. Responsive layout'ları kontrol edin (mobil/tablet/desktop)

---

## 18. Referans Ekranlar

Dark mode'un doğru uygulandığı referans ekranlar:
- Dashboard (Son aktiviteler kartı)
- Ürünler modülü (mobil ve desktop layout)
- Müşteriler modülü

Bu ekranlardaki uygulamaları diğer ekranlara da uygulayın.

---

## Notlar

- Header'lar **ASLA** değiştirilmemelidir (marka renkleri korunmalı)
- Tutarlılık çok önemlidir - aynı türdeki widget'lar aynı renkleri kullanmalı
- Theme-aware yaklaşım her zaman tercih edilmelidir
- Hardcoded renkler sadece gerçekten gerekli olduğunda kullanılmalıdır

