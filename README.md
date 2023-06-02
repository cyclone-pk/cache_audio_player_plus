\# Cache Audio Player Plus

Cache Audio Player Plus is a Flutter plugin that extends the functionality of the audioplayers plugin. It allows you to play multiple network audio files simultaneously and provides caching capabilities for improved performance and offline playback. This plugin is particularly useful for voice chats and similar applications where audio files need to be played and cached for efficient playback without re-downloading from the network.

\## Usage

To use Cache Audio Player Plus, follow these steps:

1. Create an instance of the `CacheAudioPlayerPlus` class:

```dart
final player = CacheAudioPlayerPlus();
```

2. Play audio from a URL and enable caching:

```dart
player.playerNetworkAudio(url: "https://youraudiofilelink", cache: true);
```

3. Pause the currently playing audio:

```dart
player.pause();
```

4. Stop playing the current audio:

```dart
player.stop();
```

5. Resume the paused audio:

```dart
player.resume();
```

6. Move the audio cursor to a specific position:

```dart
player.seek();
```

7. Set the volume of the player:

```dart
player.setVolume(double);
```

8. Set the balance of the player:

```dart
player.setBalance(double);
```

9. Get the current state of the player:

```dart
PlayerState state = player.state;
```

Possible player states include:
- Stopped
- Playing
- Paused
- Completed
- Disposed

10. Subscribe to the stream of changes in audio duration:

```dart
player.onDurationChanged.listen((duration) {});
```

11. Subscribe to the stream of changes in audio position:

```dart
player.onPositionChanged.listen((duration) {});
```

12. Subscribe to the stream of player state changes:

```dart
player.onPositionChanged.onPlayerStateChanged((playerState) {});
```

Note: Ensure that you handle the appropriate events and errors when using the Cache Audio Player Plus plugin.

This readme file provides a simplified overview of the usage of Cache Audio Player Plus and its available methods. Refer to the plugin's documentation for detailed instructions and additional features.

We hope you find Cache Audio Player Plus helpful in incorporating network audio playback and caching functionality into your Flutter applications.
