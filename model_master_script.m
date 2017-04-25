%% Read in the data and set constants
clc;
clear all;
close all;

% Load Data
load('Data/IndexReturns.mat'); 
load('Data/ModelReturns.mat'); 

% Set Program Constants
nWeeks = size(ModelReturns, 1);
nModels = size(ModelReturns, 2);
windowSize = 12;
nYears = 12;
nWindows = nWeeks/windowSize;
 
%% Calculate features of the model
 
% Calculate (1) alpha, (2) beta, (3) standard deviation (4) R-Squared, (5)
... (5) Sharpe Ratio for EACH window in the dataset
[features, windowAlpha] = calc_features(ModelReturns, IndexReturns, nWeeks, nWindows, windowSize, nModels); 

%% Calculate the reponse variable

% Set the minimum alpha per WEEK you would like to train the model on
weekMinAlpha = .01;
response = calc_response(windowAlpha, nWindows, nModels);

%% Divide into train and test

% Combine calculated features and responses
allData = [features, response];

% Set training and test start weeks
trainStartWindow = 1;
trainEndWindow = 25;
testStartWindow = 26;
testEndWindow = 44;

% Split the data
trainData = allData(trainStartWindow:trainEndWindow, :);
trainPred = trainData(:, 1:30);
trainResp = trainData(:, 31:end);
testData = allData (testStartWindow:testEndWindow, :);
testPred = testData(:, 1:30);
testResp = testData(:, 31:end);

%% Train neural network

nHiddenNodes = 50;
validationFrac = .25;
maxEpochs = 100;
NeuralNet = train_neural_net(trainPred, trainResp, nHiddenNodes, validationFrac, maxEpochs);

%% Pass test data into the trained neural network

neuralNetPredictions = transpose(NeuralNet(transpose(testPred)));
for i = 1:length(neuralNetPredictions)
    [tempMax, bestModelIndex(i , 1)] = max(neuralNetPredictions(i, :));
end

%% Calculate and plot our models returns over all windows 
plotIsOn = 1; 
allReturns = calc_returns(ModelReturns, IndexReturns, bestModelIndex, testStartWindow, windowSize, nWeeks, plotIsOn);

%% Print the performance of our model, other models, and index performance

% Calculate the number of years we tested over
nTestYears = (testEndWindow - testStartWindow)/4;

% Model vs. Index performance
fprintf('Our models return was %.4f per year \n', nthroot(allReturns(8), nTestYears) - 1);
fprintf('Index return was %.4f per year \n', nthroot(allReturns(7), nTestYears) - 1);

% Comparison to all other strategies
fprintf('CZeSD return was %.4f per year \n', nthroot(allReturns(1), nTestYears) - 1);
fprintf('KP_SSD return was %.4f per year \n', nthroot(allReturns(2), nTestYears) - 1);
fprintf('L_SSD return was %.4f per year \n', nthroot(allReturns(3), nTestYears) - 1);
fprintf('LR_ASSD return was %.4f per year \n', nthroot(allReturns(4), nTestYears) - 1);
fprintf('MeanVar return was %.4f per year \n', nthroot(allReturns(5), nTestYears) - 1);
fprintf('RMZ_SSD return was %.4f per year \n', nthroot(allReturns(6), nTestYears) - 1);

disp(bestModelIndex);




