# Cache Audio Player Plus

[![pub package](https://img.shields.io/pub/v/cache_audio_player_plus.svg)](https://pub.dev/packages/cache_audio_player_plus)

A lightweight, drop-in Flutter audio player that **streams and caches** network
audio. The first time a URL is played it is downloaded to local storage; every
time after that it plays instantly from disk — no re-downloads, no wasted
bandwidth, and full offline support.

Built on top of [`audioplayers`](https://pub.dev/packages/audioplayers) with
[`dio`](https://pub.dev/packages/dio) for downloads and
[`hive_flutter`](https://pub.dev/packages/hive_flutter) for the cache index.

## Features

- Stream and play network audio with **one line of code**.
- Automatic **on-disk caching** — each URL is downloaded only once.
- **Pre-cache** audio files ahead of time for instant playback.
- Full **cache management**: check, inspect size, clear single entry or the
  whole cache.
- Download **progress callback** so you can show a spinner/progress bar.
- Play from **network, local files, or Flutter assets**.
- Fine-grained **playback controls**: play, pause, resume, stop, seek, volume,
  balance, playback rate, release mode, audio context.
- Reactive **streams** for position, duration, state, seek and completion.
- Works on Android, iOS, macOS, Windows and Linux.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  cache_audio_player_plus: ^1.2.0
```

Then run:

```bash
flutter pub get
```

## Getting started

Initialize the plugin once in your `main()`:

```dart
import 'package:flutter/material.dart';
import 'package:cache_audio_player_plus/cache_audio_player_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheAudioPlayerPlus.init(); // optional but recommended
  runApp(const MyApp());
}
```

> `init()` is **optional**. If you skip it, the library will lazily set itself
> up the first time a cache-aware method is called. Calling it explicitly just
> removes that first-call latency and makes startup predictable.

Create a player instance and play something:

```dart
final player = CacheAudioPlayerPlus();

// Downloads and caches the file on the first call, then plays it.
// Every subsequent call plays instantly from local storage.
await player.playerNetworkAudio(
  url: 'https://example.com/audio/track.mp3',
);
```

That's it. No manual cache plumbing required.

## Usage

### Play a network audio file (with caching)

```dart
await player.playerNetworkAudio(
  url: 'https://example.com/track.mp3',
  cache: true, // default
  volume: 1.0,
  onDownloadProgress: (received, total) {
    if (total > 0) {
      final percent = (received / total * 100).toStringAsFixed(0);
      debugPrint('Downloading: $percent%');
    }
  },
);
```

Set `cache: false` if you want to stream straight from the network without
saving a copy.

### Play a local file

```dart
await player.playLocalAudio(filePath: '/path/to/audio.mp3');
```

### Play a Flutter asset

```dart
await player.playAssetAudio(assetPath: 'sounds/ding.mp3');
```

Remember to register the asset in your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - sounds/ding.mp3
```

### Pre-cache audio (download now, play later)

```dart
// Warm up the cache for the next track so it starts instantly.
await player.preCacheAudio(
  url: 'https://example.com/next-track.mp3',
  onDownloadProgress: (received, total) {
    // update a progress indicator
  },
);
```

### Inspect the cache

```dart
final cached = await player.isCached('https://example.com/track.mp3');

final path = await player.getCachedFilePath('https://example.com/track.mp3');

final keys = await player.getCachedKeys();

final bytes = await player.getCacheSize();
debugPrint('Cache size: ${(bytes / 1024 / 1024).toStringAsFixed(2)} MB');
```

### Clear the cache

```dart
// Remove a single file
await player.clearCacheForUrl('https://example.com/track.mp3');

// Or wipe everything
await player.clearCache();
```

### Playback controls

```dart
await player.pause();
await player.resume();
await player.stop();
await player.release();

await player.seek(const Duration(seconds: 30));
await player.setVolume(0.5);              // 0.0 .. 1.0
await player.setBalance(0.0);             // -1.0 .. 1.0
await player.setPlaybackRate(1.5);        // 0.5 .. 2.0 (iOS/macOS)
await player.setReleaseMode(ReleaseMode.loop);
```

### Listen to streams

```dart
player.onPlayerStateChanged.listen((PlayerState state) {
  // stopped / playing / paused / completed / disposed
});

player.onPositionChanged.listen((Duration position) {
  // update your progress bar
});

player.onDurationChanged.listen((Duration duration) {
  // total length of the currently loaded file
});

player.onPlayerComplete.listen((_) {
  // the track finished
});

player.onSeekComplete.listen((_) {
  // a seek operation finished
});
```

### Query the current state

```dart
final PlayerState state = player.state;
final Duration? position = await player.getCurrentPosition();
final Duration? duration = await player.getDuration();
```

### Dispose when you are done

```dart
await player.dispose();
```

## Full example

```dart
import 'package:flutter/material.dart';
import 'package:cache_audio_player_plus/cache_audio_player_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheAudioPlayerPlus.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: PlayerScreen());
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _player = CacheAudioPlayerPlus();
  static const _url =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  double _progress = 0;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await _player.playerNetworkAudio(
      url: _url,
      onDownloadProgress: (received, total) {
        if (total > 0) {
          setState(() => _progress = received / total);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cache Audio Player Plus')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_progress > 0 && _progress < 1)
              LinearProgressIndicator(value: _progress),
            ElevatedButton(onPressed: _play, child: const Text('Play')),
            ElevatedButton(
              onPressed: _player.pause,
              child: const Text('Pause'),
            ),
            ElevatedButton(
              onPressed: _player.resume,
              child: const Text('Resume'),
            ),
            ElevatedButton(
              onPressed: _player.stop,
              child: const Text('Stop'),
            ),
            ElevatedButton(
              onPressed: _player.clearCache,
              child: const Text('Clear cache'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API reference

### Setup

| Method | Description |
| --- | --- |
| `static Future<void> CacheAudioPlayerPlus.init()` | One-shot initializer. Optional — call from `main()` to prewarm Hive. |

### Playback

| Method | Description |
| --- | --- |
| `playerNetworkAudio({url, cache, volume, balance, ctx, position, mode, onDownloadProgress})` | Play a network URL. Downloads & caches on first use (when `cache: true`, the default). |
| `playLocalAudio({filePath, ...})` | Play a file that already exists on the device. |
| `playAssetAudio({assetPath, ...})` | Play an asset bundled with the app. |
| `pause()` | Pause current playback. |
| `resume()` | Resume paused playback. |
| `stop()` | Stop playback and reset position. |
| `release()` | Release native resources. |
| `seek(Duration position)` | Move the playhead. |
| `dispose()` | Dispose of the player instance. |

### Cache management

| Method | Description |
| --- | --- |
| `isCached(String url)` | `true` if the URL is cached and the file still exists. |
| `getCachedFilePath(String url)` | Local path for the cached URL, or `null`. |
| `preCacheAudio({url, onDownloadProgress})` | Download & cache a URL without playing it. |
| `clearCacheForUrl(String url)` | Remove a single cached entry. |
| `clearCache()` | Wipe the entire cache. |
| `getCacheSize()` | Total cached bytes on disk. |
| `getCachedKeys()` | List of all cached URL keys. |

### Audio settings

| Method | Description |
| --- | --- |
| `setVolume(double)` | Volume between `0.0` (mute) and `1.0` (max). |
| `setBalance(double)` | Stereo balance between `-1.0` (left) and `1.0` (right). |
| `setPlaybackRate(double)` | Playback speed. |
| `setReleaseMode(ReleaseMode)` | `stop`, `loop` or `release` on completion. |
| `setPlayerMode(PlayerMode)` | `mediaPlayer` or `lowLatency`. |
| `setAudioContext(AudioContext)` | Platform-specific audio focus / category. |

### Queries

| Getter / method | Description |
| --- | --- |
| `state` | Current `PlayerState`. |
| `getCurrentPosition()` | Current playhead position. |
| `getDuration()` | Total duration of the loaded file. |

### Streams

| Stream | Fires when |
| --- | --- |
| `onPlayerStateChanged` | State changes (stopped / playing / paused / completed / disposed). |
| `onPositionChanged` | Playhead position advances (≈ every 200 ms). |
| `onDurationChanged` | Duration of the loaded file becomes known. |
| `onPlayerComplete` | Playback reaches the end. |
| `onSeekComplete` | A `seek()` operation finishes. |
| `onLog` | Internal log messages. |

## Migration from 1.1.x

Version **1.2.0** is fully backwards compatible with 1.1.x — every existing
method keeps the same signature and behavior. The new `init()`, cache
management and asset/local playback APIs are purely additive.

The only optional change worth making is calling
`await CacheAudioPlayerPlus.init()` from your `main()` to prewarm Hive.

## Contributing

Issues and pull requests are very welcome on
[GitHub](https://github.com/cyclone-pk/cache_audio_player_plus).

## License

[MIT](LICENSE)
