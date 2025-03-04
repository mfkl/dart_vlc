import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:dart_vlc/src/channel.dart';
import 'package:dart_vlc/src/playerState/playerState.dart';
import 'package:dart_vlc/src/mediaSource/mediaSource.dart';

/// Internally used class to avoid direct creation of the object of a+ [Player] class.
class _Player extends Player {}

/// A [Player] to open & play a [Media] or [Playlist] from file, network or asset.
///
/// Use [Player.create] method to create a new instance of a [Player].
/// Provide a unique [id] while instanciating.
///
/// ```dart
/// Player player = await Player.create(id: 0);
/// ```
///
/// Use various methods avaiable to control the playback.
/// [Player.state] stores the current state of [Player] in form of [PlayerState].
/// [Player.stream] can be used to listen to playback events of [Player] instance.
///
abstract class Player {
  /// ID associated with the [Player] instance.
  int id;

  /// State of the current & opened [MediaSource] in [Player] instance.
  CurrentState current = new CurrentState();

  /// Stream to listen to current & opened [MediaSource] state of the [Player] instance.
  Stream<CurrentState> currentStream;

  /// Position & duration state of the [Player] instance.
  PositionState position = new PositionState();

  /// Stream to listen to position & duration state of the [Player] instance.
  Stream<PositionState> positionStream;

  /// Playback state of the [Player] instance.
  PlaybackState playback = new PlaybackState();

  /// Stream to listen to playback state of the [Player] instance.
  Stream<PlaybackState> playbackStream;

  /// Volume & Rate state of the [Player] instance.
  GeneralState general = new GeneralState();

  /// Stream to listen to volume & rate state of the [Player] instance.
  Stream<GeneralState> generateStream;

  /// Creates a new [Player] instance.
  ///
  /// Takes unique id as parameter.
  ///
  /// ```dart
  /// Player player = await Player.create(id: 0);
  /// ```
  ///
  static Future<Player> create({@required int id}) async {
    await channel.invokeMethod(
      'create',
      {
        'id': id,
      },
    );
    players[id] = new _Player()..id = id;
    players[id].currentController = StreamController<CurrentState>.broadcast();
    players[id].currentStream = players[id].currentController.stream;
    players[id].positionController =
        StreamController<PositionState>.broadcast();
    players[id].positionStream = players[id].positionController.stream;
    players[id].playbackController =
        StreamController<PlaybackState>.broadcast();
    players[id].playbackStream = players[id].playbackController.stream;
    players[id].generalController = StreamController<GeneralState>.broadcast();
    players[id].generateStream = players[id].generalController.stream;
    return players[id];
  }

  /// Opens a new media source into the player.
  ///
  /// Takes a [Media] or [Playlist] to open in the player.
  ///
  /// Starts playback itself by default. Pass `autoStart: false` to stop this from happening.
  ///
  /// * Open a new [Media].
  ///
  /// ```dart
  /// player.open(
  ///   Media.file(
  ///     new File('C:/music.ogg'),
  ///   ),
  ///   autoStart: false,
  /// );
  /// ```
  ///
  /// * Open a new [Playlist].
  ///
  /// ```dart
  /// player.open(
  ///   new Playlist(
  ///     medias: [
  ///       Media.file(
  ///         new File('C:/music.mp3'),
  ///       ),
  ///       Media.file(
  ///         new File('C:/audio.mp3'),
  ///       ),
  ///       Media.network('https://alexmercerind.github.io/music.mp3'),
  ///     ],
  ///   ),
  /// );
  /// ```
  ///
  Future<void> open(MediaSource source, {bool autoStart: true}) async {
    if (this.currentController.isClosed) {
      players[this.id].currentController =
          StreamController<CurrentState>.broadcast();
      players[this.id].currentStream =
          players[this.id].currentController.stream;
      players[this.id].positionController =
          StreamController<PositionState>.broadcast();
      players[this.id].positionStream =
          players[this.id].positionController.stream;
      players[this.id].playbackController =
          StreamController<PlaybackState>.broadcast();
      players[this.id].playbackStream =
          players[this.id].playbackController.stream;
      players[this.id].generalController =
          StreamController<GeneralState>.broadcast();
      players[this.id].generateStream =
          players[this.id].generalController.stream;
    }
    await channel.invokeMethod(
      'open',
      {
        'id': this.id,
        'autoStart': autoStart,
        'source': source.toMap(),
      },
    );
  }

  /// Plays opened [MediaSource],
  Future<void> play() async {
    await channel.invokeMethod(
      'play',
      {
        'id': this.id,
      },
    );
  }

  /// Pauses opened [MediaSource],
  Future<void> pause() async {
    await channel.invokeMethod(
      'pause',
      {
        'id': this.id,
      },
    );
  }

  /// Play or Pause opened [MediaSource],
  Future<void> playOrPause() async {
    await channel.invokeMethod(
      'playOrPause',
      {
        'id': this.id,
      },
    );
  }

  /// Stops the [Player],
  Future<void> stop() async {
    await channel.invokeMethod(
      'stop',
      {
        'id': this.id,
      },
    );
    await this.currentController.close();
    await this.positionController.close();
    await this.playbackController.close();
    await this.generalController.close();
  }

  /// Jumps to the next [Media] in the [Playlist] opened.
  Future<void> next() async {
    await channel.invokeMethod(
      'next',
      {
        'id': this.id,
      },
    );
  }

  /// Jumps to the previous [Media] in the [Playlist] opened.
  Future<void> back() async {
    await channel.invokeMethod(
      'back',
      {
        'id': this.id,
      },
    );
  }

  /// Jumps to [Media] at specific index in the [Playlist] opened.
  /// Pass index as parameter.
  Future<void> jump(int index) async {
    await channel.invokeMethod(
      'back',
      {
        'id': this.id,
        'index': index,
      },
    );
  }

  /// Seeks the [Media] currently playing in the [Player] instance, to the provided [Duration].
  Future<void> seek(Duration duration) async {
    await channel.invokeMethod(
      'seek',
      {
        'id': this.id,
        'duration': duration.inMilliseconds,
      },
    );
  }

  /// Sets volume of the [Player] instance.
  Future<void> setVolume(double volume) async {
    await channel.invokeMethod(
      'setVolume',
      {
        'id': this.id,
        'volume': volume,
      },
    );
  }

  /// Sets playback rate of the [Media] currently playing in the [Player] instance.
  Future<void> setRate(double rate) async {
    await channel.invokeMethod(
      'setRate',
      {
        'id': this.id,
        'rate': rate,
      },
    );
  }

  /// Internally used [StreamController]s,
  StreamController<CurrentState> currentController;
  StreamController<PositionState> positionController;
  StreamController<PlaybackState> playbackController;
  StreamController<GeneralState> generalController;
}
