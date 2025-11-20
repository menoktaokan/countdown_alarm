# ⏰ Geri Sayım ve Alarm

Flutter ile geliştirilmiş, modern ve kullanıcı dostu bir geri sayım ve alarm uygulaması.

## 📱 Özellikler

### Geri Sayım
- ⏱️ Saat, dakika ve saniye seviyesinde hassas geri sayım
- 🎯 Tek aktif geri sayım desteği
- 📱 Tam ekran geri sayım görünümü
- 🔔 Geri sayım tamamlandığında sesli uyarı
- 🎨 Modern ve sezgisel kullanıcı arayüzü

### Alarm
- ⏰ Saat ve dakika seviyesinde alarm kurma
- 📱 Tam ekran alarm görünümü
- 🔔 Alarm çaldığında sesli uyarı
- ⚙️ Tek veya sürekli ses seçenekleri
- 🎨 Sistem saati ile senkronize başlangıç değerleri

### Ses Ayarları
- 🔊 Tek seferlik bip sesi
- 🔁 Sürekli bip sesi (60 saniye)
- ⚙️ Ayarlar ekranından ses tipi seçimi
- 🎵 Platform bağımsız ses çalma desteği

### Kullanıcı Arayüzü
- 🎨 Material Design 3 desteği
- 🌓 Açık/Koyu tema desteği
- 📱 Responsive tasarım
- ♾️ Sonsuz kaydırılabilir zaman seçici tekerlekleri
- 🎯 Sezgisel dokunmatik kontroller

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.10.0 veya üzeri)
- Dart SDK
- Android Studio / VS Code / IntelliJ IDEA
- Android SDK (Android geliştirme için)
- Xcode (iOS geliştirme için, yalnızca macOS)

### Adımlar

1. **Projeyi klonlayın:**
   ```bash
   git clone <repository-url>
   cd countdown_alarm
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

## 📖 Kullanım

### Geri Sayım Başlatma
1. Ana ekranda geri sayım dairesine dokunun
2. Saat, dakika ve saniye değerlerini tekerleklerden seçin
3. Geri sayımı başlatmak için tekrar dokunun
4. Tam ekran görünümünde geri sayımı takip edin
5. Ana ekrana döndüğünüzde geri sayım otomatik olarak iptal edilir

### Alarm Kurma
1. Ana ekranda alarm dairesine dokunun
2. Saat ve dakika değerlerini tekerleklerden seçin (varsayılan olarak sistem saati gösterilir)
3. Alarmı kurmak için tekrar dokunun
4. Tam ekran görünümünde alarm durumunu takip edin
5. Ana ekrana döndüğünüzde alarm otomatik olarak iptal edilir

### Ses Ayarları
1. Ana ekranda ayarlar ikonuna dokunun
2. "Alarm Tipi" bölümünden ses tipini seçin:
   - **Tek**: Alarm çaldığında tek bir bip sesi
   - **Sürekli**: Alarm çaldığında 60 saniye boyunca sürekli bip sesi
3. Seçiminiz otomatik olarak kaydedilir

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── models/                   # Veri modelleri
│   ├── alarm_model.dart     # Alarm veri modeli
│   ├── countdown_model.dart # Geri sayım veri modeli
│   └── alert_type.dart      # Alarm tipi enum'u
├── screens/                  # Ekranlar
│   ├── home_screen.dart     # Ana ekran
│   ├── countdown_fullscreen.dart # Geri sayım tam ekran
│   ├── alarm_fullscreen.dart    # Alarm tam ekran
│   └── settings_screen.dart     # Ayarlar ekranı
├── services/                 # Servisler
│   ├── audio_service.dart    # Ses çalma servisi (Singleton)
│   ├── alarm_service.dart    # Alarm yönetim servisi
│   ├── countdown_service.dart # Geri sayım yönetim servisi
│   └── storage_service.dart  # Yerel depolama servisi
├── widgets/                  # Özel widget'lar
│   ├── countdown_circle.dart    # Geri sayım dairesi
│   ├── alarm_circle.dart        # Alarm dairesi
│   ├── time_picker_wheel.dart   # Zaman seçici tekerlek
│   ├── system_clock.dart        # Sistem saati gösterimi
│   ├── alarm_indicator.dart     # Alarm durumu göstergesi
│   └── alert_type_button.dart   # Alarm tipi butonu
└── utils/                    # Yardımcı fonksiyonlar
    └── time_formatter.dart      # Zaman formatlama
```

## 🔧 Teknolojiler

- **Flutter**: Cross-platform mobil uygulama geliştirme framework'ü
- **Dart**: Programlama dili
- **Material Design 3**: Modern UI tasarım sistemi
- **Shared Preferences**: Yerel veri depolama
- **Audio Players**: Platform bağımsız ses çalma
- **Flutter Local Notifications**: Yerel bildirimler (gelecek özellikler için)

## 🎯 Mimari Özellikler

### Singleton Pattern
- `AudioService` singleton pattern kullanarak tek bir ses çalma servisi sağlar
- Tüm ses çalma işlemleri merkezi bir servis üzerinden yönetilir

### Servis Tabanlı Mimari
- **AudioService**: Tüm ses çalma işlemlerini yönetir
- **AlarmService**: Alarm mantığını yönetir ve AudioService'e istek gönderir
- **CountdownService**: Geri sayım mantığını yönetir ve AudioService'e istek gönderir
- **StorageService**: Yerel veri depolama işlemlerini yönetir

### State Management
- Flutter'ın yerleşik `StatefulWidget` ve `setState` mekanizması kullanılır
- Servisler listener pattern ile UI güncellemelerini tetikler

## 📝 Önemli Notlar

- ⚠️ **Tek Aktif Timer**: Aynı anda yalnızca bir geri sayım veya alarm aktif olabilir
- 🔄 **Otomatik İptal**: Ana ekrana döndüğünüzde aktif geri sayım/alarm otomatik olarak iptal edilir
- ⚙️ **Ses Tipi**: Alarm tipi yalnızca ayarlar ekranından değiştirilebilir
- 🎵 **Platform Desteği**: Ses çalma işlemleri Android, iOS, Windows, macOS ve Linux'ta çalışır

## 🐛 Bilinen Sorunlar

Şu anda bilinen bir sorun bulunmamaktadır. Herhangi bir sorunla karşılaşırsanız lütfen bir issue açın.

## 🔮 Gelecek Özellikler

- [ ] Bildirim desteği
- [ ] Arka plan çalışması
- [ ] Birden fazla geri sayım desteği
- [ ] Özel ses dosyaları
- [ ] Tema özelleştirme

## 📄 Lisans

Bu proje özel bir projedir ve lisanslanmamıştır.

---

**Not**: Bu uygulama eğitim ve kişisel kullanım amaçlıdır.