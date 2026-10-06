# GoTube Proxy Server v2.0

Streaming and API Bridge for Nokia N9 (MeeGo 1.2 Harmattan) YouTube Client.

## Features in v2.0
- Multi-threaded HTTP Range request handling (RFC 7233) for instant seeking without stalling.
- Dynamic 360p / 720p HD format extraction via `yt-dlp`.
- Trending categories support (`type=music`, `type=gaming`, `type=news`, `type=all`).
- Related videos recommendation endpoint (`/api/v1/related/<id>`).
- Channel video listings endpoint (`/api/v1/channels/<id>`).

## Requirements
- Python 3.8+
- `yt-dlp` (`pip install yt-dlp`)

## Running
```bash
python3 server.py
```
Listens on `0.0.0.0:8888`. Ensure Nokia N9 is on the same local Wi-Fi network.
