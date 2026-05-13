class Collectible {
  // Top-left position of the collectible.
  float x, y;
  // Image used to draw the collectible.
  PImage img;
  // Width and height of the collectible.
  float size;
  // Type string used to decide what happens on pickup.
  String type; 
  // How many coins this collectible is worth when collected.
  int scoreValue;

  // Create one collectible item.
  Collectible(float x, float y, PImage img, float size, String type) {
    this(x, y, img, size, type, 0);
  }
  
  // Create one collectible item with a custom score value.
  Collectible(float x, float y, PImage img, float size, String type, int scoreValue) {
    this.x=x;
    this.y=y;
    this.img=img;
    this.size=size;
    this.type=type;
    this.scoreValue=scoreValue;
  }

  // Draw the collectible image.
  void display() {
    image(img, x, y, size, size);
  }

  // Rectangle collision check between the collectible and a character.
  boolean collidesWith(Character c) {
    // Edges of the character hitbox.
    float mageLeft=c.x;
    float mageRight=c.x+c.spriteWidth;
    float mageTop=c.y;
    float mageBottom=c.y+c.spriteHeight;
    // Edges of the collectible hitbox.
    float coinLeft=this.x;
    float coinRight=this.x+this.size;
    float coinTop=this.y;
    float coinBottom=this.y+this.size;
    // Return true when the two rectangles overlap.
    return(mageRight>coinLeft&&mageLeft<coinRight&&mageBottom>coinTop&&mageTop<coinBottom);
  }
}
