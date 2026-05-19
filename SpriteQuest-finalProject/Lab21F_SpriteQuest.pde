// Import the Processing sound library so the game can play effects.
import processing.sound.*;

// Different screens / phases the game can be in.
enum GameState {
  START, LOADING, PLAYING, VICTORY, LOSE
}

// Difficulty options for the run.
enum Difficulty {
  EASY, NORMAL, HARD
}

// Start the sketch on the intro screen.
GameState state = GameState.START;
// Currently selected difficulty.
Difficulty selectedDifficulty = Difficulty.NORMAL;
// Background color used for non-scrolling screens.
color currentBG;

// Timing values for the short level-loading screen.
int timerStart = 0;
int waitTime = 1000; 
// Main world object that stores map tiles and enemy spawn.
World world;
// The player character.
Mage mage;
// Active enemies in the current level.
ArrayList<Enemy> enemies;
// Sound effects.
SoundFile coin_sound;
SoundFile jump_sound;
// Images used by projectile / drop systems.
PImage magmaProjectileImg;
PImage waterProjectileImg;
PImage boneImg;
// Lists for coins, gems, magma hazards, bone drops, enemy shots, and player shots.
ArrayList<Collectible> collectibles;
ArrayList<Projectile> projectiles;
ArrayList<WaterProjectile> waterProjectiles;
// Input booleans that remember whether movement keys are held down.
boolean leftPressed;
boolean rightPressed;
boolean jumpPressed;
// When true, the player should be reset to the spawn point.
boolean resetmage;
boolean resetGame;
// Standard size for one map tile.
final int TILE_SIZE = 50;
// Number of rows and columns in the current map file.
int rows, cols;
// Raw lines loaded from the CSV map file.
String[] csvLines;
// Common sprite dimensions for characters.
final float SPRITE_WIDTH = 50;
final float SPRITE_HEIGHT = 50;
// Nearby solid tiles around the player, used for collision checks.
ArrayList<Platform> nearby;
// Current coin total.
int coinScore;
// Camera position inside the world.
float viewX=0,viewY=0; 
// Total pixel size of the current world.
float worldWidth,worldHeight;
// Current level number and total number of levels.
int map=1;
final int MAP=4;
// Size of the loading progress bar.
final int BAR_WIDTH = 600;
final int BAR_HEIGHT = 20;

// Set the sketch window size before setup() runs.
void settings() {
  size(1500,800);
  pixelDensity(1);
}

// Load all data and create the initial game objects.
void setup() {
  // Draw images using their top-left corner.
  imageMode(CORNER);
  // Create empty lists before anything tries to add into them.
  collectibles=new ArrayList<Collectible>();
  projectiles=new ArrayList<Projectile>();
  waterProjectiles=new ArrayList<WaterProjectile>();
  enemies=new ArrayList<Enemy>();
  // Create the player, then load level 1.
  mage=new Mage(250,400);
  loadLevel(map);
  // Save the world dimensions for camera / projectile boundaries.
  worldWidth=cols*TILE_SIZE;
  worldHeight=rows*TILE_SIZE;
  // Load images used outside the tile system.
  magmaProjectileImg = loadImage("magma.png");
  waterProjectileImg = loadImage("water.png");
  boneImg = loadImage("bone.png");
  // Load sound effects.
  coin_sound=new SoundFile(this,"coin-sound.mp3");
  jump_sound=new SoundFile(this,"jump-sound.mp3");
}

