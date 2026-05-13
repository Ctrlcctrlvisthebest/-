class Mage extends Character {
  // Left and right facing player sprites.
  PImage spriteLeft;
  PImage spriteRight;
  // True when the player should face right.
  boolean facingRight;
  // Delay between water shots so the player cannot spam instantly.
  int shootCooldownFrames;
  int lastShotFrame;

  // Create the player and load both facing directions.
  Mage(float startX, float startY){
    super(startX,startY,"");
    spriteLeft = loadImage("mageL.png");
    spriteRight = loadImage("mageR.png");
    facingRight=true;
    shootCooldownFrames = 18;
    lastShotFrame = -shootCooldownFrames;
  }

  @Override
  void setVelocity(){
    // Reset horizontal speed each frame before reading key input.
    xVelocity=0;
    // Move left and update the facing direction.
    if(leftPressed){
      xVelocity-=7;
      facingRight=false;
    }
    // Move right and update the facing direction.
    if(rightPressed){
      xVelocity+=7;
      facingRight=true;
    }
    // Jump when the jump key is held.
    if(jumpPressed){
      jump();
    }
  }

  @Override
  void display(){
    // Choose the correct sprite based on the last horizontal direction.
    PImage currentSprite=facingRight?spriteRight:spriteLeft;
    // Slight bounce animation while standing on the ground.
    float floatOffset=0;
    if(onGround){
      floatOffset=sin(frameCount*0.1)*5;
    }
    imageMode(CORNER);
    image(currentSprite,x,y+floatOffset,spriteHeight,spriteHeight);
  }
  
  // Fire a water projectile in the direction the player is facing.
  void shootWater() {
    // Respect the cooldown timer between shots.
    if (frameCount - lastShotFrame < shootCooldownFrames) {
      return;
    }
    // Fire right if facing right, otherwise fire left.
    int shotDirection = facingRight ? 1 : -1;
    // Spawn the projectile just outside the player sprite.
    float spawnX = shotDirection > 0 ? x + spriteWidth : x - WaterProjectile.PROJECTILE_SIZE;
    // Spawn the projectile around the player's hand / middle height.
    float spawnY = y + spriteHeight * 0.4;
    // Add the new projectile to the active water projectile list.
    waterProjectiles.add(new WaterProjectile(spawnX, spawnY, shotDirection * 10));
    // Save the frame number so cooldown works.
    lastShotFrame = frameCount;
  }
}
