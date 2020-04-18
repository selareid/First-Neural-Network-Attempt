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
Network bestNetwork;
int neuronSize = 10;
int neuroDistance = 25;
int layerDistance = 100;

boolean drawAtAll = true;
boolean moveGoal = false;
boolean masterOnly = false;
boolean showPath = true;
boolean showNetwork = true;
boolean stopEvolving = false;

void setup() {
  size(1000, 400);
  
  mmYVelocity[0] = round(-height/50);
  mmYVelocity[1] = round(height/50);
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
  if (drawAtAll) {
    clear();
    background(255, 255, 255);
    
    textSize(24);
    fill(#000000);
    text("Run: " + runNumber + " Step: " + tickNumber + "/" + stepsAllowed + " Score: " + bestScore, 15, 50);  
    textSize(12);
    text(" Last Improv: " + lastImprovement + " FPS: " + round(frameRate*100)/100, 15, 75);
    
    fill(#42d113);
    circle(startPos.x, startPos.y, goalSize*2);
    fill(#ff22ff);
    circle(goal.x, goal.y, goalSize*2);
    noFill();
  }
  else if (round(millis()/1000)*1000 % 5000 == 0) {
    clear();
    text(round(frameRate*100)/100, 10, 10);
  }
  
  if (tickNumber >= stepsAllowed) {
    tickNumber = 0;
    runNumber++;
  }
  
  if (moveGoal) {
    goal.x+=random(-100,100);
    goal.y+=random(-100,100);
    
    goal.x = (float) constrainValue(goal.x, topLeft.x+50, bottomRight.x-50);
    goal.y = (float) constrainValue(goal.y, bottomLeft.y*0.6, bottomLeft.y-50);
    
    startPos.x+=random(-100,100);
    startPos.y+=random(-100,100);
    
    startPos.x = (float) constrainValue(startPos.x, topLeft.x+50, bottomRight.x-50);
    startPos.y = (float) constrainValue(startPos.y, bottomLeft.y*0.6, bottomLeft.y-50);
    
    moveGoal = false;
  }
  
  labRats.tick();
  tickNumber++;
  
  if (drawAtAll) {
    line(topLeft.x, topLeft.y, topRight.x, topRight.y);
    line(bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y);
    line(topLeft.x, topLeft.y, bottomLeft.x, bottomLeft.y);
    line(topRight.x, topRight.y, bottomRight.x, bottomRight.y);
  }
  
  if (drawAtAll && showPath && bestPath != null && bestPath[0] != null) {
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
    
  if (drawAtAll && showNetwork && bestNetwork != null) {
    PVector startDrawing = new PVector(topLeft.x+10, topLeft.y+75);
    
    for (int layer_i = 0; layer_i < bestNetwork.layers.length; layer_i++) {
      for (int neuron_i = 0; neuron_i < bestNetwork.layers[layer_i].length; neuron_i++) {
        noFill();
        strokeWeight(1);
        circle(startDrawing.x+layer_i*layerDistance, startDrawing.y+neuron_i*neuroDistance, neuronSize);
        
        for (int connection_i = 0; connection_i < bestNetwork.layers[layer_i][neuron_i].connections.length; connection_i++) {
          if (bestNetwork.layers[layer_i][neuron_i].connections[connection_i] > 0) stroke(#000000);
          else stroke(#FF0000);
          
          strokeWeight(abs((float) sigmoid(bestNetwork.layers[layer_i][neuron_i].connections[connection_i])));
          line(startDrawing.x+layer_i*layerDistance, startDrawing.y+neuron_i*neuroDistance, startDrawing.x+(layer_i+1)*layerDistance, startDrawing.y+connection_i*neuroDistance);
        }
      }
    }
    
    noFill();
    strokeWeight(1);
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
    case 'n':
      showNetwork = !showNetwork;
      break;
    //case 'r':
    //  setup();
    //  break;
    //case 'c':
    //  showBombCross = !showBombCross;
    //  break;
    case 'q':
      drawAtAll = !drawAtAll;
      fill(#FFFFFF);
      clear();
      break;
    //case 't':
    //  showText = !showText;
    //  break;
    }
}
