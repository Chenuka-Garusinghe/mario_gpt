import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mario_gpt/world_builder.dart';
import 'utils.dart';
import './actors/mario.dart';

class MarioGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  MarioGame();
  late Mario _mario;
  late List<Rect> solidBlocks;

  @override
  Future<void> onLoad() async {
    List<String> imageFiles = await findAssets(directory: 'assets/images/');
    print("These are the image files: $imageFiles\n");

    // Load images into Flame.images instead of this.images
    await Flame.images.loadAll(imageFiles);

    await WorldBuilder
        .initializeTileSizes(); // Make sure to initialize tile sizes

    camera.viewfinder.anchor = Anchor.topLeft;
    final (worldComponents, marioPosition, blocks) =
        await WorldBuilder.generateWorld('assets/level_1.txt');
    solidBlocks = blocks;
    world.addAll(worldComponents);
    _mario = Mario(position: marioPosition);
    _mario.setSolidBlocks(solidBlocks);
    world.add(_mario);
  }
}