// Processing automatically calls draw() every frame.
void draw() {
  // Clear the screen with the current background color.
  background(currentBG);

  // Run different logic depending on the current screen / game phase.
  switch (state) {
    case START:
      // Show the intro screen.
      drawIntroScreen();
      // Reset the loading timer while we are waiting on the start screen.
      timerStart = millis();  
      break;
      
    case LOADING:
      // Show a short transition screen between levels.
      drawLevelScreen();

      // After enough time has passed, begin gameplay.
      if (millis() - timerStart > waitTime) { 
        state = GameState.PLAYING;
      }
      break;
      
    case PLAYING:
        // Save the current coordinate system before applying camera movement.
        pushMatrix();
        // Move the world opposite the camera to create scrolling.
        translate(-viewX, -viewY);
        // Draw the gameplay sky.
        background(100, 200, 255);
        // Draw every solid tile in the world.
        resetGame();
        world.drawTiles();
        // Get only the tiles near the player for efficient collision.
        nearby = world.getNearByTiles(mage);
        // Debug draw nearby collision boxes.
        drawNearbyTiles();
        // Update player velocity from input.
        mage.setVelocity();
        // Move the player left / right and resolve wall collisions.
        mage.handleHorizontalMovement(nearby);
        // Apply gravity and vertical collision.
        mage.applyGravity(nearby);
        // Update each alive enemy in the level.
        for (Enemy enemy : enemies) {
          if (enemy != null && enemy.isAlive()) {
            // Get tiles near the enemy for enemy collision.
            ArrayList<Platform> enemyNearby = world.getNearByTiles(enemy);
            // Run the enemy patrol AI and collisions.
            enemy.setVelocity();
            enemy.handleHorizontalMovement(enemyNearby);
            enemy.applyGravity(enemyNearby);
            // Let the enemy attempt to fire toward the player.
            enemy.tryShootAt(mage);
          }
        }
        // Move enemy magma shots.
        updateProjectiles();
        // Move player water shots.
        updateWaterProjectiles();
        // Resolve water hitting magma or enemy.
        resolveProjectileHits();
        // Draw the player and enemy.
        mage.display();
        for (Enemy enemy : enemies) {
          if (enemy != null) {
            enemy.display();
          }
        }
        // Check if the player has collected coins / gems / bones / hazards.
        checkCollectibleCollisions(mage);
        // Draw collectible objects after updating them.
        drawCollectibles();
        // Reset the player if a hazard / projectile requested it.
        if(resetmage)resetMage();
        // Move the camera toward the player.
        updateCamera();
        // Restore the screen coordinate system so HUD text stays fixed.
        popMatrix();
        // Draw HUD information in screen space.
        drawScore();
        break;
      
    case VICTORY:
      // Show the win screen.
      drawVictoryScreen();
      break;

    case LOSE:
      // Show the lose screen.
      drawLoseScreen();
      break;
      
  }
}

// Draw the score and rank HUD in the top-left corner.
void drawScore(){
  fill(0);
  textSize(24);
  text("Score:"+coinScore,20,30);
  text("Rank:"+getRank(),20,60);
  text("Difficulty:"+getDifficultyName(),20,90);
  mage.drawCooldownTime();
}

// Convert the current coin total into a letter rank.
String getRank(){
  if(coinScore >= 80){
    return "S";
  }else if(coinScore >= 65){
    return "A";
  }else if(coinScore >= 40){
    return "B";
  }else if(coinScore >= 20){
    return "C";
  }else{
    return "D";
  }
}

String getDifficultyName(){
  switch(selectedDifficulty){
    case EASY:
      return "Easy";
    case NORMAL:
      return "Normal";
    case HARD:
      return "Hard";
    default:
      return "Normal";
  }
}

int getEnemyCount(){
  switch(selectedDifficulty){
    case EASY:
      return 1;
    case NORMAL:
      return 2;
    case HARD:
      return 3;
    default:
      return 1;
  }
}

int getBoneValue(){
  switch(selectedDifficulty){
    case HARD:
      return 10;
    case NORMAL:
      return 7;
    case EASY:
    default:
      return 5;
  }
}

// Debug helper: draw boxes around nearby collision tiles.
void drawNearbyTiles(){
  rectMode(CORNER);
  for (Platform p : nearby) {
    // Draw a thick black outline for each nearby tile.
    stroke(0);
    strokeWeight(4);
    noFill();
    rect(p.x,p.y,p.size,p.size);
  }
}

// Keep the camera centered on the player without leaving the world bounds.
void updateCamera() {
  // Target camera x so the player appears near the center of the screen.
  float targetViewX =mage.x-width/2;
  // Target camera y so the player appears near the center vertically too.
  float targetViewY =mage.y-height/2;
  // Keep the camera inside the world so we never show empty space outside.
  targetViewX = constrain(targetViewX,0,worldWidth-width);
  targetViewY = constrain(targetViewY,0,worldHeight-height);
  // Camera catch-up speed for smooth movement instead of snapping instantly.
  float cameraSpeed = 0.2;
  // Horizontal and vertical distance from current camera to target camera.
  float delta = targetViewX-viewX;
  float deltaY = targetViewY-viewY;
  // Move a fraction of the distance each frame for smooth following.
  viewX += cameraSpeed*delta;
  viewY += cameraSpeed*deltaY;
}

// Draw every collectible currently active in the level.
void drawCollectibles() {
  for(Collectible c:collectibles){
    c.display();
  }
}

