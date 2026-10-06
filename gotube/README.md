# GoTube — Nokia N9 (MeeGo 1.2 Harmattan) YouTube Client

[English](#english) | [Türkçe](#türkçe)

## English

GoTube is a native, hardware-accelerated YouTube client tailored specifically for the Nokia N9 running MeeGo 1.2 Harmattan. Built with Qt 4.7 and Qt Quick (QML 1.1), it provides an ad-free viewing experience powered by a lightweight local proxy bridge.

### Features

* **AMOLED-Optimized Dark UI**: True black (`#000000`) theme preserving battery life on the N9's 480x854 AMOLED screen.

* **Hardware-Accelerated Playback**: Leverages the TI OMAP3630 DSP/IVA2 hardware decoder via GStreamer for smooth 360p/720p H.264 playback.

* **Smooth Seeking (HTTP Range)**: Multi-threaded streaming proxy supporting RFC 7233 byte-range requests for instantaneous seeking without stream stalling.

* **Background Audio Mode ("Sadece Ses")**: Power-saving mode to stream audio only with display turned off.

* **Offline Downloads**: Download videos directly to `/home/user/MyDocs/Videos/` for offline viewing.

* **Native MeeGo Harmattan Icon**: 80x80 squircle icon matching the system Blanco theme guidelines.

### Architecture

* **N9 Native App (`gotube/`)**: Qt 4.7 / C++ core network manager interfacing with QtQuick 1.1 UI components and GStreamer multimedia pipelines.

* **Streaming Bridge (`server/server.py`)**: Multi-threaded Python proxy on PC/WSL that bridges modern TLS 1.3 requirements, prevents 403 blocks via `yt-dlp`, and serves HTTP Range streams to the N9.

### Getting Started

#### 1. Setup Streaming Proxy (PC / WSL)

1. Install Python 3 and `yt-dlp`:

   ```
   pip install yt-dlp
   
   ```

2. Start the proxy server:

   ```
   python3 server/server.py
   
   ```

   *(Ensure PC and Nokia N9 are connected to the same local Wi-Fi network).*

#### 2. Running on Nokia N9

Copy the `gotube` files to the phone or install the Debian package:

```
# Run directly from terminal or launch from application grid
gotube

```

### Building from Source (Harmattan SDK)

Inside the Harmattan Scratchbox / Docker build environment:

```
cd gotube
qmake
make
dpkg-buildpackage -rfakeroot -uc -us -b

```

## Türkçe

GoTube, MeeGo 1.2 Harmattan işletim sistemli Nokia N9 için özel olarak geliştirilmiş, donanım hızlandırmalı ve modern özelliklere sahip yerel bir YouTube istemcisidir. Saf Qt 4.7 ve Qt Quick (QML 1.1) mimarisi üzerine inşa edilmiştir.

### Özellikler

* **AMOLED Uyumlu Koyu Tema**: Nokia N9'un 480x854 AMOLED ekranında pil tüketimini en aza indiren saf siyah (`#000000`) arayüz.

* **Donanım Hızlandırmalı Oynatma**: TI OMAP3630 DSP/IVA2 yongası ve GStreamer altyapısıyla akıcı H.264 (360p / 720p) video deneyimi.

* **Kesintisiz İleri/Geri Sarma (HTTP Range)**: RFC 7233 kısmi içerik (206 Partial Content) destekli çok iş parçacıklı proxy mimarisiyle takılmadan anında sarma.

* **Sadece Ses Modu (Arka Planda Dinleme)**: Ekran kapalıyken veya pil tasarrufu için yalnızca ses akışını dinleyebilme.

* **Yerel İndirme (Çevrimdışı MP4)**: Videoları doğrudan `/home/user/MyDocs/Videos/` dizinine MP4 olarak kaydetme.

* **Özel MeeGo Squircle İkonu**: Blanco sistem teması tasarım rehberine tam uyumlu 80x80 vektörel uygulama simgesi.

### Mimari

* **N9 Yerel İstemci (`gotube/`)**: Qt 4.7 / C++ ağ katmanı, QtQuick 1.1 arayüz bileşenleri ve GStreamer video motoru.

* **Akış Köprüsü (`server/server.py`)**: N9'un TLS 1.0 kısıtlamasını aşan, Invidious/yt-dlp üzerinden 403 engelini çözen ve HTTP Range desteği sunan PC/WSL sunucusu.

### Kurulum ve Kullanım

#### 1. Akış Sunucusunu Başlatma (PC / WSL)

1. Python 3 ve `yt-dlp` paketini kurun:

   ```
   pip install yt-dlp
   
   ```

2. Sunucuyu başlatın:

   ```
   python3 server/server.py
   
   ```

   *(Bilgisayar ve Nokia N9'un aynı yerel Wi-Fi ağına bağlı olduğundan emin olun).*

#### 2. Nokia N9 Üzerinde Çalıştırma

Uygulama dosyalarını cihaza aktardıktan sonra uygulama menüsünden simgeye dokunarak veya terminalden:

```
gotube

```

komutuyla başlatabilirsiniz.

### Kaynak Koddan Derleme (Harmattan SDK)

Harmattan Scratchbox veya Docker ortamında:

```
cd gotube
qmake
make
dpkg-buildpackage -rfakeroot -uc -us -b

```

### Lisans / License

MIT License