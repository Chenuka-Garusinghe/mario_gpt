import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flame/game.dart';

Future<List<String>> findAssets({String directory = 'assets/images/'}) async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  return manifestMap.keys
      .where((String key) =>
          key.startsWith(directory) &&
          !path.basename(key).startsWith('.') && // Ignore hidden files
          isImageFile(key)) // Only include image files
      .map((String key) => path.basename(key)) // Get just the filename
      .toList();
}

bool isImageFile(String filePath) {
  final validExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'];
  return validExtensions.contains(path.extension(filePath).toLowerCase());
}

Vector2 getImageDimensions(String imagePath) {
  try {
    Image image = Flame.images.fromCache(imagePath);
    int width = image.width;
    int height = image.height;
    // print('Image dimensions for $imagePath: $width x $height');
    return Vector2(width.toDouble(), height.toDouble());
  } catch (e) {
    print('Error accessing cached image $imagePath: $e');
    return Vector2.zero();
  }
}
