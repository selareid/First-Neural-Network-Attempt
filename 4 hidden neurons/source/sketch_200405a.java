import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sketch_200405a extends PApplet {

public double constrainValue(double valueToCheck, double min, double max) {
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
final float gravityAmount = 0.1f;
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

public void setup() {
  
  
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
  
  startPos = new PVector(bottomLeft.x+squareSize+0.1f, bottomLeft.y-squareSize-0.1f);
  
  labRats = new Population();
}

public void draw() {
  if (drawAtAll) {
    clear();
    background(255, 255, 255);
    
    textSize(24);
    fill(0xff000000);
    text("Run: " + runNumber + " Step: " + tickNumber + "/" + stepsAllowed + " Score: " + bestScore, 15, 50);  
    textSize(12);
    text(" Last Improv: " + lastImprovement + " FPS: " + round(frameRate*100)/100, 15, 75);
    
    fill(0xff42d113);
    circle(startPos.x, startPos.y, goalSize*2);
    fill(0xffff22ff);
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
    goal.y = (float) constrainValue(goal.y, bottomLeft.y*0.6f, bottomLeft.y-50);
    
    startPos.x+=random(-100,100);
    startPos.y+=random(-100,100);
    
    startPos.x = (float) constrainValue(startPos.x, topLeft.x+50, bottomRight.x-50);
    startPos.y = (float) constrainValue(startPos.y, bottomLeft.y*0.6f, bottomLeft.y-50);
    
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
          if (bestNetwork.layers[layer_i][neuron_i].connections[connection_i] > 0) stroke(0xff000000);
          else stroke(0xffFF0000);
          
          strokeWeight(abs((float) sigmoid(bestNetwork.layers[layer_i][neuron_i].connections[connection_i])));
          line(startDrawing.x+layer_i*layerDistance, startDrawing.y+neuron_i*neuroDistance, startDrawing.x+(layer_i+1)*layerDistance, startDrawing.y+connection_i*neuroDistance);
        }
      }
    }
    
    noFill();
    strokeWeight(1);
  }
}

public void keyTyped() {
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
      fill(0xffFFFFFF);
      clear();
      break;
    //case 't':
    //  showText = !showText;
    //  break;
    }
}
class Network {
  Neuron[][] layers; // [layer][neuron]

  Network () {
    layers = new Neuron[3][];
    layers[0] = new Neuron[6]; //input neurons
    layers[1] = new Neuron[4]; //hidden layer
    layers[layers.length-1] = new Neuron[2]; //output neurons

    //initialise input neurons
    for (int i = 0; i < layers[0].length; i++) {
      layers[0][i] = new Neuron(layers[1].length, 1);
    }

    //initialise output neurons
    for (int i = 0; i < layers[layers.length-1].length; i++) {
      layers[layers.length-1][i] = new Neuron(0, 2);
    }

    //initialise hidden layers, all are sigma
    for (int layer_i = 1; layer_i < layers.length-1; layer_i++) {
      for (int neuron_i = 0; neuron_i < layers[layer_i].length; neuron_i++) {
        layers[layer_i][neuron_i] = new Neuron(layers[layer_i+1].length, 0);
      }
    }
  }

  public void randomizeNetwork () {
    //for each neuron in network, run randomise
    for (int layer_i = 0; layer_i < layers.length; layer_i++) {
      for (int neuron_i = 0; neuron_i < layers[layer_i].length; neuron_i++) {
        layers[layer_i][neuron_i].randomiseValues();
      }
    }
  }

  public void mutateFrom (Network parentNetwork) {
    for (int layer_i = 0; layer_i < layers.length; layer_i++) {
      for (int neuron_i = 0; neuron_i < layers[layer_i].length; neuron_i++) {
        layers[layer_i][neuron_i].type = parentNetwork.layers[layer_i][neuron_i].type;
        layers[layer_i][neuron_i].bias = parentNetwork.layers[layer_i][neuron_i].bias + random(-0.100001f, 0.100001f);

        for (int connect_i = 0; connect_i < layers[layer_i][neuron_i].connections.length; connect_i++) {
          layers[layer_i][neuron_i].connections[connect_i] = parentNetwork.layers[layer_i][neuron_i].connections[connect_i] + random(-10.00001f, 10.00001f);
        }
      }
    }
  }

  public float[] runNetwork (float[] inputData) {
    float[] networkOutput = new float[layers[layers.length-1].length];

    for (int layer_i = 0; layer_i < layers.length; layer_i++) {
      for (int neuron_i = 0; neuron_i < layers[layer_i].length; neuron_i++) {
        if (layer_i == 0) {
          layers[layer_i][neuron_i].runNeuron(inputData[neuron_i]);
        } else {
          float sumOfValuesToSend = layers[layer_i][neuron_i].bias;

          for (int lastNeuron_i = 0; lastNeuron_i < layers[layer_i-1].length; lastNeuron_i++) {            
            sumOfValuesToSend += layers[layer_i-1][lastNeuron_i].output * layers[layer_i-1][lastNeuron_i].connections[neuron_i];
          }

          layers[layer_i][neuron_i].runNeuron(sumOfValuesToSend);
        }

        if (layer_i == layers.length-1) {
          networkOutput[neuron_i] = layers[layer_i][neuron_i].output;
        }
      }
    }

    return networkOutput;
  }
}
/**
 * シグモイド関数: Sigmoid function
 */
private double sigmoid(double x) {
    return (2.0f / (1 + Math.exp(-x))) - 1;
}

class Neuron {
  float[] connections; //weights
  float bias;
  int type;
  
  float output;
  
