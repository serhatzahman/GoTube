# GoTube - Nokia N9 Derleme ve Cihaza Yükleme Kılavuzu

Bu kılavuz, GoTube uygulamasının Nokia N9 (MeeGo 1.2 Harmattan) için nasıl derleneceğini ve cihaza nasıl yükleneceğini adım adım açıklar.

---

## 1. Geliştirme Ortamı Seçenekleri

Nokia N9 için Qt 4.7 tabanlı ARM binary üretmek üzere iki yaygın yöntem kullanılır:

### Yöntem A: Docker Tabanlı Harmattan SDK (En Kolay ve Modern Yöntem)
Modern Linux dağıtımlarında 32-bit kütüphane sorunlarıyla uğraşmamak için hazır Harmattan SDK Docker container'ı kullanılabilir:

```bash
# 1. Proje dizinine girin
cd gotube

# 2. Harmattan derleyici container'ını başlatın
docker run --rm -v $(pwd):/workspace -w /workspace marmistrz/harmattan-sdk:latest \
    /bin/bash -c "qmake && make && dpkg-buildpackage -rfakeroot -uc -us -b"
```

### Yöntem B: Orijinal Nokia Qt SDK (Ubuntu / Debian Chroot)
Eğer sisteminizde Nokia Qt SDK (MeeGo 1.2 Harmattan Target) kuruluysa:
```bash
# Scratchbox / Harmattan ortamına geçin
sb2 -t harmattan-armel

# Derleme
cd /path/to/gotube
qmake gotube.pro
make
dpkg-buildpackage -rfakeroot -uc -us -b
```

---

## 2. Üretilen Paket

Derleme başarıyla tamamlandığında proje dizininin bir üst seviyesinde aşağıdaki dosya oluşur:
```
gotube_1.0.0_armel.deb
```

---

## 3. Nokia N9'a Kurulum

### Adım 1: N9'da Geliştirici Modunu Açın
1. N9'da **Ayarlar > Güvenlik > Geliştirici Modu (Developer Mode)** seçeneğini açın.
2. Cihaz gerekli paketleri kuracak ve `Terminal` uygulamasını aktif hale getirecektir.
3. Terminalde `devel-su` şifresini belirleyin (Varsayılan şifre genellikle `rootme`dir).

### Adım 2: .deb Dosyasını Cihaza Aktarın
* **USB ile:** Cihazı USB kablosuyla bilgisayara bağlayıp "Depolama Modu"nu seçin. `gotube_1.0.0_armel.deb` dosyasını `MyDocs` içerisine kopyalayın.
* **Veya Wi-Fi / SSH ile:**
  ```bash
  scp gotube_1.0.0_armel.deb user@192.168.1.xxx:/home/user/MyDocs/
  ```

### Adım 3: Kurulumu Gerçekleştirin
N9 üzerindeki `Terminal` uygulamasını açın ve çalıştırın:
```bash
devel-su
# Şifrenizi girin (varsayılan: rootme)

cd /home/user/MyDocs
dpkg -i gotube_1.0.0_armel.deb
apt-get -f install
```

---

## 4. Kullanım ve İpuçları

1. **Uygulamayı Başlatma:**
   * Kurulum bittiğinde uygulama listesinde **GoTube** simgesi belirecektir. Üzerine dokunarak açabilirsiniz.
2. **Sadece Ses Modu (Background Playback):**
   * Video oynatılırken **"Sadece Ses"** butonuna dokunulduğunda ekran kararır ve sadece ses akışı devam eder. Ekran kilitlendiğinde veya başka uygulamaya geçildiğinde müzik çalmaya devam eder.
3. **Çevrimdışı İndirme:**
   * **"İndir (MP4)"** butonuna dokunulduğunda dosya doğrudan `/home/user/MyDocs/Videos/` dizinine kaydedilir ve alt menüdeki **İndirilenler** sekmesinde listelenir.
4. **Sunucu Değiştirme:**
   * Bir Invidious sunucusu yanıt vermezse, sağ üstteki menüden **"Sunucu (Instance) Ayarı"** seçilerek aktif bir Invidious adresi (örn. `https://yewtu.be` veya `https://inv.tux.pizza`) girilebilir.
