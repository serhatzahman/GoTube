import http.server
import socketserver
import threading
import json
import urllib.parse
import urllib.request
import yt_dlp
import os
import re

# GoTube Stream & API Proxy v2.0 for Nokia N9 (MeeGo 1.2 Harmattan)
CACHE_DIR = "/tmp/gotube_cache"
os.makedirs(CACHE_DIR, exist_ok=True)
PC_IP = "192.168.8.137:8888"

EXTRACTOR_ARGS = {'youtube': {'player_client': ['android', 'web_embedded']}}
ydl_flat = yt_dlp.YoutubeDL({'extract_flat': True, 'quiet': True, 'no_warnings': True, 'extractor_args': EXTRACTOR_ARGS})

download_locks = {}
locks_mutex = threading.Lock()

def get_video_lock(key):
    with locks_mutex:
        if key not in download_locks:
            download_locks[key] = threading.Lock()
        return download_locks[key]

CATEGORY_SEARCH_MAP = {
    'music': 'ytsearch25:trend muzik',
    'gaming': 'ytsearch25:trend oyun turkiye',
    'news': 'ytsearch25:haber gundem',
    'all': 'ytsearch25:trend turkiye'
}

def get_trending(category='music'):
    search_query = CATEGORY_SEARCH_MAP.get(category, CATEGORY_SEARCH_MAP['music'])
    try:
        res = ydl_flat.extract_info(search_query, download=False)
        videos = []
        for e in res.get('entries', []):
            if e and e.get('id'):
                vid = e.get('id')
                videos.append({
                    'videoId': vid,
                    'title': e.get('title', ''),
                    'author': e.get('uploader') or e.get('channel') or '',
                    'authorId': e.get('channel_id') or '',
                    'lengthSeconds': e.get('duration') or 0,
                    'videoThumbnails': [{'url': f'http://{PC_IP}/thumb/{vid}.jpg'}],
                    'publishedText': ''
                })
        print(f"-> [GoTube v2] {category.upper()} kategorisinde {len(videos)} video hazirlandi.")
        return videos
    except Exception as ex:
        print(f'Trending ({category}) hatasi:', ex)
        return []

def get_search(q):
    if not q: return []
    try:
        res = ydl_flat.extract_info(f'ytsearch20:{q}', download=False)
        videos = []
        for e in res.get('entries', []):
            if e and e.get('id'):
                vid = e.get('id')
                videos.append({
                    'videoId': vid,
                    'title': e.get('title', ''),
                    'author': e.get('uploader') or '',
                    'authorId': e.get('channel_id') or '',
                    'videoThumbnails': [{'url': f'http://{PC_IP}/thumb/{vid}.jpg'}]
                })
        return videos
    except Exception as ex:
        print('Search hatasi:', ex)
        return []

def get_related(vid, title=""):
    try:
        query = f'ytsearch10:{title}' if title else f'ytsearch10:youtube {vid}'
        res = ydl_flat.extract_info(query, download=False)
        related = []
        for e in res.get('entries', []):
            if e and e.get('id') and e.get('id') != vid:
                r_vid = e.get('id')
                related.append({
                    'videoId': r_vid,
                    'title': e.get('title', ''),
                    'author': e.get('uploader') or '',
                    'lengthSeconds': e.get('duration') or 0,
                    'videoThumbnails': [{'url': f'http://{PC_IP}/thumb/{r_vid}.jpg'}]
                })
        return related
    except Exception as ex:
        print('Related hatasi:', ex)
        return []

def get_channel_videos(channel_id):
    try:
        res = ydl_flat.extract_info(f'ytsearch20:channel {channel_id}', download=False)
        videos = []
        for e in res.get('entries', []):
            if e and e.get('id'):
                vid = e.get('id')
                videos.append({
                    'videoId': vid,
                    'title': e.get('title', ''),
                    'author': e.get('uploader') or '',
                    'videoThumbnails': [{'url': f'http://{PC_IP}/thumb/{vid}.jpg'}]
                })
        return {'channelId': channel_id, 'author': 'Kanal', 'latestVideos': videos}
    except Exception as ex:
        print('Channel hatasi:', ex)
        return {'channelId': channel_id, 'author': 'Kanal', 'latestVideos': []}

class RobustProxy(http.server.SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_GET(self):
        p = urllib.parse.urlparse(self.path)
        q = urllib.parse.parse_qs(p.query)

        # 1. Kucuk Resimleri Aktar:
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

        # 2. Cok Is Parcacikli, Kalite Destekli & Range Destekli Video Akisi:
        if p.path.startswith('/stream/'):
            raw_filename = p.path.split('/')[-1].replace('.mp4', '')
            
            # Kalite ayrıştırma: örn. vid veya vid_720p veya vid_360p
            quality = '360p'
            if '_720p' in raw_filename:
                vid = raw_filename.replace('_720p', '')
                quality = '720p'
            elif '_360p' in raw_filename:
                vid = raw_filename.replace('_360p', '')
                quality = '360p'
            else:
                vid = raw_filename
                
            cache_file = os.path.join(CACHE_DIR, f"{vid}_{quality}.mp4")

            if not os.path.exists(cache_file):
                lock_key = f"{vid}_{quality}"
                with get_video_lock(lock_key):
                    if not os.path.exists(cache_file):
                        print(f"-> [GoTube v2] Video hazirlaniyor ({vid} - {quality})...")
                        if quality == '720p':
                            format_spec = '22/best[ext=mp4][height<=720]/best[ext=mp4]'
                        else:
                            format_spec = '18/best[ext=mp4][height<=360]/best[ext=mp4]'
                            
                        opts = {
                            'format': format_spec,
                            'outtmpl': cache_file,
                            'quiet': True,
                            'no_warnings': True,
                            'extractor_args': EXTRACTOR_ARGS
                        }
                        try:
                            with yt_dlp.YoutubeDL(opts) as ydl:
                                ydl.download([f"https://www.youtube.com/watch?v={vid}"])
                            print(f"-> [GoTube v2] {quality} Video hazir ({os.path.getsize(cache_file)} byte)! Aktariliyor...")
                        except Exception as e:
                            print(f"-> [HATA] Video indirilemedi ({vid}):", e)
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
                print("Akis aktarim hatasi:", ex)
                return

        # 3. JSON API v2:
        data = None
        if p.path.startswith('/api/v1/trending'):
            cat = q.get('type', ['music'])[0]
            data = get_trending(cat)
        elif p.path.startswith('/api/v1/search'):
            data = get_search(q.get('q', [''])[0])
        elif p.path.startswith('/api/v1/related/'):
            vid = p.path.split('/')[-1]
            title = q.get('title', [''])[0]
            data = get_related(vid, title)
        elif p.path.startswith('/api/v1/channels/'):
            channel_id = p.path.split('/')[-1]
            data = get_channel_videos(channel_id)
        elif p.path.startswith('/api/v1/videos/'):
            vid = p.path.split('/')[-1]
            data = {
                'title': 'Video Oynatiliyor',
                'author': '',
                'formatStreams': [
                    {'url': f'http://{PC_IP}/stream/{vid}_360p.mp4', 'container': 'mp4', 'qualityLabel': '360p'},
                    {'url': f'http://{PC_IP}/stream/{vid}_720p.mp4', 'container': 'mp4', 'qualityLabel': '720p'}
                ]
            }

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
    print('GoTube v2.0 Kesintisiz Akis Koprusu 8888 portunda hazir!')
    ThreadingHTTPServer(('0.0.0.0', 8888), RobustProxy).serve_forever()