// Update enemy magma projectiles, draw them, and hurt the player on contact.
void updateProjectiles() {
  // Loop backwards so removing projectiles is safe.
  for (int i = projectiles.size() - 1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    // Move the projectile horizontally.
    p.update();
    // Remove the projectile if it hits a wall or leaves the map.
    if (p.hitsWall() || p.isOffWorld()) {
      projectiles.remove(i);
      continue;
    }
    // Draw the projectile after its position is updated.
    p.display();
    // Sprinting lets the player ignore magma projectiles completely.
    if (mage.isSprinting()) {
      continue;
    }
    // If the projectile hits the player, remove it and apply damage.
    if (p.collidesWith(mage)) {
      projectiles.remove(i);
      coinScore -= 10;
      // If the player's score goes below zero, they lose.
      if (coinScore < 0) {
        state = GameState.LOSE;
      }
      // Otherwise reset the player to the spawn position.
      resetmage = true;
    }
  }
}

// Update and draw the player's water projectiles.
void updateWaterProjectiles() {
  for (int i = waterProjectiles.size() - 1; i >= 0; i--) {
    WaterProjectile p = waterProjectiles.get(i);
    p.update();
    if (p.hitsWall() || p.isOffWorld()) {
      waterProjectiles.remove(i);
      continue;
    }
    p.display();
  }
}

// Handle water projectiles hitting the enemy or cancelling magma projectiles.
void resolveProjectileHits() {
  for (int i = waterProjectiles.size() - 1; i >= 0; i--) {
    WaterProjectile water = waterProjectiles.get(i);
    // Track whether this water shot already hit something.
    boolean hit = false;
    // Water damages the first alive enemy it touches.
    for (Enemy enemy : enemies) {
      if (enemy != null && enemy.isAlive() && water.collidesWith(enemy)) {
        enemy.takeDamage(1);
        waterProjectiles.remove(i);
        hit = true;
        break;
      }
    }
    if (hit) {
      continue;
    }
    // Otherwise check whether the water shot destroys an enemy magma shot.
    for (int j = projectiles.size() - 1; j >= 0; j--) {
      Projectile magma = projectiles.get(j);
      if (water.collidesWith(magma)) {
        waterProjectiles.remove(i);
        projectiles.remove(j);
        hit = true;
        break;
      }
    }
    if (hit) {
      continue;
    }
  }
}

// Fire a water projectile only during actual gameplay.
void fireWaterProjectile() {
  if (state != GameState.PLAYING || mage == null) {
    return;
  }
  mage.shootWater();
}
 
// Check what happens when the player touches each collectible / hazard.
void checkCollectibleCollisions(Character ch) {
  // Loop backwards so we can safely remove collected items.
  for(int i=collectibles.size()-1;i>=0;i--){
    Collectible c=collectibles.get(i);
    // Only react if the player overlaps the item.
    if(c.collidesWith(ch)){
      // Coins give 1 point.
      if(c.type.equals("coin")){
        collectibles.remove(i);
        coinScore++;
        coin_sound.play();
      // Bones dropped by enemies give their stored score value.
      }else if(c.type.equals("bone")){
        collectibles.remove(i);
        coinScore += c.scoreValue;
        coin_sound.play();
      // Gems move the player to the next level.
      }else if(c.type.equals("gem")){
        collectibles.remove(i);
        map++;
        // If there are no more levels, the player wins.
        if(map>MAP){
          state=GameState.VICTORY;
          break;
        }
        // Otherwise start the loading screen and load the next map.
        timerStart = millis();
        state = GameState.LOADING;
        loadLevel(map);
        break;
      }else{
        // Any other collectible type here is treated as a hazard.
        coinScore-=10;
        if(coinScore<0)state = GameState.LOSE;
        resetmage=true;
      }
    }
  }
}

// Draw the title / instructions screen.
void drawIntroScreen() {
  fill(255);
  textSize(70);
  text("SPRITR QUEST",500,300);
  fill(125);
  textSize(30);
  text("Arrow to Move, X shoot water, space restart, z sprint, r reselect",430,380);
  text("Press 1 for Easy, 2 for Normal, 3 for Hard",420,430);
  text("Selected Difficulty: " + getDifficultyName(),480,480);
  fill(255);
  textSize(50);
  text("Press [SPACEBAR] to play",500,560);
  // Reuse the reset key to leave the intro screen.
  if(resetmage){
    map = 1;
    coinScore = 0;
    timerStart = millis();
    state = GameState.LOADING;
    loadLevel(map);
    resetmage = false;
  }
}


