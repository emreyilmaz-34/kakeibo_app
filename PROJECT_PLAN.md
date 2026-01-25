## kakeiboapp – Proje Planı (Mobil – Flutter, Dart)

### 1) Vizyon ve Amaç
- İnsanların harcamalarını kolayca kaydedip yönetebildiği, finans farkındalığını artıran bir mobil uygulama.
- Premium kullanıcılar için: harcama detayında “bu tutarı harcamak yerine şu varlıklara yatırsaydın” karşılaştırmaları (altın, popüler hisseler vb.) – fiyatlar kendi backend’imizden anlık/yakın gerçek zamanlı olarak gelecek.

### 2) Kullanıcı Senaryoları (Özet)
- Ücretsiz kullanıcı
  - Harcama ekler (tutar, tarih, not, kategori).
  - Harcamaları listeler ve filtreler.
  - Reklam görür (banner/interstitial konumlarına göre).
- Premium kullanıcı
  - Reklamsız deneyim.
  - Harcama detayında varlık karşılaştırmaları (altın, seçilmiş hisseler, endeks fonu vb.).
  - Geçmiş harcamalarda da aynı karşılaştırmaları görebilir.

### 3) Özellik Seti
- Harcama Yönetimi
  - Ekleme: tutar (zorunlu), para birimi, tarih, kategori (opsiyonel), not (opsiyonel), etiketler (opsiyonel), foto/fiş ekleri (v2)
  - Listeleme, arama, filtreleme (tarih aralığı, kategori, min/max tutar)
  - Düzenleme / silme
  - Basit özetler (aylık toplam, kategori kırılımı)
- Varlıklar (Portföy) – yeni
  - Kullanıcı, sahip olduğu varlıkları ekler: sembol (ALTIN, THYAO…), adet/gram/lot, alış fiyatı (opsiyonel), alış tarihi (opsiyonel), not (opsiyonel).
  - Portföy ekranında tüm varlıklar listelenir; toplam değer, günlük/bugünkü değer (yakın gerçek zamanlı fiyatlarla), basit P&L gösterimi (alış fiyatı varsa).
  - Varlık ekle/düzenle/sil.
- Premium
  - Reklamsız.
  - Harcama detayında varlık karşılaştırmaları: “X TL yerine bugün şunları alabilirdin” listesi (altın, THYAO, BIST30 ETF örn.).
  - Varlık listesi ve ağırlıklandırma backend tarafından yönetilir (yönetim paneli v2).
- Reklam
  - Ücretsizte banner ve belirli akışlarda interstitial.
  - Premium’da kapalı.

### 4) Teknik Mimari (Mobil Uygulama)
- Mobil: Flutter (Dart).
- Navigation: Flutter Navigator (go_router veya Navigator 2.0). Başlangıç: go_router (daha modern ve kolay).
- State Yönetimi: Basit ve hafif yapı için Provider veya Riverpod. (Başlangıç: Provider – daha sonra gerekirse Riverpod’a geçiş yapılabilir.)
- Yerel Depolama:
  - Kalıcı ve sorgulanabilir veri için SQLite (sqflite).
  - Küçük ayarlar/flag'ler için shared_preferences veya flutter_secure_storage (hassas veriler için).
- Internationalization (i18n):
  - flutter_localizations + intl (çok dilli destek).
  - Başlangıç dilleri: İngilizce (en), Türkçe (tr), İspanyolca (es), Fransızca (fr), Almanca (de), İtalyanca (it), Portekizce (pt), Japonca (ja), Korece (ko), Çince (zh).
  - Uygulama global olarak yayınlanacak; tüm kullanıcı görünür metinler i18n ile yönetilir.
- Ağ/İstemci
  - REST tabanlı backend (Node.js/Express) – varlık fiyatları endpointleri.
  - HTTP client: dio veya http. Başlangıç: dio (daha özellikli).
  - İleride WebSocket/Server-Sent Events ile canlı güncelleme (v2).
- Analitik ve Hata Takibi
  - Firebase Analytics + Crashlytics (firebase_core, firebase_analytics, firebase_crashlytics) (alternatif: Sentry).
- Ödeme/Premium
  - In‑App Purchases: in_app_purchase.
  - Sunucu tarafında makbuz/doğrulama (v2 / backend).
- Reklam
  - google_mobile_ads (AdMob).

