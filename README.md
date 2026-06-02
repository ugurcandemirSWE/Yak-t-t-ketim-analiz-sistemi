# Yakıt Tüketim Analiz Sistemi (Masaüstü MATLAB Uygulaması + EXE Paketleme)

Bu proje, yakıt tüketimi ve maliyet analizi için basit lineer regresyon tahmin modeli içeren, masaüstünde çalışmaya hazır bir MATLAB arayüzü sunar.

## Dosyalar

- `FuelConsumptionAnalysisSystem_App.m`: Ana masaüstü GUI uygulaması (`uifigure` tabanlı sınıf yapısı).
- `computeFuelConsumption.m`: Yeniden kullanılabilir çekirdek analiz fonksiyonu (doğrulama, metrikler, regresyon, grafik verileri).
- `runFuelConsumptionApp.m`: Tek satırlık başlatma scripti.
- `buildStandaloneExe.m`: Tek komutla standalone EXE/kurulum paketi üretim scripti (MATLAB Compiler).
- `FuelConsumptionAnalysisSystem_Phase1.m`: 1. aşama script referansı.

## Gereksinimler

- MATLAB R2026a (hedef sürüm) veya daha yeni.
- Çekirdek işlevler için ek toolbox gerekmez (`polyfit`, `polyval`, `uifigure`, `uitable`, `uiaxes`).
- Standalone `.exe` üretimi için build alınan makinede MATLAB Compiler gerekir.

## Çalıştırma

Bu klasörde MATLAB Command Window'dan:

```matlab
runFuelConsumptionApp
```

Veya doğrudan başlat:

```matlab
app = FuelConsumptionAnalysisSystem_App;
```

## Standalone EXE Build (R2026a)

Bu klasörde MATLAB Command Window'dan:

```matlab
buildStandaloneExe
```

Build sonrası:
- Çalıştırılabilir dosya ve kurulum çıktıları `dist/FuelConsumptionAnalysisSystem` altına üretilir.
- Son kullanıcıya kurulum çıktısını paylaşabilirsin.
- Son kullanıcının MATLAB kurması gerekmez; MATLAB Runtime gerekir (kurulum akışı bunu yönetir).

## Kullanım

1. Tablo sütunlarına yolculuk verilerini gir:
   - `Km`
   - `FuelLiters`
   - `FuelPriceTLPerLiter`
2. `Tahmin için Ek Km` alanını ayarla (varsayılan `1500`).
3. `Hesapla ve Tahmin Et` butonuna tıkla.
4. Şunları incele:
   - Ortalama tüketim (`L/100km`)
   - Ortalama maliyet (`TL/km`)
   - Toplam yakıt ve toplam yakıt maliyeti
   - Tahmini toplam maliyet ve ek maliyet
   - İki grafik (tüketim trendi, maliyet trendi + regresyon + tahmin noktası)

## Notlar

- Regresyon için en az 2 satır veri gerekir.
- Tüm sayısal girişler geçerli ve negatif olmayan değerler olmalıdır (`Km` pozitif olmalıdır).
- Giriş hataları uygulama içinde uyarı penceresi ile gösterilir.
- Çalışma anında tablo verisi table/sayısal/hücre biçiminde girilebilir; uygulama doğrulama yapar ve hatayı bildirir.

## GitHub'a Hazır Kontrol Listesi

1. Repoyu başlat ve tüm kaynak dosyaları commit et.
2. GitHub'da `v1.0.0` release notlarını ekle.
3. `buildStandaloneExe` çalıştır ve `dist/FuelConsumptionAnalysisSystem` altındaki kurulum dosyasını GitHub Release'e ekle.
4. README içine uygulama ekran görüntülerini koy.

