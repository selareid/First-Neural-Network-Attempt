/**
 * シグモイド関数: Sigmoid function
 */
private double sigmoid(double x) {
    return (2.0 / (1 + Math.exp(-x))) - 1;
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
  
  void randomiseValues() {
    bias = random(-1, 1);
    
    for (int i = 0; i < connections.length; i++) {
      connections[i] = random(-1, 1);
    }
  }
  
  void runNeuron (float inputValue) { //input value is sum of each neuron in last layer's output * weight
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