### 5) Backend (Özet Gereksinimler)
- Amaç: Popüler varlıkların (altın, seçilmiş hisseler/ETF’ler) anlık/near-real-time fiyatlarını sağlamak.
- Önerilen Stack: Node.js + Express / Fastify, Redis (cache), Postgres (opsiyonel), Docker tabanlı dağıtım.
- Endpointler (v1):
  - GET `/assets` → { symbol, name, type } listesi (altın, THYAO, BIST30 ETF vb.).
  - GET `/prices?symbols=ALTIN,THYAO,BIST30ETF` → anlık fiyatlar.
  - Response’larda `price`, `currency`, `timestamp` alanları.
- Politikalar:
  - Oran sınırlama (rate-limit), API anahtarı (uygulama içi public key + basit doğrulama; v2’de kullanıcı bazlı auth).
  - Bellek/Redis cache ile tazeleme aralığı: 15–60 sn (konfigüre edilebilir).

### 5.1) Offline-First, Opsiyonel Login ve Senkronizasyon – yeni
- Kayıt/oturum açma zorunlu değil; varsayılan olarak tüm veriler cihazda yerel saklanır.
- Kullanıcı istediği zaman hesap oluşturup giriş yaptığında, mevcut yerel veriler sunucuya senkronize edilir ve hesapla ilişkilendirilir.
- Senkronizasyon Stratejisi (v1 – tek cihaz varsayımı):
  - Her kayıtta `id` (UUID), `remoteId` (nullable), `updatedAt` (ISO), `deleted` (0/1) alanları.
  - Girişte: “push all local unsynced changes” → backend `upsert` uygular, `remoteId` döndürür.
  - Sonrasında: periodik/manuel sync (ayarlar).
- Çakışma Yönetimi (v1):
  - Tek cihaz senaryosunda çakışma riski düşüktür; kural: “son yazan kazanır” (`updatedAt` karşılaştırması).
  - v2: çoklu cihaz senaryosunda sürümleme/merge politikası eklenecek.
- Kimlik ve Linkleme:
  - Local kullanıcıya `deviceId` (shared_preferences veya device_info_plus) atanır.
  - Hesap oluşturunca local veriler `deviceId` vasıtasıyla kullanıcı hesabına bağlanır.

### 6) Veri Modeli (Mobil – Minimum V1)
```text
Expense {
  id: string;
  amount: number;          // örn. 5000
  currency: string;        // "TRY"
  date: string;            // ISO 8601
  category?: string;       // "Yeme-İçme", "Ulaşım", ...
  note?: string;
  tags?: string[];
  createdAt: string;       // ISO
  updatedAt: string;       // ISO
}

Holding {
  id: string;
  symbol: string;          // "ALTIN", "THYAO", "BIST30ETF"
  quantity: number;        // gram/lot/adet
  unit: string;            // "gram", "lot", "adet" (gösterim için)
  buyPrice?: number;       // opsiyonel – TRY bazında
  buyDate?: string;        // ISO – opsiyonel
  note?: string;
  remoteId?: string | null;
  deleted: 0 | 1;
  createdAt: string;
  updatedAt: string;
}

Settings {
  isPremium: boolean;
  preferredCurrency: string; // "TRY"
  showAds: boolean;          // !isPremium
  deviceId: string;          // offline kimlik
  lastSyncAt?: string;       // opsiyonel
}
```

### 7) UX / Ekranlar
- Onboarding (kısa – opsiyonel)
- Ana Ekran: aylık özet, hızlı ekleme butonu.
- Harcama Listesi: arama/filtre.
- Harcama Ekle/Düzenle: tutar, tarih, kategori, not.
- Harcama Detayı:
  - Temel bilgiler
  - Premium: “Bu tutar ile şunları alabilirdin” bileşeni (varlık listesi, adet/lot hesapları, tarih/saat).
- Varlıklar (Portföy) Ekranı – yeni
  - Liste: sembol, miktar, anlık fiyat, toplam değer, P&L (varsa).
  - Ekle/Düzenle formu: sembol seçimi (autocomplete), miktar, birim, opsiyonel alış fiyatı/tarihi.
  - Detay (v2): geçmiş fiyat grafiği (opsiyonel).
- Premium Satın Alma: plan tanımı, fiyat, abonelik/süreç.
- Ayarlar: para birimi, yedekleme (v2), premium durumu.

