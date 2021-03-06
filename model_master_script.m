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

for test = 1: 1

%% Train neural network
nHiddenNodes = 50;
validationFrac = .25;
maxEpochs = 100;
[NeuralNet, trainData] = train_neural_net(trainPred, trainResp, nHiddenNodes, validationFrac, maxEpochs);

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
fprintf('Our     test return was %.4f percent per year with risk %.4f \n', ourReturn*100, ourRisk);

% Comparison to all other strategies
fprintf('CZeSD   test return was %.4f percent per year with risk %.4f \n', yearlyReturns(1)*100, modelRisks(1));
fprintf('KP_SSD  test return was %.4f percent per year with risk %.4f \n', yearlyReturns(2)*100, modelRisks(2));
fprintf('L_SSD   test return was %.4f percent per year with risk %.4f \n', yearlyReturns(3)*100, modelRisks(3));
fprintf('LR_ASSD test return was %.4f percent per year with risk %.4f \n', yearlyReturns(4)*100, modelRisks(4));
fprintf('MeanVar test return was %.4f percent per year with risk %.4f \n', yearlyReturns(5)*100, modelRisks(5));
fprintf('RMZ_SSD test return was %.4f percent per year with risk %.4f \n', yearlyReturns(6)*100, modelRisks(6));
fprintf('Index   test return was %.4f percent per year with risk %.4f \n', yearlyReturns(7)*100, modelRisks(7));

% Plot performance comparisons
if ishandle(1)
    clf(1);
end
figure(1);
hold on
plot(modelRisks, yearlyReturns, 'k*', 'markers',12);
lsline
plot(ourRisk, ourReturn, 'r*', 'markers',12);
plot(modelRisks(7),yearlyReturns(7), 'g*', 'markers',12);
xlabel('Assumed Quarterly Risk');
ylabel('Yearly Return');
legend('Individual Strategies','Best Fit of Individual Strategies', 'Our Model Performance', 'Benchmark Index Performance')
hold off 
title('Portfolio Performance 2013 - 2015');

figure(2);
plotperform(trainData)

end