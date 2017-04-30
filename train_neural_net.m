function [ NeuralNet, trainData ] = train_neural_net(trainPred, trainResp, nHiddenNodes, validationFrac, maxEpochs)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

% Set up the parameters of network
NeuralNet = patternnet(nHiddenNodes);
NeuralNet.divideFcn = 'dividerand';
NeuralNet.divideParam.valRatio = validationFrac;
NeuralNet.divideParam.trainRatio = 1-validationFrac;
NeuralNet.divideParam.testRatio = 0;
NeuralNet.trainParam.epochs = maxEpochs; 

% Train the network
[NeuralNet, trainData] = train(NeuralNet, transpose(trainPred), transpose(trainResp), 'useParallel','yes');

end

