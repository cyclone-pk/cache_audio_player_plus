library cache_audio_player_plus;

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// This represents a single CacheAudioPlayerPlus, which can play one audio at a time.
/// To play several audios at the same time, you must create several instances
/// of this class.
///
/// It holds methods to play, loop, pause, stop, seek the audio, and some useful
/// hooks for handlers and callbacks.
class CacheAudioPlayerPlus {
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// get Current State of the Player
  /// initial state, stop has been called or an error occurred.
  ///  stopped,
  ///
  /// Currently playing audio.
  /// playing,
  ///
  /// Pause has been called.
  /// paused,
  ///
  /// The audio successfully completed (reached the end).
  /// completed,
  ///
  /// The player has been disposed and should not be used anymore.
  /// disposed,
  PlayerState get state => _audioPlayer.state;

  /// Stream of changes on player state.
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;

  /// Stream of changes on audio position.
  ///
  /// Roughly fires every 200 milliseconds. Will continuously update the
  /// position of the playback if the status is [PlayerState.playing].
  ///
  /// You can use it on a progress bar, for instance.
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;

  /// Stream of changes on audio duration.
  ///
  /// An event is going to be sent as soon as the audio duration is available
  /// (it might take a while to download or buffer it).
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  /// Stream of player completions.
  ///
  /// Events are sent every time an audio is finished, therefore no event is
  /// sent when an audio is paused or stopped.
  ///
  /// [ReleaseMode.loop] also sends events to this stream.
  Stream get onPlayerComplete => _audioPlayer.onPlayerComplete;

  /// Stream of seek completions.
  ///
  /// An event is going to be sent as soon as the audio seek is finished.
  Stream get onSeekComplete => _audioPlayer.onSeekComplete;

  Stream<String> get onLog => _audioPlayer.onLog;

  ///playing  network audio directly from string url
  ///you can enable and disable caching by passing cache default is true
  Future playerNetworkAudio({
    required String url,
    bool cache = true,
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    if (cache) {
      Box cacheBox = (await Hive.openBox('cacheAudioPlayerPlus'));
      String urlAsKey = url.split('/').last;
      if (cacheBox.get(urlAsKey) != null) {
        await _audioPlayer.play(
          DeviceFileSource(cacheBox.get(urlAsKey)),
          volume: volume,
          position: position,
          balance: balance,
          ctx: ctx,
          mode: mode,
        );
        return;
      }
      try {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String audioFilePath = '${appDocDir.path}/$urlAsKey';
        await Dio().download(url, audioFilePath);
        cacheBox.put(urlAsKey, audioFilePath);
        await _audioPlayer.play(
          DeviceFileSource(audioFilePath),
          volume: volume,
          position: position,
          balance: balance,
          ctx: ctx,
          mode: mode,
        );
      } catch (e) {
        debugPrint('Error ${e.toString()}');
        debugPrint('Please Report This Error To The Developer Of This Package');
      }
    } else {
      try {
        await _audioPlayer.play(
          UrlSource(url),
          volume: volume,
          position: position,
          balance: balance,
          ctx: ctx,
          mode: mode,
        );
      } catch (e) {
        debugPrint('Error ${e.toString()}');
        debugPrint('Please Report This Error To The Developer Of This Package');
      }
    }
  }

  /// Stops the audio that is currently playing.
  ///
  /// The position is going to be reset and you will no longer be able to resume
  /// from the last point.
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Pauses the audio that is currently playing.
  ///
  /// If you call [resume] later, the audio will resume from the point that it
  /// has been paused.
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Resumes the audio that has been paused or stopped.
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  /// Releases the resources associated with this media player.
  ///
  /// The resources are going to be fetched or buffered again as soon as you
  /// call [resume] or change the source.
  Future<void> release() async {
    await _audioPlayer.release();
  }

  /// Moves the cursor to the desired position.
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setAudioContext(AudioContext ctx) async {
    await _audioPlayer.setAudioContext(ctx);
  }

  Future<void> setPlayerMode(PlayerMode mode) async {
    await _audioPlayer.setPlayerMode(mode);
  }

  /// Sets the stereo balance.
  ///
  /// -1 - The left channel is at full volume; the right channel is silent.
  ///  1 - The right channel is at full volume; the left channel is silent.
  ///  0 - Both channels are at the same volume.
  Future<void> setBalance(double balance) async {
    await _audioPlayer.setBalance(balance);
  }

  /// Sets the volume (amplitude).
  ///
  /// 0 is mute and 1 is the max volume. The values between 0 and 1 are linearly
  /// interpolated.
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  /// Sets the release mode.
  ///
  /// Check [ReleaseMode]'s doc to understand the difference between the modes.
  Future<void> setReleaseMode(ReleaseMode releaseMode) async {
    await _audioPlayer.setReleaseMode(releaseMode);
  }

  /// Sets the playback rate - call this after first calling play() or resume().
  ///
  /// iOS and macOS have limits between 0.5 and 2x
  /// Android SDK version should be 23 or higher
  Future<void> setPlaybackRate(double playbackRate) async {
    await _audioPlayer.setPlaybackRate(playbackRate);
  }

  /// Get audio duration after setting url.
  /// It will be available as soon as the audio duration is available
  /// (it might take a while to download).
  Future<Duration?> getDuration() async {
    return _audioPlayer.getDuration();
  }

  // Gets audio current playing position
  Future<Duration?> getCurrentPosition() async {
    return _audioPlayer.getCurrentPosition();
  }

  /// You must call this method when your [CacheAudioPlayerPlus] instance is not going to
  /// be used anymore. If you try to use it after this you will get errors.
  Future<void> dispose() async {
    // First stop and release all native resources.
    _audioPlayer.dispose();
  }
}
