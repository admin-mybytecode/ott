import 'package:flutter/cupertino.dart';

enum PlayerState { stopped, playing, paused }

class AudioState extends ChangeNotifier {
  PlayerState _playerState = PlayerState.paused;
  PlayerState get playerState => _playerState;

  void state(PlayerState pstate) {
    _playerState = pstate;
    notifyListeners();
    print("notified listeners for audiostate change");
  }
}