  Neuron (int neuronsInNextLayer, int givenType) {
    bias = 0;
    type = givenType;
    
    connections = new float[neuronsInNextLayer];
    
    for (int i = 0; i < neuronsInNextLayer; i++) {
      connections[i] = 0;
    }
  }
  
  public void randomiseValues() {
    bias = random(-1, 1);
    
    for (int i = 0; i < connections.length; i++) {
      connections[i] = random(-1, 1);
    }
  }
  
  public void runNeuron (float inputValue) { //input value is sum of each neuron in last layer's output * weight
    float outputValue;
    
    switch (type) {
      case 1: //input neuron
        outputValue = inputValue;
        break;
      case 2: //output neuron
        outputValue = (float) sigmoid(inputValue) * 5; //velocity change (-1 to 1 * 5 gives -5 to 5)
        break;
      case 3: //rectified linear unit
        outputValue = inputValue + bias > 0 ? inputValue + bias : 0;
        break;
      default: //0, sigmoid
        outputValue = (float) sigmoid(inputValue + bias);
    }
    
    output = outputValue;
  }
}
class Population {
  Square[] populous;
  Square bestSquare;
  
  Population () {
    populous = new Square[populationSize];
    
    for (int square_i = 0; square_i < populous.length; square_i++) {
      populous[square_i] = new Square(squareSize);
      populous[square_i].myBrain.randomizeNetwork();
    }
  }
  
  public void tick () {
    if (tickNumber == 0 && runNumber != 0) { //start of new round, not first we need to reset populous
      Square newBest = null;
    
      if (stopEvolving) newBest = populous[0];
      else {
        for (Square currentSquare : populous) {
          //if (currentSquare.dead) continue;
          
          if (newBest == null || currentSquare.score < newBest.score) {
            newBest = currentSquare;
          }
        }
      }
    
      if (newBest.score < bestScore) {
        lastImprovement = runNumber;
      }
      
      bestScore = newBest.score;
      bestPath = newBest.path;
      bestNetwork = newBest.myBrain;
      
      if (newBest.reachedGoal) {
        stepsAllowed = round(newBest.ticksUsed*max(1.25f, runNumber/3000));
        
        if (runNumber-20 >= lastImprovement) {
          stepsAllowed = stepsAllowed*2;
          moveGoal = true;
          lastImprovement = runNumber;
        }
      }
      else if (runNumber - 1000 >= lastImprovement) moveGoal = true;
      else if (runNumber-10 >= lastImprovement) {
        stepsAllowed += 10;
        newBest.score += 10;
      }
      
      bestSquare = newBest;
      
      newPopulation();
    }
    
   //tick
   for (Square square : populous) {
     square.tickSquare();
   }
  }
  
  public void newPopulation () {
    populous = new Square[populationSize];
    
    for (int square_i = 0; square_i < populous.length; square_i++) {
      populous[square_i] = new Square(squareSize);
      populous[square_i].myBrain.mutateFrom(bestSquare.myBrain);
    }
    
    populous[0].myBrain = bestSquare.myBrain;
    populous[0].master = true;
  }
}
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
  
  int squareColor;
  
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
  
  public int getScore() {
    return round(((position.dist(goal) + 1)/1.2f)+0.1f * ticksUsed * 100);
  }
  
  public void tickSquare () {
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
  
  public void applyTopBottomETC () {
    top = position.y - squareHeight/2;
    bottom = position.y + squareHeight/2;
    left = position.x - squareWidth/2;
    right = position.x + squareWidth/2;
  }
  
  public void drawSquare () {
    stroke(squareColor);
    
    line(left, top, left, bottom);
    line(left, top, right, top);
    line(right, top, right, bottom);
    line(left, bottom, right, bottom);
    
    stroke(0, 0, 0);
    point(position.x, position.y);
  }
  
  public boolean touchingGround () {    
    if (bottom > min(bottomLeft.y, bottomRight.y) - 1) return true;    
    return false;
  }
  
  public void applyGravity () {
    if (!touchingGround()) velocity.y += gravityAmount;
  }
  
  //applies velocity to position
  public void moveSquare () {
    if (right + velocity.x < min(topRight.x, bottomRight.x)) {
      if (left + velocity.x > max(topLeft.x, bottomLeft.x)) {
        position.x += velocity.x;
      } else {
        velocity.x = 0-round(velocity.x/5);
      position.x = max(topLeft.x, bottomLeft.x) + 0.1f + squareWidth/2;
      }
    } else {
      velocity.x = 0-round(velocity.x/5);
      position.x = min(topRight.x, bottomRight.x) - 0.1f - squareWidth/2;
    }

    if (bottom + velocity.y <= min(bottomLeft.y, bottomRight.y) - 0.1f) {
      if (top + velocity.y > max(topLeft.y, topRight.y) + 0.1f) {
        position.y += velocity.y;
      } else {
        velocity.y = 0.1f;
        position.y = max(topLeft.y, topRight.y) + 0.1f + squareHeight/2;
      }
    } else {
      velocity.y = 0-round(velocity.y/3);
      position.y = min(bottomLeft.y, bottomRight.y) - 0.1f   - squareHeight/2;
    }
  }
  
  public void changeXVelocity(float changeAmount) {
    if (touchingGround()) velocity.x = round(velocity.x * 1000)/1000 + changeAmount;
    velocity.x = (float) constrainValue(velocity.x, mmXVelocity[0], mmXVelocity[1]);
  }
  
  public void changeYVelocity(float changeAmount) {
    if (touchingGround()) velocity.y = round(velocity.y * 1000)/1000 + changeAmount;
    velocity.y = (float) constrainValue(velocity.y, mmYVelocity[0], mmYVelocity[1]);
  }
}
  public void settings() {  size(1000, 400); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "sketch_200405a" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
