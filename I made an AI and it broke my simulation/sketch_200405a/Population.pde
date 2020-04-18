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
    
      for (Square currentSquare : populous) {
        //if (currentSquare.dead) continue;
        
        if (bestSquare == null || currentSquare.score < bestSquare.score) {
          bestSquare = currentSquare;
        }
      }
      
      if (bestSquare.score < bestScore) {
        lastImprovement = tickNumber;
      }
      
      bestScore = bestSquare.score;
      
      if (bestSquare.reachedGoal) {println("woo");
        stepsAllowed = round(bestSquare.ticksUsed*1.25);
      }
      else if (runNumber-10 >= lastImprovement) {
        //stepsAllowed += 10;
        bestSquare.score += 10;
      }
      
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
  }
}
