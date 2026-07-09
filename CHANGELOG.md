## 1.3.2

* Fixed iOS playback failure for cached audio files. Cached files are stored
  on disk under an MD5-hashed filename with no extension. Android inspects the
  file's magic bytes to detect the format, but iOS (AVFoundation) relies on the
  file extension or an explicit MIME type hint and would silently fail to play.
  A MIME type is now derived from the original URL's extension (e.g. `.mp3` →
  `audio/mpeg`) and passed to `DeviceFileSource`, ensuring consistent playback
  across both platforms. Supported hints: mp3/mpeg, m4a/mp4, aac, wav, ogg,
  flac.

## 1.3.1

* Fixed `HiveError: You need to initialize Hive or provide a path to store the
  box.` that some users hit when calling `init()`. `init()` swallowed **every**
  error from `Hive.initFlutter()`, masking real failures (such as a missing
  `path_provider` plugin path when the Flutter binding wasn't ready) and then
  crashing inside `openBox()` with a misleading message.
  * `init()` now calls `WidgetsFlutterBinding.ensureInitialized()` and only
    ignores an `already-initialized` `HiveError`; any other error propagates
    with its real cause.
  * The lazy `_getCacheBox()` fallback now ensures the binding is ready before
    initializing Hive as well.

## 1.3.0

* Fixed a cache key collision: cache keys are now derived by MD5-hashing the
  full URL instead of using only the last path segment. Previously two
  different URLs that shared the same filename (e.g. `.../x/track.mp3` and
  `.../y/track.mp3`) resolved to the same key and could serve each other's
  audio.
* Added `crypto` dependency (used for MD5 hashing of cache keys).

  Note: because the key derivation changed, files cached by earlier versions
  will not be found under the new keys and will be re-downloaded once.

## 1.2.1

* Added a runnable `example/` Flutter app demonstrating playback,
  download progress, pre-caching and cache management.

## 1.2.0

Backwards-compatible feature release — no breaking changes.

* Added `CacheAudioPlayerPlus.init()` one-shot initializer for Hive.
* Added `playLocalAudio()` to play audio files from the device file system.
* Added `playAssetAudio()` to play audio bundled as a Flutter asset.
* Added `preCacheAudio()` to download and cache a URL without playing it
  (useful for pre-warming the next track in a playlist).
* Added `onDownloadProgress` callback to `playerNetworkAudio()` so you can
  show download progress the first time a file is fetched.
* Added cache inspection APIs: `isCached()`, `getCachedFilePath()`,
  `getCachedKeys()`, `getCacheSize()`.
* Added cache mutation APIs: `clearCacheForUrl()`, `clearCache()`.
* `playerNetworkAudio()` now verifies the cached file still exists on disk
  before replaying it, and falls back to re-downloading if it was removed.
* Cache box is now lazily initialized, so callers that forgot to call
  `Hive.initFlutter()` no longer crash.
* Upgraded dependencies to the latest stable versions:
  * `audioplayers` ^6.6.0
  * `dio` ^5.9.2
  * `flutter_lints` ^6.0.0

## 1.1.1

* Version for dependencies has been updated to latest.

## 1.0.0

* Initial Version of Cache Audio Player Plus
