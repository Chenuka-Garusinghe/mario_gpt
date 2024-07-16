import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'mario_game.dart';

void main() {
  runApp(
    const GameWidget<MarioGame>.controlled(
      gameFactory: MarioGame.new,
    ),
  );
}