// Draw the short level loading screen and animated progress bar.
void drawLevelScreen() {
  // Time that has passed since loading started.
  float elapsed = millis()-timerStart;

  // Convert elapsed time into a percentage from 0 to 1.
  float percent = elapsed/waitTime;
  
  // Clamp the percentage so it never goes below 0 or above 1.
  percent = constrain(percent,0,1);
  
  // Convert the percentage into the width of the inner bar.
  float progressBarWidth = percent*BAR_WIDTH;

  // Draw the empty outline of the loading bar.
  noFill();
  rect(200,500,BAR_WIDTH,BAR_HEIGHT);
  // Fill the inner bar based on the loading percentage.
  fill(255);
  textSize(40);
  text("Level"+map,650,300);
  rect(500,400,progressBarWidth,BAR_HEIGHT);
  // Show the percentage as text too.
  fill(255);
  textSize(40);
  text(int(percent*100)+"%",700,500);

}


// Draw the victory screen and allow the player to restart the full game.
void drawVictoryScreen() {
  fill(255);
  textSize(70);
  text("You win!",600,300);
  fill(125);
  textSize(30);
  text("You earn "+coinScore+" coin",550,400);
  text("Choose difficulty: 1 Easy, 2 Normal, 3 Hard",420,460);
  text("Selected Difficulty: " + getDifficultyName(),500,500);
  fill(255);
  textSize(50);
  text("Press [SPACEBAR]",500,570);
  // Restart the game from level 1 when the reset key is pressed.
  if(resetmage){
    coinScore=0;
    map=1;
    timerStart = millis(); 
    state = GameState.LOADING; 
    loadLevel(map);
  }
}

// Draw the lose screen and allow the player to restart the full game.
void drawLoseScreen() {
  fill(255);
  textSize(70);
  text("You Lose!",600,300);
  fill(125);
  textSize(30);
  text("You lost all coin",550,400);
  text("Choose difficulty: 1 Easy, 2 Normal, 3 Hard",420,460);
  text("Selected Difficulty: " + getDifficultyName(),500,500);
  fill(255);
  textSize(50);
  text("Press [SPACEBAR] play again",450,570);
  // Restart from the beginning when the reset key is pressed.
  if(resetmage){
    coinScore=0;
    map=1;
    timerStart = millis(); 
    state = GameState.LOADING; 
    loadLevel(map);
  }
}

// Load a new level from its CSV file and reset level-specific objects.
void loadLevel(int Map){
  // Remove old collectibles and projectiles from the previous level.
  collectibles.clear();
  projectiles.clear();
  waterProjectiles.clear();
  enemies.clear();
  // Read the matching CSV file.
  csvLines = loadStrings("map"+Map+".csv");
  // Recalculate map dimensions from the file.
  rows = csvLines.length;
  cols = split(csvLines[0], ",").length;
  // Convert row / column counts into pixel dimensions.
  worldWidth=cols*TILE_SIZE;
  worldHeight=rows*TILE_SIZE;
  // Build the world and create new enemies for this map.
  world = new World(csvLines);
  enemies = createEnemiesForMap();
  // Reset the camera to the top-left.
  viewX=0;
  viewY=0;
  // Reset the player after the level is loaded.
  resetMage();
}

// Put the player back at the level start and clear active projectiles.
void resetMage(){
  mage.x=250;
  mage.y=400;
  mage.xVelocity=0;
  mage.yVelocity=0;
  mage.resetSprintState();
  projectiles.clear();
  waterProjectiles.clear();
  switch(selectedDifficulty){
    case EASY:
      break;
    case NORMAL:
    case HARD:
    default:
      resetEnemies();
      break;
  }
  resetmage=false;
}

// Create all enemies for the current level based on difficulty.
ArrayList<Enemy> createEnemiesForMap(){
  ArrayList<Enemy> newEnemies = new ArrayList<Enemy>();
  float spawnX = world.getEnemySpawnX();
  float[] offsets = {0, 250, -250, 500, -500};
  int enemyCount = min(getEnemyCount(), offsets.length);
  for (int i = 0; i < enemyCount; i++) {
    float enemyX = constrain(spawnX + offsets[i], 0, max(0, worldWidth - SPRITE_WIDTH));
    float enemyY = world.findGroundY(enemyX);
    newEnemies.add(new Enemy(enemyX, enemyY, getBoneValue()));
  }
  return newEnemies;
}
void resetGame(){
  if(resetGame){
    state = GameState.START;
    resetGame=false;
  }
}
// Reset all enemies to their spawn positions and full state.
void resetEnemies(){
  float spawnX = world.getEnemySpawnX();
  float[] offsets = {0, 250, -250, 500, -500};
  for (int i = 0; i < enemies.size(); i++) {
    Enemy enemy = enemies.get(i);
    float enemyX = constrain(spawnX + offsets[i], 0, max(0, worldWidth - SPRITE_WIDTH));
    float enemyY = world.findGroundY(enemyX);
    enemy.x = enemyX;
    enemy.y = enemyY;
    enemy.resetState();
  }
}
