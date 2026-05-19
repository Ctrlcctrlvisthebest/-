class Mage extends Character {
  // Left and right facing player sprites.
  PImage spriteLeft;
  PImage spriteRight;
  PImage spriteSprintL;
  PImage spriteSprintR;
  // True when the player should face right.
  boolean facingRight;
  // Delay between water shots so the player cannot spam instantly.
  int shootCooldownFrames;
  int lastShotFrame;
  // Sprint timing values.
  int sprintCooldownFrames;
  int sprintDurationFrames;
  int lastSprintFrame;
  int sprintStartFrame;
  // Horizontal speed used during sprint.
  float sprintSpeed;
  // Create the player and load both facing directions.
  Mage(float startX, float startY){
    super(startX,startY,"");
    spriteLeft = loadImage("mageL.png");
    spriteRight = loadImage("mageR.png");
    spriteSprintL=loadImage("mageSprintL.png");
    spriteSprintR=loadImage("mageSprintR.png");
    facingRight=true;
    shootCooldownFrames = 18;
    sprintCooldownFrames=90;
    sprintDurationFrames=10;
    lastSprintFrame = -sprintCooldownFrames;
    sprintStartFrame = -sprintDurationFrames;
    sprintSpeed = 16;
    lastShotFrame = -shootCooldownFrames;
  }

  @Override
  void setVelocity(){
    // While sprinting, force horizontal movement in the facing direction.
    if (isSprinting()) {
      xVelocity = facingRight ? sprintSpeed : -sprintSpeed;
      return;
    }
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
    PImage currentSprite;
    if (isSprinting()) {
      if(facingRight){
        currentSprite = spriteSprintR;
      }else{
        currentSprite = spriteSprintL;
      }
    } else {
      currentSprite=facingRight?spriteRight:spriteLeft;
    }
    // Slight bounce animation while standing on the ground.
    float floatOffset=0;
    if(onGround && !isSprinting()){
      floatOffset=sin(frameCount*0.1)*5;
    }
    imageMode(CORNER);
    image(currentSprite,x,y+floatOffset,spriteHeight,spriteHeight);
  }
  
  // Returns true during the active sprint window.
  boolean isSprinting() {
    return frameCount - sprintStartFrame < sprintDurationFrames;
  }
  
  // Start a sprint if the cooldown has finished.
  void triggerSprint() {
    if (isSprinting()) {
      return;
    }
    if (frameCount - lastSprintFrame < sprintCooldownFrames) {
      return;
    }
    sprintStartFrame = frameCount;
    lastSprintFrame = frameCount;
    // Preserve the current facing direction; if the player is holding a direction,
    // update facing before the sprint begins.
    if (leftPressed) {
      facingRight = false;
    } else if (rightPressed) {
      facingRight = true;
    }
  }
  
  // Clear any active sprint when the player or level resets.
  void resetSprintState() {
    sprintStartFrame = -sprintDurationFrames;
    lastSprintFrame = -sprintCooldownFrames;
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
  float getShotCooldownPercent() {
    return constrain((frameCount - lastShotFrame) / float(shootCooldownFrames), 0, 1);
  }
  
  // Return how full the sprint cooldown is from 0.0 to 1.0.
  float getSprintCooldownPercent() {
    return constrain((frameCount - lastSprintFrame) / float(sprintCooldownFrames), 0, 1);
  }
  void drawCooldownTime(){
    float shotPercent = getShotCooldownPercent();
    float sprintPercent = getSprintCooldownPercent();
    float shotX = width - 110;
    float sprintX = width - 50;
    float iconY = height - 50;
    float size = 42;
    float startAngle = -HALF_PI;
    
    textAlign(CENTER, CENTER);
    strokeWeight(3);
    
    // Water-shot cooldown circle.
    stroke(210);
    fill(235);
    ellipse(shotX, iconY, size, size);
    stroke(40, 120, 255);
    noFill();
    arc(shotX, iconY, size, size, startAngle, startAngle + TWO_PI * shotPercent);
    fill(20, 80, 180);
    textSize(12);
    text("X", shotX, iconY);
    fill(0);
    textSize(10);
    text("shot", shotX, iconY + 32);
    
    // Sprint cooldown circle.
    stroke(210);
    fill(235);
    ellipse(sprintX, iconY, size, size);
    stroke(255, 150, 40);
    noFill();
    arc(sprintX, iconY, size, size, startAngle, startAngle + TWO_PI * sprintPercent);
    fill(180, 90, 20);
    textSize(12);
    text("Z", sprintX, iconY);
    fill(0);
    textSize(10);
    text("sprint", sprintX, iconY + 32);
    
    noStroke();
    textAlign(LEFT, BASELINE);
  }
}