### 8) “Varlık Karşılaştırması” Hesaplama Mantığı (Mobil Taraf)
- Girdi: harcama tutarı (TRY), timestamp (harcama tarihi), backend’den dönen her varlık için güncel fiyat (`price`, `currency`, `timestamp`).
- Dönüşüm: Fiyatlar farklı para biriminde ise uygulama şimdilik TRY bazlı kalır; backend TRY fiyatı döndürür (v1).
- Çıktı: Her varlık için alınabilecek yaklaşık adet = `amount / price` (lot/gram vs. birim notuyla).
- Gösterim: varlık adı, sembolü, birim fiyatı, alınabilecek adet, fiyat zaman damgası.

### 8.1) Portföy (Varlıklar) Değer Hesaplama Mantığı (Mobil Taraf) – yeni
- Girdi: holding.quantity, backend’den canlı fiyat (`price` – TRY), opsiyonel buyPrice.
- Toplam değer: `holding.quantity * price`
- P&L (opsiyonel): `holding.quantity * (price - buyPrice)`
- Yüzde değişim (opsiyonel): `(price - buyPrice) / buyPrice`
- Para birimi: v1’de tüm fiyatlar TRY.

### 9) Reklam Stratejisi (v1)
- Banner: Harcama listesi ve ana ekran alt/üst.
- Interstitial: Bazı akışlarda (ör. her X kayıttan sonra) – kullanıcı rahatsızlığını ölçerek ayarlama.
- Premium’da tamamı kapalı.

### 10) Güvenlik ve Gizlilik
- Yerelde saklanan veriler cihazda kalır (v1 – bulut senkronizasyonu yok).
- iOS Keychain / Android EncryptedSharedPreferences ile gerekli anahtar/flag’lerin güvenliği.
- Analitik veriler kişisel veri içermeyecek; A/B testleri (v2).

### 11) Test ve Kalite
- Ünite testi (Flutter test framework) – hesaplama yardımcıları, dönüştürme fonksiyonları.
- Widget testleri (Flutter test framework) – kritik ekranlar ve widget'lar.
- Entegrasyon testleri (integration_test) – temel akışlar (v2).

### 12) Sürümleme ve Yayınlama
- CI/CD: GitHub Actions ile otomatik build/test, manual release.
- iOS TestFlight, Android Internal Testing → kademeli yayın.

### 13) Yol Haritası (Öneri – Haftalık)
- ✅ Hafta 1–2: Proje iskeleti (Flutter/Dart), navigation (go_router), temel UI (Material Design), SQLite (sqflite); harcama CRUD. **TAMAMLANDI**
- ✅ Hafta 3: Liste/filtre ✅, özetler ✅, basit analytics ✅, reklam entegrasyonu (ücretsiz akış) ✅ **TAMAMLANDI**
- ✅ Hafta 4: Premium ekranı + IAP entegrasyonu; premium gating. **TAMAMLANDI**
- ✅ Hafta 5: Mock data ile varlık karşılaştırması; detay ekranında "Bu tutar ile şunları alabilirdin" bileşeni. **TAMAMLANDI**
- ✅ Hafta 6: Varlıklar (Portföy) ekranı: holding CRUD, mock data ile canlı değer ve P&L hesaplama. **TAMAMLANDI**
- ⏳ Hafta 6 (Devam): Performans/UX iyileştirme, hatalar, temel testler, ilk beta.

### 14) Başlangıç Paketleri (Mobil)
- Navigation: `go_router`
- Depolama: `sqflite`, `shared_preferences`, `flutter_secure_storage`
- Internationalization: `flutter_localizations`, `intl`
- IAP: `in_app_purchase`
- Reklam: `google_mobile_ads`
- HTTP: `dio`
- State Management: `provider`
- Firebase: `firebase_core`, `firebase_analytics`, `firebase_crashlytics`
- Device Info: `device_info_plus`
- UUID: `uuid`

### 15) Riskler ve Alternatifler
- App Store/Play Store IAP incelemeleri → zaman planına etki.
- Finansal veri sağlayıcı sürekliliği → backend cache/fallback şart.
- Yerel DB şeması evrimi → göç/migrasyon stratejisi.

—
Bu plan v1 kapsamını odaklı tutar. Premium ve varlık karşılaştırma özelliği backend ile birlikte tasarlanmıştır; ilerleyen sürümlerde canlı fiyat akışı, geçmişe dönük getiri simülasyonları ve kişiselleştirme eklenebilir.


