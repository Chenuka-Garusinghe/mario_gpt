// define the general enemy class and its properties
class Enemies {
  // properties
  String name;
  int health;
  int damage;
  // constructor
  Enemies({
    required this.name,
    required this.health,
    required this.damage,
  });

  // methods

  void animateMovements() {
    print('Enemy $name is moving');
  }

  void attack() {
    print('Enemy $name attacks you for $damage damage');
  }

  void takeDamage(int damage) {
    health -= damage;
    print('Enemy $name takes $damage damage');
  }

  void die() {
    print('Enemy $name dies');
  }
}
