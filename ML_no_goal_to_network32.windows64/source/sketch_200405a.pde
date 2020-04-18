double constrainValue(double valueToCheck, double min, double max) {
  if (valueToCheck > max) return max;
  if (valueToCheck < min) return min;
  return valueToCheck;
}

Population labRats;

PVector topLeft;
PVector topRight;
PVector bottomLeft;
PVector bottomRight;

int squareSize = 25;
int populationSize = 10;
final float gravityAmount = 0.1;
final float[] mmXVelocity = {-5, 5}; //min max
final float[] mmYVelocity = {-6, 6}; //min max
PVector goal = new PVector(750, 330);
int goalSize = 5;
PVector startPos;

int tickNumber;
int runNumber;
int lastImprovement;
int stepsAllowed;
int bestScore;

PVector[] bestPath;

boolean moveGoal = false;
boolean masterOnly = false;
boolean showPath = true;
boolean stopEvolving = false;

void setup() {
  size(1000, 400);
  
  runNumber = 0;
  lastImprovement = 0;
  stepsAllowed = 150;
  bestScore = 999999;
  
  frameRate(5000);
  
  topLeft = new PVector(10, 10);
  topRight = new PVector (width-10, 10);
  bottomLeft = new PVector(10, height-10);
  bottomRight = new PVector(width-10, height-10);
  
  startPos = new PVector(bottomLeft.x+squareSize+0.1, bottomLeft.y-squareSize-0.1);
  
  labRats = new Population();
}

void draw() {
  clear();
  background(255, 255, 255);
  
  textSize(24);
  fill(#000000);
  text("Run: " + runNumber + " Step: " + tickNumber + "/" + stepsAllowed + " Score: " + bestScore, 15, 50);  
  textSize(12);
  text(" Last Improv: " + lastImprovement + " FPS: " + round(frameRate*100)/100, 15, 75);
  
  fill(#ff22ff);
  circle(goal.x, goal.y, goalSize*2);
  noFill();
  
  
  if (tickNumber >= stepsAllowed) {
    tickNumber = 0;
    runNumber++;
  }
  
  if (moveGoal) {
    goal.x+=random(-100,100);
    goal.y+=random(-100,100);
    
    goal.x = (float) constrainValue(goal.x, topLeft.x+50, bottomRight.x-50);
    goal.y = (float) constrainValue(goal.y, bottomLeft.y*0.6, bottomLeft.y-50);
    
    moveGoal = false;
  }
  
  labRats.tick();
  tickNumber++;
  
  line(topLeft.x, topLeft.y, topRight.x, topRight.y);
  line(bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y);
  line(topLeft.x, topLeft.y, bottomLeft.x, bottomLeft.y);
  line(topRight.x, topRight.y, bottomRight.x, bottomRight.y);
  
  if (showPath && bestPath != null && bestPath[0] != null) {
    for (int position_it = 1; position_it < bestPath.length && bestPath[position_it] != null; position_it++) {
      boolean dunIt = false;
      PVector secondPos;
      
      if (bestPath.length > position_it+5 && bestPath[position_it+4] != null) {
        secondPos = bestPath[position_it+4];
        dunIt = true;
      } else secondPos = bestPath[position_it];
      
      line(bestPath[position_it-1].x, bestPath[position_it-1].y, secondPos.x, secondPos.y);
      if (dunIt) position_it += 4;
    }
  }
}

void keyTyped() {
  switch (key) {
    case 'b':
      masterOnly = !masterOnly;
      break;
    case 'p':
      showPath = !showPath;
      break;
    case 'r':
      stopEvolving = !stopEvolving;
      break;
    case 'm':
      moveGoal = true;
      break;
    //case 'r':
    //  setup();
    //  break;
    //case 'c':
    //  showBombCross = !showBombCross;
    //  break;
    //case 'q':
    //  drawNone = !drawNone;
    //  if (drawNone) frameRate(1000);
    //  break;
    //case 't':
    //  showText = !showText;
    //  break;
    }
}
