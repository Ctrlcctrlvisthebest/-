class Platform {
  // Top-left position of the platform tile.
  float x, y;
  // Image to use when drawing the tile.
  PImage img;
  // Width and height of the square tile.
  float size;

  // Create one platform tile.
  Platform(float x,float y, PImage img,float size){
    this.x=x;
    this.y=y;
    this.img=img;
    this.size=size;
  }

  // Draw the platform tile at its position.
  void display(){
    image(img,x,y,size,size);
  }
}
