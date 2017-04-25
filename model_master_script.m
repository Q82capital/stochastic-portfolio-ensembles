%% Read in the data and set constants
clc;
clear all;

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
targetAlpha = .0035;
response = calc_response(windowAlpha, targetAlpha, nWindows, nModels);

%% Divide into train and test

% Combine calculated features and responses
allData = [features, response];

% Set training and test start weeks
trainStartWindow = 1;
trainEndWindow = 30;
testStartWindow = 31;
testEndWindow = 44;

% Split the data
trainData = allData(trainStartWindow:trainEndWindow, :);
trainPred = trainData(:, 1:30);
trainResp = trainData(:, 31:end);
testData = allData (testStartWindow:testEndWindow, :);
testPred = testData(:, 1:30);
testResp = testData(:, 31:end);

for test = 1: 100

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

%% Calculate model risks
modelRisks = zeros(1, nModels + 1);
for i = 1:nModels
    modelRisks(i) = std(ModelReturns(:, i));
end
modelRisks(nModels + 1) = std(IndexReturns);

% Calculate our risk by averaging risk of models we chose
ourRisk = 0;
for i = 1:length(bestModelIndex)
    ourRisk = ourRisk + modelRisks(bestModelIndex(i));
end
ourRisk = ourRisk/length(bestModelIndex);

%% Calculate model yearly returns

% Calculate the number of years we tested over
nTestYears = (testEndWindow - testStartWindow)/4;

yearlyReturns = zeros(1, nModels + 1);
for i = 1:nModels + 1
    yearlyReturns(i) = nthroot(allReturns(i), nTestYears) - 1;
end
ourReturn = nthroot(allReturns(nModels + 2), nTestYears) - 1;

%% Print the performance of our model, other models, and index performance

% Model performance
fprintf('Our     return was %.4f per year with risk %.4f \n', ourReturn, ourRisk);

% Comparison to all other strategies
fprintf('CZeSD   return was %.4f per year with risk %.4f \n', yearlyReturns(1), modelRisks(1));
fprintf('KP_SSD  return was %.4f per year with risk %.4f \n', yearlyReturns(2), modelRisks(2));
fprintf('L_SSD   return was %.4f per year with risk %.4f \n', yearlyReturns(3), modelRisks(3));
fprintf('LR_ASSD return was %.4f per year with risk %.4f \n', yearlyReturns(4), modelRisks(4));
fprintf('MeanVar return was %.4f per year with risk %.4f \n', yearlyReturns(5), modelRisks(5));
fprintf('RMZ_SSD return was %.4f per year with risk %.4f \n', yearlyReturns(6), modelRisks(6));
fprintf('Index   return was %.4f per year with risk %.4f \n', yearlyReturns(7), modelRisks(7));

% disp(bestModelIndex);
if ishandle(1)
    clf(1);
end
figure(1);
hold on 
scatter(modelRisks, yearlyReturns, 'g*');
lsline
scatter(ourRisk, ourReturn, 'r*');
xlabel('Risk');
ylabel('Return');
hold off 
title(test);
end