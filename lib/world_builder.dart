import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import '../utils.dart';

class WorldBuilder {
  static Map<String, Vector2> tileSizes = {};

  static double loadTileSize(String asciiCharacter) {
    // print("Attempting to load tile size for character: $asciiCharacter");

    String? tileKey;
    // print("This is the ascii character found $asciiCharacter");
    if (asciiCharacter == "G") {
      // print("This is the ascii character found $asciiCharacter");
    }
    switch (asciiCharacter) {
      case '=':
        tileKey = 'SMB_ground';
        break;
      case 'B':
        tileKey = 'SMB_brick';
        break;
      case 'P_H':
        tileKey = 'SMB_Warp_Pipe_Head';
        break;
      case 'P_B':
        'Warp_Pipe_Body';
        break;
      case 'G':
        tileKey = 'goomba_1';
        break;
      case 'W':
        tileKey = 'SMB_Wall';
        break;
      case 'M':
        tileKey = 'SMB_Mario';
        break;
      case 'C':
        tileKey = 'SMB_Castle';
        break;
      case 'F_P':
        tileKey = 'SMB_Flagpole';
        break;
      default:
        // print("Unknown ASCII character: $asciiCharacter");
        return 32.0; // Default size
    }

    if (tileSizes.containsKey(tileKey)) {
      // print("Tile size for $tileKey: ${tileSizes[tileKey]!.x}");
      return tileSizes[tileKey]!.x;
    } else {
      // print("Tile size not found for key: $tileKey");
      return 32.0; // Default size if not found
    }
  }

  // get the sprites dimensions based on PNG file
  static Future<void> initializeTileSizes() async {
    // get the file list using utils.dart
    List<String> imageFiles = await findAssets(directory: 'assets/images/');
    String suffix = '.png';
    String filename = "";

    // for each image file name, store ref by file name and dimmensions to map
    for (String image in imageFiles) {
      if (image.endsWith(suffix)) {
        filename = image.substring(0, (filename.length - suffix.length).abs());
      }
      tileSizes[filename] = getImageDimensions(image);
    }
  }

  static Component? _createComponent(String tile, Vector2 position) {
    switch (tile) {
      case '=':
        return SpriteComponent(
            sprite: Sprite(Flame.images.fromCache('SMB_ground.png')),
            position: position,
            size: Vector2.all(loadTileSize('=')));
      case 'B':
        return SpriteComponent(
            sprite: Sprite(Flame.images.fromCache('SMB_brick.png')),
            position: position,
            size: Vector2.all(loadTileSize('B')));
      case 'P_H':
        return SpriteComponent(
            sprite: Sprite(Flame.images.fromCache('SMB_Warp_Pipe_Head.png')),
            position: position,
            size: Vector2.all(loadTileSize('P_H')));
      case 'P_B':
        return SpriteComponent(
            sprite: Sprite(Flame.images.fromCache('Warp_Pipe_body.png')),
            position: position,
            size: Vector2.all(loadTileSize('P_B')));
      case 'G':
        return SpriteComponent(
            sprite: Sprite(Flame.images.fromCache('goomba_1.png')),
            position: position,
            size: Vector2.all(loadTileSize('G')));
      case 'W':
        return SpriteComponent(
            sprite: Sprite(Flame.images.fromCache('SMB_Wall.png')),
            position: position,
            size: Vector2.all(loadTileSize('W')));
      case 'C':
        return SpriteComponent(
            sprite: Sprite(Flame.images.fromCache('SMB_Castle.png')),
            position: position,
            size: Vector2.all(loadTileSize('C')));
      case 'F_P':
        return SpriteComponent(
            sprite: Sprite(Flame.images.fromCache('SMB_Flagpole.png')),
            position: position,
            size: Vector2.all(loadTileSize('F_P')));
      case 'M':
        return SpriteComponent(
            sprite: Sprite(Flame.images.fromCache('SMB_Mario.png')),
            position: position,
            size: Vector2.all(loadTileSize('M')));
      default:
        return null;
    }
  }

  static Future<(List<Component>, Vector2, List<Rect>)> generateWorld(
      String levelFile) async {
    List<Component> worldComponents = [];
    List<Rect> solidBlocks = [];

    Vector2 marioPosition = Vector2.zero();
    String levelData = await rootBundle.loadString(levelFile);
    List<String> fileRows = levelData.split('\n');

    if (tileSizes.isEmpty) {
      await initializeTileSizes();
    }

    for (int r = 0; r < fileRows.length; r++) {
      String currentFileRow = fileRows[r];
      // print("This is the currentFileRow --> $currentFileRow\n");

      for (int c = 0; c < currentFileRow.length; c++) {
        String tile = '';

        // Check for multi-character tiles
        if (c + 2 < currentFileRow.length &&
            currentFileRow.substring(c, c + 3) == "P_B") {
          tile = "P_B";
          c += 2; // Skip the next two characters
        } else if (c + 2 < currentFileRow.length &&
            currentFileRow.substring(c, c + 3) == "P_H") {
          tile = "P_H";
          c += 2; // Skip the next two characters
        } else if (c + 2 < currentFileRow.length &&
            currentFileRow.substring(c, c + 3) == "F_P") {
          tile = "F_P";
          c += 2; // Skip the next two characters
        } else {
          tile = currentFileRow[c];
        }

        // print("Processing tile: $tile");

        if (tile.trim().isEmpty) continue;

        double tileSize = loadTileSize(tile);
        Vector2 position = Vector2(c * tileSize, r * tileSize);

        if (tile == 'M') {
          marioPosition = position;
        } else {
          Component? component = _createComponent(tile, position);
          if (component != null) {
            worldComponents.add(component);
            if (['=', 'B', 'W', 'P_B', 'P_H'].contains(tile)) {
              // Add other solid block types here
              solidBlocks.add(
                  Rect.fromLTWH(position.x, position.y, tileSize, tileSize));
            }
          }
        }
      }
    }
    return (worldComponents, marioPosition, solidBlocks);
  }
}
