class Projectile {
  // Fixed size for enemy magma projectiles.
  static final float PROJECTILE_SIZE = 24;
  
  // Position and horizontal speed.
  float x;
  float y;
  float xVelocity;
  
  // Create a magma projectile.
  Projectile(float x, float y, float xVelocity) {
    this.x = x;
    this.y = y;
    this.xVelocity = xVelocity;
  }
  
  // Move the projectile horizontally.
  void update() {
    x += xVelocity;
  }
  
  // Draw the magma image at the current position.
  void display() {
    image(magmaProjectileImg, x, y, PROJECTILE_SIZE, PROJECTILE_SIZE);
  }
  
  // Check whether the projectile hit a solid wall tile.
  boolean hitsWall() {
    float checkX = xVelocity > 0 ? x + PROJECTILE_SIZE : x;
    float checkY = y + PROJECTILE_SIZE / 2;
    return world.isSolidAt(checkX, checkY);
  }
  
  // Check whether the projectile has left the world boundaries.
  boolean isOffWorld() {
    return x + PROJECTILE_SIZE < 0 || x > worldWidth || y + PROJECTILE_SIZE < 0 || y > worldHeight;
  }
  
  // Rectangle collision check between a magma projectile and a character.
  boolean collidesWith(Character c) {
    float charLeft = c.x;
    float charRight = c.x + c.spriteWidth;
    float charTop = c.y;
    float charBottom = c.y + c.spriteHeight;
    float projectileRight = x + PROJECTILE_SIZE;
    float projectileBottom = y + PROJECTILE_SIZE;
    return projectileRight > charLeft && x < charRight && projectileBottom > charTop && y < charBottom;
  }
}
