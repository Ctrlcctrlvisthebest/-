class Enemy extends Character {
  // Left and right facing enemy sprites.
  PImage enemyLeft;
  PImage enemyRight;
  // Tracks which way the enemy sprite should face.
  boolean enemyfacingRight;
  // 1 means move right, -1 means move left.
  int direction;
  // Horizontal patrol speed.
  float patrolSpeed;
  // Delay before the enemy actually flips direction.
  float turnAroundSpeed;
  // Timestamp for when the enemy started waiting to turn.
  float waitTurnAround;
  // True while the enemy is paused before flipping direction.
  boolean waitingToTurn;
  // Shooting cooldown values for magma projectiles.
  int shootCooldownFrames;
  int lastShotFrame;
  // Enemy health system.
  int maxHealth;
  int health;
  // Reference to the bone dropped when the enemy dies.
  Collectible droppedBone;
  // Number of coins granted by this enemy's bone drop.
  int boneValue;
  
  // Build the enemy and initialize patrol / health values.
  Enemy(float startX, float startY, int boneValue){
    super(startX,startY,"");
    enemyLeft = loadImage("wizardL.png");
    enemyRight = loadImage("wizardR.png");
    enemyfacingRight=true;
    direction = 1;
    patrolSpeed = 3;
    shootCooldownFrames = 100;
    turnAroundSpeed=3000/getEnemyCount()/getEnemyCount();
    waitTurnAround = 0;
    waitingToTurn = false;
    lastShotFrame = -shootCooldownFrames;
    maxHealth = 5;
    health = maxHealth;
    droppedBone = null;
    this.boneValue = boneValue;
  }
  
  @Override
  void setVelocity(){
    // Dead enemies should stop moving completely.
    if (!isAlive()) {
      xVelocity = 0;
      return;
    }
    // If we are already waiting to turn, stay still until the wait finishes.
    if (waitingToTurn) {
      xVelocity = 0;
      if (millis() - waitTurnAround >= turnAroundSpeed) {
        direction *= -1;
        waitingToTurn = false;
      }
      enemyfacingRight = direction > 0;
      return;
    }
    // Start the turn timer only once when a wall or ledge is detected.
    if (shouldTurnAround()) {
      waitTurnAround = millis();
      waitingToTurn = true;
      xVelocity = 0;
      enemyfacingRight = direction > 0;
      return;
    }
    // Move in the current patrol direction.
    xVelocity = patrolSpeed * direction;
    enemyfacingRight = direction > 0;
  }
  
  // Decide whether the enemy should reverse direction.
  boolean shouldTurnAround() {
    // Check just in front of the enemy body for a wall.
    float frontX = direction > 0 ? x + spriteWidth + 2 : x - 2;
    float topCheckY = y + 6;
    float midCheckY = y + spriteHeight - 6;
    boolean wallAhead = world.isSolidAt(frontX, topCheckY) || world.isSolidAt(frontX, midCheckY);
    if (wallAhead) {
      return true;
    }
    // If the enemy is on the ground, check whether there is floor ahead.
    if (onGround) {
      float groundCheckX = direction > 0 ? x + spriteWidth + 4 : x - 4;
      float groundCheckY = y + spriteHeight + 4;
      boolean hasGroundAhead = world.isSolidAt(groundCheckX, groundCheckY);
      if (!hasGroundAhead) {
        return true;
      }
    }
    return false;
  }
  
  // Shoot a magma projectile toward the player when the cooldown allows.
  void tryShootAt(Character target) {
    // Dead enemies do not shoot.
    if (!isAlive()) {
      return;
    }
    // Wait until enough frames have passed since the previous shot.
    if (frameCount - lastShotFrame < shootCooldownFrames) {
      return;
    }
    // Compare vertical centers so the enemy only shoots when the player is roughly level.
    float targetCenterY = target.y + target.spriteHeight / 2;
    float enemyCenterY = y + spriteHeight / 2;
    if (abs(targetCenterY - enemyCenterY) > 200) {
      return;
    }
    // Fire toward whichever side the player is on.
    int shotDirection = enemyfacingRight ? 1 : -1;
    // Spawn the magma shot just outside the enemy sprite.
    float spawnX = shotDirection > 0 ? x + spriteWidth : x - Projectile.PROJECTILE_SIZE;
    float spawnY = y + spriteHeight * 0.35;
    // Add the new projectile and update facing direction / cooldown.
    projectiles.add(new Projectile(spawnX, spawnY, shotDirection * 7));
    enemyfacingRight = shotDirection > 0;
    lastShotFrame = frameCount;
  }
  
  // Returns true while the enemy still has health left.
  boolean isAlive() {
    return health > 0;
  }
  
  // Reduce enemy health and drop a bone when health reaches zero.
  void takeDamage(int damage) {
    if (!isAlive()) {
      return;
    }
    health = max(0, health - damage);
    if (health == 0) {
      dropBone();
    }
  }
  
  // Restore the enemy to its full starting state for respawn / level reset.
  void resetState() {
    // Remove any old dropped bone so the player cannot farm extra points.
    if (droppedBone != null) {
      collectibles.remove(droppedBone);
      droppedBone = null;
    }
    health = maxHealth;
    xVelocity = 0;
    yVelocity = 0;
    direction = 1;
    enemyfacingRight = true;
    waitTurnAround = 0;
    waitingToTurn = false;
    lastShotFrame = -shootCooldownFrames;
  }
  
  // Spawn a collectible bone where the enemy died.
  void dropBone() {
    float boneSize = TILE_SIZE * 0.9;
    float boneX = x + (spriteWidth - boneSize) / 2;
    float boneY = y + spriteHeight - boneSize;
    droppedBone = new Collectible(boneX, boneY, boneImg, boneSize, "bone", boneValue);
    collectibles.add(droppedBone);
  }
  
  // Draw a health bar above the enemy sprite.
  void drawHealthBar() {
    if (!isAlive()) {
      return;
    }
    // Size and position of the health bar.
    float barWidth = spriteWidth;
    float barHeight = 8;
    float barX = x;
    float barY = y - 14;
    // Dark background bar.
    noStroke();
    fill(60);
    rect(barX, barY, barWidth, barHeight);
    // Green foreground showing current health percentage.
    fill(70, 220, 90);
    rect(barX, barY, barWidth * health / float(maxHealth), barHeight);
  }
  
  @Override
  void display(){
    // Dead enemies are no longer drawn.
    if (!isAlive()) {
      return;
    }
    // Pick the correct sprite based on the current facing direction.
    PImage enemycurrentSprite=enemyfacingRight?enemyRight:enemyLeft;
    // Small floating animation while the enemy is standing on ground.
    float floatOffset=0;
    if(onGround){
      floatOffset=sin(frameCount*0.1)*5;
    }
    // Draw the enemy sprite and then the health bar.
    imageMode(CORNER);
    image(enemycurrentSprite,x,y+floatOffset,spriteHeight,spriteHeight);
    drawHealthBar();
  }
}
