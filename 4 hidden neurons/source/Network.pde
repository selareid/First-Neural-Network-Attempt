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

  void randomizeNetwork () {
    //for each neuron in network, run randomise
    for (int layer_i = 0; layer_i < layers.length; layer_i++) {
      for (int neuron_i = 0; neuron_i < layers[layer_i].length; neuron_i++) {
        layers[layer_i][neuron_i].randomiseValues();
      }
    }
  }

  void mutateFrom (Network parentNetwork) {
    for (int layer_i = 0; layer_i < layers.length; layer_i++) {
      for (int neuron_i = 0; neuron_i < layers[layer_i].length; neuron_i++) {
        layers[layer_i][neuron_i].type = parentNetwork.layers[layer_i][neuron_i].type;
        layers[layer_i][neuron_i].bias = parentNetwork.layers[layer_i][neuron_i].bias + random(-0.100001, 0.100001);

        for (int connect_i = 0; connect_i < layers[layer_i][neuron_i].connections.length; connect_i++) {
          layers[layer_i][neuron_i].connections[connect_i] = parentNetwork.layers[layer_i][neuron_i].connections[connect_i] + random(-10.00001, 10.00001);
        }
      }
    }
  }

  float[] runNetwork (float[] inputData) {
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
