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
int populationSize = 100;
final float gravityAmount = 0.1;
final float[] mmXVelocity = {-5, 5}; //min max
final float[] mmYVelocity = {-7, 1}; //min max
PVector goal = new PVector(500, 200);
int goalSize = 5;
PVector startPos;

int tickNumber;
int runNumber;
int lastImprovement;
int stepsAllowed;
int bestScore;

void setup() {
  size(1000, 400);
  
  runNumber = 0;
  lastImprovement = 0;
  stepsAllowed = 10;
  bestScore = 0;
  
  frameRate(5);
  
  topLeft = new PVector(10, 10);
  topRight = new PVector (width-10, 10);
  bottomLeft = new PVector(10, height-10);
  bottomRight = new PVector(width-10, height-10);
  
  startPos = new PVector(50,50);//new PVector(bottomLeft.x+squareSize+0.1, bottomLeft.y-squareSize-0.1);
  
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

  line(topLeft.x, topLeft.y, topRight.x, topRight.y);
  line(bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y);
  line(topLeft.x, topLeft.y, bottomLeft.x, bottomLeft.y);
  line(topRight.x, topRight.y, bottomRight.x, bottomRight.y);
  
  if (tickNumber > stepsAllowed) {
    tickNumber = 0;
    runNumber++;
  }
  
  labRats.tick();
  
  tickNumber++;
}
