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
  
  void tick () {
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
      
      if (newBest.reachedGoal) {
        stepsAllowed = round(newBest.ticksUsed*1.25);
        
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
  
  void newPopulation () {
    populous = new Square[populationSize];
    
    for (int square_i = 0; square_i < populous.length; square_i++) {
      populous[square_i] = new Square(squareSize);
      populous[square_i].myBrain.mutateFrom(bestSquare.myBrain);
    }
    
    populous[0].myBrain = bestSquare.myBrain;
    populous[0].master = true;
  }
}
