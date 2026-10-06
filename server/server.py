import http.server
import socketserver
import threading
import json
import urllib.parse
import urllib.request
import yt_dlp
import os

# GoTube Stream Proxy for Nokia N9 (MeeGo 1.2 Harmattan)
CACHE_DIR = "/tmp/gotube_cache"
os.makedirs(CACHE_DIR, exist_ok=True)
PC_IP = "192.168.8.137:8888"

# 403 Forbidden engelini aşan istemci ayarları:
EXTRACTOR_ARGS = {'youtube': {'player_client': ['android', 'web_embedded']}}

ydl_flat = yt_dlp.YoutubeDL({'extract_flat': True, 'quiet': True, 'no_warnings': True, 'extractor_args': EXTRACTOR_ARGS})

# Eşzamanlı isteklerde aynı videoyu iki kez indirmeyi önleyen kilit havuzu:
download_locks = {}
locks_mutex = threading.Lock()

def get_video_lock(vid):
    with locks_mutex:
        if vid not in download_locks:
            download_locks[vid] = threading.Lock()
        return download_locks[vid]

def get_trending():
    try:
        res = ydl_flat.extract_info('ytsearch25:trend muzik', download=False)
        videos = []
        for e in res.get('entries', []):
            if e and e.get('id'):
                vid = e.get('id')
                videos.append({
                    'videoId': vid,
                    'title': e.get('title', ''),
                    'author': e.get('uploader') or e.get('channel') or '',
                    'lengthSeconds': e.get('duration') or 0,
                    'videoThumbnails': [{'url': 'http://' + PC_IP + '/thumb/' + vid + '.jpg'}],
                    'publishedText': ''
                })
        print(f"-> [GoTube] {len(videos)} adet trend video hazırlandı.")
        return videos
    except Exception as ex:
        print('Trending hatasi:', ex)
        return []

def get_search(q):
    try:
        res = ydl_flat.extract_info('ytsearch20:' + q, download=False)
        videos = []
        for e in res.get('entries', []):
            if e and e.get('id'):
                vid = e.get('id')
                videos.append({
                    'videoId': vid,
                    'title': e.get('title', ''),
                    'author': e.get('uploader') or '',
                    'videoThumbnails': [{'url': 'http://' + PC_IP + '/thumb/' + vid + '.jpg'}]
                })
        return videos
    except Exception as ex:
        print('Search hatasi:', ex)
        return []

def get_video_info(vid):
    return {
        'title': 'Video Oynatılıyor',
        'author': '',
        'description': '',
        'formatStreams': [{'url': 'http://' + PC_IP + '/stream/' + vid + '.mp4', 'container': 'mp4', 'qualityLabel': '360p'}]
    }

class RobustProxy(http.server.SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_GET(self):
        p = urllib.parse.urlparse(self.path)
        q = urllib.parse.parse_qs(p.query)

        # 1. Küçük Resimleri Aktar:
        if p.path.startswith('/thumb/'):
            vid = p.path.split('/')[-1].replace('.jpg', '')
            try:
                req = urllib.request.Request(f"https://i.ytimg.com/vi/{vid}/hqdefault.jpg", headers={'User-Agent': 'Mozilla/5.0'})
                img_data = urllib.request.urlopen(req, timeout=6).read()
                self.send_response(200)
                self.send_header('Content-Type', 'image/jpeg')
                self.send_header('Content-Length', str(len(img_data)))
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Connection', 'close')
                self.end_headers()
                self.wfile.write(img_data)
                return
            except:
                self.send_response(404)
                self.send_header('Content-Length', '0')
                self.send_header('Connection', 'close')
                self.end_headers()
                return

        # 2. 403 Korumalı, Çok İş Parçacıklı & Range (İleri Sarma) Destekli Akış:
        if p.path.startswith('/stream/'):
            vid = p.path.split('/')[-1].replace('.mp4', '')
            cache_file = os.path.join(CACHE_DIR, f"{vid}.mp4")

            if not os.path.exists(cache_file):
                with get_video_lock(vid):
                    if not os.path.exists(cache_file):
                        print(f"-> [GoTube] Video N9 için hazırlanıyor ({vid})...")
                        opts = {
                            'format': '18/best[ext=mp4][height<=720]/best[ext=mp4]',
                            'outtmpl': cache_file,
                            'quiet': True,
                            'no_warnings': True,
                            'extractor_args': EXTRACTOR_ARGS
                        }
                        try:
                            with yt_dlp.YoutubeDL(opts) as ydl:
                                ydl.download([f"https://www.youtube.com/watch?v={vid}"])
                            print(f"-> [GoTube] Video başarıyla indirildi ({os.path.getsize(cache_file)} byte)! N9'a aktarılıyor...")
                        except Exception as e:
                            print("-> [HATA] Video indirilemedi:", e)
                            self.send_response(500)
                            self.send_header('Content-Length', '0')
                            self.send_header('Connection', 'close')
                            self.end_headers()
                            return

            try:
                size = os.path.getsize(cache_file)
                range_header = self.headers.get('Range')
                start, end = 0, size - 1
                status_code = 200

                if range_header and range_header.startswith('bytes='):
                    parts = range_header[6:].split('-')
                    if parts[0]: start = int(parts[0])
                    if len(parts) > 1 and parts[1]: end = int(parts[1])
                    status_code = 206

                length = end - start + 1
                self.send_response(status_code)
                self.send_header('Content-Type', 'video/mp4')
                self.send_header('Accept-Ranges', 'bytes')
                self.send_header('Content-Length', str(length))
                if status_code == 206:
                    self.send_header('Content-Range', f"bytes {start}-{end}/{size}")
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()

                with open(cache_file, 'rb') as f:
                    f.seek(start)
                    remaining = length
                    while remaining > 0:
                        chunk_size = min(remaining, 64 * 1024)
                        chunk = f.read(chunk_size)
                        if not chunk: break
                        self.wfile.write(chunk)
                        remaining -= len(chunk)
                return
            except (BrokenPipeError, ConnectionResetError):
                return
            except Exception as ex:
                print("Akış aktarım hatası:", ex)
                return

        # 3. JSON API:
        data = None
        if p.path.startswith('/api/v1/trending'):
            data = get_trending()
        elif p.path.startswith('/api/v1/search'):
            data = get_search(q.get('q', [''])[0])
        elif p.path.startswith('/api/v1/videos/'):
            vid = p.path.split('/')[-1]
            data = get_video_info(vid)

        if data is not None:
            body = json.dumps(data).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Content-Length', str(len(body)))
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Connection', 'close')
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.send_header('Content-Length', '0')
            self.send_header('Connection', 'close')
            self.end_headers()

class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

if __name__ == '__main__':
    print('GoTube Kesintisiz Akış Köprüsü (Çok İş Parçacıklı & Range Destekli) 8888 portunda hazır!')
    ThreadingHTTPServer(('0.0.0.0', 8888), RobustProxy).serve_forever()
