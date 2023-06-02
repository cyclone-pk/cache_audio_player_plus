

A Flutter plugin to play multiple simultaneously network audio files. this is extension of audioplayers.

We tried to make cache_network_player_plus as simple to use as possible:

creating instance and then playing the audio from the url
```dart
final player = CacheAudioPlayerPlus();
player.playerNetworkAudio(url: "https://youraudiofilelink", cache: true);
```

pausing the current playing audio
```dart
player.pause();
```

stop playing the current playing audio
```dart
player.stop();
```

resume the pause audio
```dart
player.resume();
```

moving cursor to a specific position
```dart
player.seek();
```

setVolume of the player
```dart
player.setBalance(double);
```

setBalance of the player
```dart
player.setBalance(double);
```

get Current State of the Player
stopped,
playing,
paused,
completed,
disposed,
```dart
PlayerState state = player.state;
```

Stream of changes on audio duration.
```dart
player.onDurationChanged.listen((duration) {});
```

Stream of changes on audio position.
```dart
player.onPositionChanged.listen((duration) {});
```

Stream of PlayerState.
```dart
player.onPositionChanged.onPlayerStateChanged((playerState) {});
```


