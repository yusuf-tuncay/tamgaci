# Real-time Listener Kullanım Kılavuzu

## 🎯 **Genel Prensipler**

### **1. Manuel Güncelleme YASAK**
- ❌ `setState()` ile manuel güncelleme
- ❌ `refreshSubscription()` çağrıları
- ❌ `clearCache()` işlemleri
- ❌ Manuel API çağrıları

### **2. Real-time Listener KULLAN**
- ✅ `listenToSubscriptionUpdates()` ile otomatik güncelleme
- ✅ Firestore `snapshots()` ile real-time dinleme
- ✅ Otomatik UI güncelleme
- ✅ Performans optimizasyonu

## 🔧 **Teknik Implementasyon**

### **1. Global Real-time Listener**
```dart
// lib/core/providers/global_realtime_provider.dart
class GlobalRealtimeNotifier extends StateNotifier<bool> {
  void startGlobalListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _startSubscriptionListener(user.uid);
      }
    });
  }
}
```

### **2. Subscription Real-time Listener**
```dart
// lib/core/providers/subscription_state_provider.dart
void listenToSubscriptionUpdates(String userId) {
  FirebaseFirestore.instance
      .collection('subscription_updates')
      .doc(userId)
      .snapshots()
      .listen((snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data()!;
      if (data['status'] == 'updated') {
        // Otomatik güncelleme
        checkUserSubscription(userId);
      }
    }
  });
}
```

### **3. Firebase Functions Integration**
```typescript
// functions/src/index.ts
await db.collection('subscription_updates').doc(userId).set({
    userId: userId,
    status: 'updated',
    subscriptionEndAt: newEndDate,
    subscriptionPlan: planType,
    updatedAt: now,
    orderId: orderId,
    daysAdded: daysToAdd,
});
```

## 📱 **Kullanım Senaryoları**

### **1. PayTR Ödeme Sonrası**
```
PayTR Ödeme → Firebase Functions → Firestore Güncelleme → Real-time Listener → UI Güncelleme
```

### **2. Abonelik Süresi Ekleme**
```
Süre Ekleme → Firestore → Real-time Listener → Anında Görünür
```

### **3. Geçmiş Satın Alımlar**
```
Yeni Satın Alım → Firestore → Real-time Listener → Liste Güncellenir
```

## 🚀 **Avantajlar**

### **1. Kullanıcı Deneyimi**
- ✅ **Anlık güncelleme**
- ✅ **Manuel yenileme yok**
- ✅ **Kesintisiz deneyim**

### **2. Performans**
- ✅ **Gereksiz API çağrıları yok**
- ✅ **Sadece değişiklik olduğunda tetiklenir**
- ✅ **Battery friendly**

### **3. Güvenilirlik**
- ✅ **Veri tutarlılığı**
- ✅ **Cache sorunları yok**
- ✅ **Otomatik senkronizasyon**

## ⚠️ **Dikkat Edilecekler**

### **1. Listener Lifecycle**
```dart
// Listener'ı başlat
void startListening() {
  _subscription = FirebaseFirestore.instance
      .collection('subscription_updates')
      .doc(userId)
      .snapshots()
      .listen((snapshot) {
        // Handle updates
      });
}

// Listener'ı durdur
void stopListening() {
  _subscription?.cancel();
}
```

### **2. Memory Management**
```dart
@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### **3. Error Handling**
```dart
FirebaseFirestore.instance
    .collection('subscription_updates')
    .doc(userId)
    .snapshots()
    .listen(
      (snapshot) {
        // Handle success
      },
      onError: (error) {
        debugPrint('Real-time listener error: $error');
      },
    );
```

## 📋 **Checklist**

### **✅ Yapılması Gerekenler**
- [ ] Global real-time listener başlat
- [ ] Subscription real-time listener kullan
- [ ] Manuel güncelleme kodlarını kaldır
- [ ] Error handling ekle
- [ ] Memory management yap

### **❌ Yapılmaması Gerekenler**
- [ ] Manuel `setState()` çağrıları
- [ ] Manuel `refreshSubscription()` çağrıları
- [ ] Manuel cache temizleme
- [ ] Gereksiz API çağrıları

## 🎉 **Sonuç**

Real-time listener yaklaşımı ile:
- **Manuel güncelleme yok**
- **Otomatik senkronizasyon**
- **Mükemmel kullanıcı deneyimi**
- **Performans optimizasyonu**
- **Güvenilir veri yönetimi**

Bu yaklaşım sayesinde kullanıcı hiçbir şey yapmadan tüm değişiklikleri anında görür! 🚀
