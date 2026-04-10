import 'package:flutter/material.dart';
import 'package:cache_audio_player_plus/cache_audio_player_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Optional but recommended — pre-warms the cache index.
  await CacheAudioPlayerPlus.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cache Audio Player Plus Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const PlayerScreen(),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final CacheAudioPlayerPlus _player = CacheAudioPlayerPlus();

  // A small public-domain audio sample.
  static const String _audioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  double _downloadProgress = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayerState _state = PlayerState.stopped;
  int _cacheBytes = 0;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _state = s);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _refreshCacheSize();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _refreshCacheSize() async {
    final bytes = await _player.getCacheSize();
    if (mounted) setState(() => _cacheBytes = bytes);
  }

  Future<void> _play() async {
    await _player.playerNetworkAudio(
      url: _audioUrl,
      onDownloadProgress: (received, total) {
        if (total > 0 && mounted) {
          setState(() => _downloadProgress = received / total);
        }
      },
    );
    await _refreshCacheSize();
  }

  Future<void> _preCache() async {
    setState(() => _downloadProgress = 0);
    await _player.preCacheAudio(
      url: _audioUrl,
      onDownloadProgress: (received, total) {
        if (total > 0 && mounted) {
          setState(() => _downloadProgress = received / total);
        }
      },
    );
    await _refreshCacheSize();
  }

  Future<void> _clearCache() async {
    await _player.clearCache();
    await _refreshCacheSize();
    setState(() => _downloadProgress = 0);
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:'
      '${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isDownloading = _downloadProgress > 0 && _downloadProgress < 1;
    final cacheKb = (_cacheBytes / 1024).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(title: const Text('Cache Audio Player Plus')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('State: ${_state.name}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (isDownloading) ...[
              const Text('Downloading...'),
              const SizedBox(height: 4),
              LinearProgressIndicator(value: _downloadProgress),
              const SizedBox(height: 12),
            ],
            Slider(
              value: _position.inMilliseconds
                  .clamp(0, _duration.inMilliseconds)
                  .toDouble(),
              max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
              onChanged: (v) =>
                  _player.seek(Duration(milliseconds: v.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position)),
                Text(_fmt(_duration)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _play,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _player.pause,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _player.resume,
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Resume'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _player.stop,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Text('Cache: $cacheKb KB',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _preCache,
                  icon: const Icon(Icons.download),
                  label: const Text('Pre-cache'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final cached = await _player.isCached(_audioUrl);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          cached ? 'Audio is cached' : 'Audio is NOT cached',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Is cached?'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearCache,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Clear cache'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
