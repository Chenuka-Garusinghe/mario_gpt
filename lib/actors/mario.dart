import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class Mario extends SpriteAnimationComponent with KeyboardHandler {
  Mario({
    required Vector2 position,
  }) : super(
            size: Vector2.all(33),
            position: position,
            anchor: Anchor.bottomCenter);

  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 100;
  final double jumpSpeed = 350;
  final double gravity = 800;
  bool isOnGround = false;
  List<Rect> solidBlocks = [];

  late SpriteAnimation _runAnimation;
  late SpriteAnimation _idleAnimation;

  bool _isMovingLeft = false;
  bool _isMovingRight = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    Sprite idleSprite = await Sprite.load('mario_walk_1.png');
    _idleAnimation = SpriteAnimation.spriteList([idleSprite], stepTime: 1);

    // Load run animation sprites
    List<Sprite> runFrames = [
      await Sprite.load('mario_walk_1.png'),
      await Sprite.load('mario_walk_2.png'),
      await Sprite.load('mario_walk_3.png'),
    ];
    _runAnimation = SpriteAnimation.spriteList(runFrames, stepTime: 0.12);

    // Set initial animation to idle
    animation = _idleAnimation;
  }

  void setSolidBlocks(List<Rect> blocks) {
    solidBlocks = blocks;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _isMovingLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    _isMovingRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      jump();
    }

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply horizontal movement
    if (_isMovingLeft && !_isMovingRight) {
      velocity.x = -moveSpeed;
      if (scale.x > 0) flipHorizontally();
      animation = _runAnimation;
    } else if (_isMovingRight && !_isMovingLeft) {
      velocity.x = moveSpeed;
      if (scale.x < 0) flipHorizontally();
      animation = _runAnimation;
    } else {
      velocity.x = 0;
      animation = _idleAnimation;
    }

    // Apply gravity
    velocity.y += gravity * dt;

    // Move Mario
    position += velocity * dt;

    // Handle collisions
    handleCollisions();

    print(
        "Position: $position, Velocity: $velocity, OnGround: $isOnGround, MovingLeft: $_isMovingLeft, MovingRight: $_isMovingRight");
  }

  void handleCollisions() {
    final marioRect = toRect();
    isOnGround = false;

    for (final block in solidBlocks) {
      if (marioRect.overlaps(block)) {
        final double overlapX = (marioRect.right - block.left).abs() <
                (marioRect.left - block.right).abs()
            ? marioRect.right - block.left
            : marioRect.left - block.right;
        final double overlapY = (marioRect.bottom - block.top).abs() <
                (marioRect.top - block.bottom).abs()
            ? marioRect.bottom - block.top
            : marioRect.top - block.bottom;

        if (overlapX.abs() < overlapY.abs()) {
          // Horizontal collision
          if (overlapX > 0) {
            // Colliding from the left
            position.x = block.left - size.x / 2;
          } else {
            // Colliding from the right
            position.x = block.right + size.x / 2;
          }
          velocity.x = 0;
        } else {
          // Vertical collision
          if (overlapY > 0) {
            // Colliding from the top
            position.y = block.top;
            velocity.y = 0;
            isOnGround = true;
          } else {
            // Colliding from the bottom
            position.y = block.bottom + size.y;
            velocity.y = 0;
          }
        }
      }
    }
  }

  void jump() {
    if (isOnGround) {
      velocity.y = -jumpSpeed;
      isOnGround = false;
    }
  }
}
