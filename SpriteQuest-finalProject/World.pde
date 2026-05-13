class World {
  // 2D grid of solid tiles used for drawing and collision.
  Platform[][] tileGrid;
  // Size of the current map measured in tile rows and columns.
  int rows, cols;
  // Tile and collectible images loaded from the data folder.
  PImage redBrick, snow, brownBrick, crate,coinImg,gemImg,magma,water;
  // Raw CSV lines that describe the map layout.
  String[] csvLines;
  // Enemy spawn point read from the map.
  float enemySpawnX;
  float enemySpawnY;
  boolean hasEnemySpawn;

  // Build a world by loading the CSV file from disk.
  World(String filename) {
    csvLines =loadStrings(filename);
    initWorld();
  }

  // Build a world from CSV lines that were already loaded elsewhere.
  World(String[] preloadedLines) {
    csvLines = preloadedLines;
    initWorld();
  }

  // Shared setup used by both constructors.
  void initWorld() {
    // Count map rows and columns from the CSV file.
    rows = csvLines.length;
    cols = split(csvLines[0],",").length;
    // Load all artwork used by map tiles and collectibles.
    redBrick = loadImage("red_brick.png");
    snow = loadImage("snow.png");
    brownBrick = loadImage("brown_brick.png");
    crate = loadImage("crate.png");  
    coinImg=loadImage("gold1.png");
    gemImg=loadImage("gem1.png");
    magma=loadImage("magma.png");
    water=loadImage("water.png");
    // Default spawn values before reading the map.
    enemySpawnX = 0;
    enemySpawnY = 0;
    hasEnemySpawn = false;
    // Create the tile grid array.
    tileGrid = new Platform[cols][rows];
    // Fill the world by reading the map data.
    createPlatforms();
  }

  // Read each CSV cell and turn it into the correct object.
  void createPlatforms() {
    for (int row = 0; row < rows; row++) {
      // Split one CSV line into individual tile codes.
      String[] values =split(csvLines[row],",");
      for (int col = 0; col < values.length; col++) {
        // Remove extra spaces around each tile code.
        String val = values[col].trim();
        PImage img = null;
        // Decide what to place based on the code in the map file.
        switch(val){
          case "1":
            img=redBrick;
            addTile(col,row,img);
            break;
          case "2":
            img=snow;
            addTile(col,row,img);
            break;
          case "3":
            img=brownBrick;
            addTile(col,row,img);
            break;
          case "4":
            img=crate;
            addTile(col,row,img);
            break;
          case "5":
            img=coinImg;
            addCollectible(col,row,img,"coin");
            break;
          case "6":
            img=gemImg;
            addCollectible(col,row,img,"gem");
            break;
          case "7":
            img=magma;
            addCollectible(col,row,img,"magma");
            break;
          case "8":
            img=water;
            addTile(col,row,img);
            break;
          case "9":
            // Code 9 marks the enemy spawn point instead of drawing a tile.
            setEnemySpawn(col, row);
            break;
          default:
            // Empty or unknown cells create nothing.
            img=null;
        }
      }
    }
  }

  // Place one solid tile into the world grid.
  void addTile(int col, int row, PImage img) {
    tileGrid[col][row] = new Platform(col*TILE_SIZE,row*TILE_SIZE,img,TILE_SIZE);
  }

  // Place one collectible object into the level.
  void addCollectible(int col, int row, PImage img, String type) {
    collectibles.add(new Collectible(col*TILE_SIZE,row*TILE_SIZE,img,TILE_SIZE,type));
  }
  
  // Save the enemy spawn location in pixel coordinates.
  void setEnemySpawn(int col, int row) {
    enemySpawnX = col * TILE_SIZE;
    enemySpawnY = row * TILE_SIZE;
    hasEnemySpawn = true;
  }

  // Draw every solid tile in the 2D map.
  void drawTiles() {
    for(int col=0;col<cols;col++){
      for(int row=0;row<rows;row++){
        Platform p=tileGrid[col][row];
        if(p!=null){
          p.display();
        }
      }
    }
  }

  // Return only the solid tiles near a character for faster collision checks.
  ArrayList<Platform>getNearByTiles(Character c){
    ArrayList<Platform>nearby=new ArrayList<Platform>();
    // Convert the character position into tile coordinates.
    int currCol=(int)(c.x/TILE_SIZE);
    int currRow=(int)(c.y/TILE_SIZE);
    // Expand by one tile in each direction so collisions are still detected cleanly.
    int leftCol=max(0,currCol-1);
    int rightCol=min(cols-1,(int)((c.x+c.spriteHeight)/TILE_SIZE)+1);
    int topRow=max(0,currRow-1);
    int bottomRow=min(rows-1,(int)((c.y+c.spriteHeight)/TILE_SIZE)+1);
    // Collect all non-null tiles inside that small rectangle.
    for(int col=leftCol;col<=rightCol;col++){
      for(int row=topRow;row<=bottomRow;row++){
        Platform p=tileGrid[col][row];
        if(p!=null)nearby.add(p);
      }
    }
    return nearby;
  }
  
  // Check whether a specific pixel position is inside a solid tile.
  boolean isSolidAt(float pixelX, float pixelY){
    int col = floor(pixelX / TILE_SIZE);
    int row = floor(pixelY / TILE_SIZE);
    // Outside the map counts as non-solid here.
    if (col < 0 || col >= cols || row < 0 || row >= rows) {
      return false;
    }
    return tileGrid[col][row] != null;
  }
  
  // Find the y-position where an enemy should stand for a given x-position.
  float findGroundY(float pixelX){
    int col = constrain(floor((pixelX + SPRITE_WIDTH / 2) / TILE_SIZE), 0, cols - 1);
    // Search downward until the first solid tile is found.
    for (int row = 0; row < rows; row++) {
      Platform p = tileGrid[col][row];
      if (p != null) {
        return p.y - SPRITE_HEIGHT;
      }
    }
    // Fallback to the bottom of the world if no ground was found.
    return rows * TILE_SIZE - SPRITE_HEIGHT;
  }
  
  // Return the stored enemy spawn x, or a fallback if none exists.
  float getEnemySpawnX() {
    if (hasEnemySpawn) {
      return enemySpawnX;
    }
    return 600;
  }
  
  // Return the stored enemy spawn y, or calculate one from ground height.
  float getEnemySpawnY() {
    if (hasEnemySpawn) {
      return enemySpawnY;
    }
    return findGroundY(getEnemySpawnX());
  }
}
