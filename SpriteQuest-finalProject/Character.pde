abstract class Character {
    // protected means subclasses like Mage and Enemy can directly use these fields.
    // Position of the character's top-left corner.
    protected float x;
    protected float y;
    // Current movement speeds.
    protected float xVelocity;
    protected float yVelocity;
    // Downward acceleration applied every frame.
    protected float gravity;
    // True when the character is standing on solid ground.
    protected boolean onGround;
    // Optional sprite image reference.
    protected PImage sprite;
    // Standard width and height for all characters.
    final float spriteWidth = 50;
    final float spriteHeight = 50;

    // Base constructor shared by Mage and Enemy.
    Character(float startX, float startY, String imgFile){
      // Set the initial position.
      x=startX;
      y=startY;
      // Start with no movement.
      xVelocity=0;
      yVelocity=0;
      // Gravity strength used for jumping / falling.
      gravity=0.5;
      onGround=false;
      // Load a sprite only if a filename was actually provided.
      if(imgFile!=null&&!imgFile.equals("")){
        sprite=loadImage(imgFile);
      }else{
        sprite=null;
      }
    }

    // Apply gravity and resolve vertical collisions with nearby tiles.
    void applyGravity(ArrayList<Platform> nearby){
      // Assume we are in the air until collision proves otherwise.
      onGround=false;
      // Gravity increases downward speed every frame.
      yVelocity+=gravity;
      // Predict the next vertical position.
      float nextY=y+yVelocity;
      for (Platform p : nearby) {
        // Horizontal overlap is required for any top/bottom collision.
        boolean overlapX =x+spriteWidth>p.x&&x<p.x+p.size;
        // Falling downward onto the top of a platform.
        if(yVelocity>0&&overlapX){
          // The character was above the platform last frame.
          boolean wasAbove=y+spriteHeight<=p.y;
          // The next position would pass through the top of the platform.
          boolean willPass=nextY+spriteHeight>=p.y;
          // Snap the character to the platform and stop the fall.
          if(wasAbove&&willPass){
            nextY=p.y-spriteHeight;
            yVelocity=0;
            onGround=true;
          }
        }
        // Moving upward into the bottom of a platform.
        if(yVelocity<0&&overlapX){
          boolean wasBelow=y>=p.y+p.size;
          boolean willPass=nextY<=p.y+p.size;
          // Snap just below the tile and stop upward movement.
          if(wasBelow&&willPass){
            nextY=p.y+p.size;
            yVelocity=0;
          }
        }
      }
      // Apply the corrected vertical position.
      y=nextY;
      // Keep the character inside the bottom of the world.
      float worldBottom = rows * TILE_SIZE - spriteHeight;
      if(y>worldBottom){
        y=worldBottom;
        yVelocity=0;
        onGround=true;
      }
      // Also prevent moving above the top edge of the world.
      if(y<0){
        y=0;
        if(yVelocity<0){
          yVelocity=0;
        }
      }
    }

    // Start a jump only if the character is standing on the ground.
    void jump(){
      if(onGround){
        yVelocity=-13;  
        jump_sound.play();
      }
    }

    // Old helper that wraps around the screen edges (not currently used).
    void wrapAround(){
      if(x<0){
        x=width;
      }else if(x>width){
        x=0;
      }
    }

    // Move the character horizontally and stop when hitting a solid tile.
    void handleHorizontalMovement(ArrayList<Platform> nearby) {
      // Keep the character inside the world before movement.
      x=constrain(x,0,cols * TILE_SIZE);
      // Move horizontally based on the current velocity.
      x += xVelocity;
      // Test against nearby platforms only.
      for (Platform p : nearby) {
        // Rectangle overlap test between the character and tile.
        boolean overlap =
        x <p.x+p.size&&
        x +spriteWidth> p.x &&
        y <p.y+p.size&&
        y +spriteHeight> p.y;
        if (overlap) {
          // If moving right, snap the character to the left of the tile.
          if (xVelocity > 0) {
            x =p.x-spriteWidth;
          }
          // If moving left, snap the character to the right of the tile.
          else if (xVelocity < 0) {
            x =p.x+p.size;
          }
          // Stop horizontal motion after collision.
          xVelocity=0; 
        }
      }
      // Final safety clamp to keep the character inside world bounds.
      x=min(x,cols*TILE_SIZE-SPRITE_WIDTH);
      x=max(x,0);
    }
    // Each subclass must define how it draws itself.
    abstract void display();
    // Each subclass must define how it chooses movement velocity.
    abstract void setVelocity();
}
