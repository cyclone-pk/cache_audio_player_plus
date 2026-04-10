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
