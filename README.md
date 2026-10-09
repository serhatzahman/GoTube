# GoTube v2.0 — Nokia N9 (MeeGo 1.2 Harmattan) YouTube Client

[English](#english) | [Türkçe](#türkçe)

---

<a name="english"></a>
## English

GoTube v2.0 is a native, hardware-accelerated YouTube client crafted specifically for the Nokia N9 running MeeGo 1.2 Harmattan. Built with Qt 4.7 and Qt Quick (QML 1.1), it combines modern YouTube mobile UX with the classic MeeGo swipe design language.

### What's New in v2.0
- **Double-Tap Seeking (±10s)**: Double-tap on the left half of the video to rewind 10 seconds, or on the right half to fast-forward 10 seconds, complete with animated visual badges.
- **Playback Speed Selector**: Adjust speed between `0.75x`, `1.0x`, `1.25x`, `1.5x`, and `2.0x` dynamically using hardware DSP clocking.
- **Quality Switcher (360p / 720p HD)**: Switch seamlessly between battery-efficient 360p and high-definition 720p streams while preserving playback position.
- **Trending Categories**: Browse curated feeds for Music, Gaming, News, and General Trending videos via one-touch filter chips.
- **Up Next & Related Videos**: Discover related content right below the player and switch videos with a single tap.
- **Channel Explorer**: Tap any channel name to view channel details and recent uploads in `ChannelPage`.
- **Integrated Offline Downloads**: Download MP4 videos directly to `/home/user/MyDocs/Videos/` for offline playback in the built-in `DownloadsPage` or native Gallery.
- **Multi-Threaded HTTP Range Streaming**: RFC 7233 byte-range server bridge ensuring smooth, instant scrubbing without connection stalling.

### Architecture
- **N9 Native App (`gotube/`)**: Qt 4.7 / C++ core network manager interfacing with QtQuick 1.1 UI components and GStreamer multimedia pipelines.
- **Streaming Bridge v2 (`server/server.py`)**: Multi-threaded Python server on PC/WSL that bridges modern TLS 1.3 requirements, prevents 403 blocks via `yt-dlp`, and serves HTTP Range streams and REST APIs to the N9.
<img width="480" height="854" alt="Screenshot_20261009_090250" src="https://github.com/user-attachments/assets/8db1d4ba-a51e-4397-9199-2822f0c0f4e2" />
<img width="480" height="854" alt="Screenshot_20261009_090244" src="https://github.com/user-attachments/assets/a989a854-544e-4459-a93d-863fe339aa50" />
<img width="854" height="480" alt="SILVER_2026-09-27_21-00-38" src="https://github.com/user-attachments/assets/a366d97c-6a4f-413e-b957-7c70ecbd3c89" />
<img width="854" height="480" alt="Screenshot_20261009_091552" src="https://github.com/user-attachments/assets/6773c5cb-1454-41ff-8fe6-19226dc7a7e4" />
<img width="480" height="854" alt="Screenshot_20261009_091508" src="https://github.com/user-attachments/assets/2a1cdd0e-a47c-4b1f-9b9f-b05709bebf79" />

### Getting Started

#### 1. Setup Streaming Proxy (PC / WSL)
1. Install Python 3 and `yt-dlp`:
   ```bash
   pip install yt-dlp
   ```
2. Start the proxy server:
   ```bash
   python3 server/server.py
   ```
   *(Ensure PC and Nokia N9 are connected to the same local Wi-Fi network).*

#### 2. Running on Nokia N9
Copy the `gotube` files to the phone or install the Debian package:
```bash
# Run directly from terminal or launch from application grid
gotube
```

### Building from Source (Harmattan SDK)
Inside the Harmattan Scratchbox / Docker build environment:
```bash
cd gotube
qmake
make
dpkg-buildpackage -rfakeroot -uc -us -b
```

---

<a name="türkçe"></a>
## Türkçe

GoTube v2.0, MeeGo 1.2 Harmattan işletim sistemli Nokia N9 için özel olarak geliştirilmiş, donanım hızlandırmalı ve modern mobil YouTube deneyimini N9'un AMOLED ekranına taşıyan yerel istemcidir. Saf Qt 4.7 ve Qt Quick (QML 1.1) mimarisi üzerine kuruludur.

### v2.0 ile Gelen Yenilikler
- **Çift Dokunma ile ±10 Saniye Atlama**: Ekranın sol yarısına çift dokunarak 10 saniye geri, sağ yarısına çift dokunarak 10 saniye ileri sarma (animasyonlu rozet gösterimi ile).
- **Oynatma Hızı Ayarı**: `0.75x`, `1.0x`, `1.25x`, `1.5x` ve `2.0x` hız seçenekleri arasında tek dokunuşla geçiş.
- **360p / 720p HD Kalite Seçimi**: Pil dostu 360p ile kristal netliğindeki 720p HD akış arasında oynatma konumunu kaybetmeden geçiş yapabilme.
- **Trend Kategori Sekmeleri**: Ana ekranda Müzik, Oyun, Haberler ve Tümü filtre çipleriyle kategorilere göre video keşfi.
- **Sıradaki ve İlgili Videolar**: Oynatıcının altında mevcut videoyla ilişkili önerilen videoları listeleme ve tek tıkla yeni videoya geçebilme.
- **Kanal Detay Sayfası**: Video altındaki kanal adına dokunarak kanalın videolarını listeleme.
- **Entegre Çevrimdışı İndirme**: Videoları tek dokunuşla `/home/user/MyDocs/Videos/` dizinine MP4 olarak kaydetme ve `DownloadsPage` üzerinden internetsiz izleme.
- **Çok İş Parçacıklı HTTP Range Akışı**: RFC 7233 kısmi içerik destekli proxy ile takılmadan kesintisiz sarma.

### Mimari
- **N9 Yerel İstemci (`gotube/`)**: Qt 4.7 / C++ ağ katmanı, QtQuick 1.1 arayüz bileşenleri ve GStreamer video motoru.
- **Akış Köprüsü v2 (`server/server.py`)**: N9'un TLS 1.0 kısıtlamasını aşan, Invidious/yt-dlp üzerinden 403 engelini çözen ve HTTP Range desteği sunan PC/WSL sunucusu.

### Kurulum ve Kullanım

#### 1. Akış Sunucusunu Başlatma (PC / WSL)
1. Python 3 ve `yt-dlp` paketini kurun:
   ```bash
   pip install yt-dlp
   ```
2. Sunucuyu başlatın:
   ```bash
   python3 server/server.py
   ```
   *(Bilgisayar ve Nokia N9'un aynı yerel Wi-Fi ağına bağlı olduğundan emin olun).*

#### 2. Nokia N9 Üzerinde Çalıştırma
```bash
gotube
```

### Kaynak Koddan Derleme (Harmattan SDK)
```bash
cd gotube
qmake
make
dpkg-buildpackage -rfakeroot -uc -us -b
```

---

### Lisans / License
MIT License
