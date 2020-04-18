class Square {
  Network myBrain;
  
  PVector velocity = new PVector(0, 0);
  PVector position;

  float top;
  float bottom;
  float left;
  float right;

  int squareWidth;
  int squareHeight;
  
  color squareColor;
  
  int score;
  int ticksUsed = 0;
  
  boolean master = false;
  boolean dead = false;
  boolean reachedGoal = false;
  
  PVector[] path;
  
  Square (int sizeGiven) {
    squareColor = color(random(0, 200), random(0, 200), random(0, 200));
    
    squareWidth = sizeGiven;
    squareHeight = sizeGiven;
    
    position = startPos.copy();
    applyTopBottomETC();
    
    myBrain = new Network();
    
    path = new PVector[stepsAllowed];
  }
  
  int getScore() {
    return round(((position.dist(goal) + 1)/1.2)+0.1 * ticksUsed * 100);
  }
  
  void tickSquare () {
    if (dead) return;
    
    if (!reachedGoal) {
      float[] dataToPassToNetwork = {position.x, position.y, goal.x, goal.y, velocity.x, velocity.y}; //TODO add the bombz
      float[] networkOutput = myBrain.runNetwork(dataToPassToNetwork);
      //apply network output to square
      changeXVelocity(networkOutput[0]);
      changeYVelocity(networkOutput[1]);
      
      applyGravity(); //changes velocity
      
      moveSquare(); //changes position
      applyTopBottomETC(); //updates position things
      
      score = getScore();
      ticksUsed++;
      
      if (position.dist(goal) < goalSize) {
        reachedGoal = true;
      }
    }
    
    if (drawAtAll && (!masterOnly || master)) drawSquare(); //draws
    
    path[ticksUsed-1] = position.copy();
  }
  
  void applyTopBottomETC () {
    top = position.y - squareHeight/2;
    bottom = position.y + squareHeight/2;
    left = position.x - squareWidth/2;
    right = position.x + squareWidth/2;
  }
  
  void drawSquare () {
    stroke(squareColor);
    
    line(left, top, left, bottom);
    line(left, top, right, top);
    line(right, top, right, bottom);
    line(left, bottom, right, bottom);
    
    stroke(0, 0, 0);
    point(position.x, position.y);
  }
  
  boolean touchingGround () {    
    if (bottom > min(bottomLeft.y, bottomRight.y) - 1) return true;    
    return false;
  }
  
  void applyGravity () {
    if (!touchingGround()) velocity.y += gravityAmount;
  }
  
  //applies velocity to position
  void moveSquare () {
    if (right + velocity.x < min(topRight.x, bottomRight.x)) {
      if (left + velocity.x > max(topLeft.x, bottomLeft.x)) {
        position.x += velocity.x;
      } else {
        velocity.x = 0-round(velocity.x/5);
      position.x = max(topLeft.x, bottomLeft.x) + 0.1 + squareWidth/2;
      }
    } else {
      velocity.x = 0-round(velocity.x/5);
      position.x = min(topRight.x, bottomRight.x) - 0.1 - squareWidth/2;
    }

    if (bottom + velocity.y <= min(bottomLeft.y, bottomRight.y) - 0.1) {
      if (top + velocity.y > max(topLeft.y, topRight.y) + 0.1) {
        position.y += velocity.y;
      } else {
        velocity.y = 0.1;
        position.y = max(topLeft.y, topRight.y) + 0.1 + squareHeight/2;
      }
    } else {
      velocity.y = 0-round(velocity.y/3);
      position.y = min(bottomLeft.y, bottomRight.y) - 0.1   - squareHeight/2;
    }
  }
  
  void changeXVelocity(float changeAmount) {
    if (touchingGround()) velocity.x = round(velocity.x * 1000)/1000 + changeAmount;
    velocity.x = (float) constrainValue(velocity.x, mmXVelocity[0], mmXVelocity[1]);
  }
  
  void changeYVelocity(float changeAmount) {
    if (touchingGround()) velocity.y = round(velocity.y * 1000)/1000 + changeAmount;
    velocity.y = (float) constrainValue(velocity.y, mmYVelocity[0], mmYVelocity[1]);
  }
}
