// Processing calls this once whenever a key is pressed.
void keyPressed() {
  // Remember that the left arrow is being held.
  if (keyCode == LEFT) {
    leftPressed=true;
  // Remember that the right arrow is being held.
  }else if(keyCode==RIGHT){
    rightPressed=true;
  // Remember that the up arrow is being held for jumping.
  }else if(keyCode==UP){
    jumpPressed=true;
  // Number keys select difficulty on menu screens.
  }else if(key == '1' && state != GameState.PLAYING && state != GameState.LOADING){
    selectedDifficulty = Difficulty.EASY;
  }else if(key == '2' && state != GameState.PLAYING && state != GameState.LOADING){
    selectedDifficulty = Difficulty.NORMAL;
  }else if(key == '3' && state != GameState.PLAYING && state != GameState.LOADING){
    selectedDifficulty = Difficulty.HARD;
  // X fires a water projectile.
  }else if(key == 'x' || key == 'X'){
    fireWaterProjectile();
  // Space triggers reset / start / restart behavior depending on the game state.
  }else if(keyCode==' '){
    resetmage=true;
  }
}

// Processing calls this once whenever a key is released.
void keyReleased() {
  // Stop moving left when the left arrow is released.
  if(keyCode==LEFT){
    leftPressed=false;
  // Stop moving right when the right arrow is released.
  }else if(keyCode==RIGHT){
    rightPressed=false;
  // Stop jump input when the up arrow is released.
  }else if(keyCode==UP){
    jumpPressed=false;
  }
}
