class WaterProjectile {
  // Fixed size for player water projectiles.
  static final float PROJECTILE_SIZE = 20;
  
  // Position and horizontal speed.
  float x;
  float y;
  float xVelocity;
  
  // Create a water projectile.
  WaterProjectile(float x, float y, float xVelocity) {
    this.x = x;
    this.y = y;
    this.xVelocity = xVelocity;
  }
  
  // Move the projectile horizontally.
  void update() {
    x += xVelocity;
  }
  
  // Draw the water image at the current position.
  void display() {
    image(waterProjectileImg, x, y, PROJECTILE_SIZE, PROJECTILE_SIZE);
  }
  
  // Check whether the water projectile hits a wall.
  boolean hitsWall() {
    float checkX = xVelocity > 0 ? x + PROJECTILE_SIZE : x;
    float checkY = y + PROJECTILE_SIZE / 2;
    return world.isSolidAt(checkX, checkY);
  }
  
  // Check whether the water projectile leaves the world.
  boolean isOffWorld() {
    return x + PROJECTILE_SIZE < 0 || x > worldWidth || y + PROJECTILE_SIZE < 0 || y > worldHeight;
  }
  
  // Rectangle collision between a water shot and a magma shot.
  boolean collidesWith(Projectile magma) {
    float waterRight = x + PROJECTILE_SIZE;
    float waterBottom = y + PROJECTILE_SIZE;
    float magmaRight = magma.x + Projectile.PROJECTILE_SIZE;
    float magmaBottom = magma.y + Projectile.PROJECTILE_SIZE;
    return waterRight > magma.x && x < magmaRight && waterBottom > magma.y && y < magmaBottom;
  }
  
  // Rectangle collision between a water shot and a character.
  boolean collidesWith(Character target) {
    float waterRight = x + PROJECTILE_SIZE;
    float waterBottom = y + PROJECTILE_SIZE;
    float targetRight = target.x + target.spriteWidth;
    float targetBottom = target.y + target.spriteHeight;
    return waterRight > target.x && x < targetRight && waterBottom > target.y && y < targetBottom;
  }
}
