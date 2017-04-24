%% Read in the data and set constants
clc;
clear all;
close all;

load('Data/IndexReturns.mat'); 
load('Data/ModelReturns.mat'); 

% Program Constants
nWeeks = size(ModelReturns, 1);
nModels = size(ModelReturns, 2);
windowSize = 12;
nYears = 12;
nWindows = nWeeks/windowSize;
 
 %% Calculate features
 
[features, windowAlpha] = calc_features(ModelReturns, IndexReturns, nWeeks, nWindows, windowSize, nModels); 

%% Calculate the reponse variable

% Set the minimum alpha per WEEK you would like to train the model on
weekMinAlpha = .01;
response = calc_response(windowAlpha, nWindows, nModels);

%% Divide into train and test

allData = [features, response];

trainData = allData(1:31, :);
trainPred = trainData(:, 1:30);
trainResp = trainData(:, 31:end);

testData = allData (32:end, :);
testPred = testData(:, 1:30);
testResp = testData(:, 31:end);
%% Initialize NN

hiddenLayerNodes = 50;
fractionVal = .25;
maxEpochs = 100;

net = patternnet(hiddenLayerNodes);
net.divideFcn = 'dividerand';
net.divideParam.valRatio = fractionVal;
net.divideParam.trainRatio = 1-fractionVal;
net.divideParam.testRatio = 0;
net.trainParam.epochs = maxEpochs; 

[net, tr] = train(net, transpose(trainPred), transpose(trainResp), 'useParallel','yes');
neuralNetPredictions = transpose(net(transpose(testPred)));

%% Calculate best model

for i = 1:length(neuralNetPredictions)
    [tempMax, bestModelIndex(i , 1)] = max(neuralNetPredictions(i, :));
end

%% Calculate Average Yearly Test Returns
fullModelReturns = 1 + ModelReturns;
fullIndexReturns = 1 + IndexReturns;

darkAlphaReturn = 1.00;
CZeSD_testRet = 1.00;
KP_SSD_testRet = 1.00;
L_SSD_testRet = 1.00;
LR_ASSD_testRet = 1.00;
MeanVar_testRet = 1.00;
RMZ_SSD_testRet = 1.00;
SP500_testRet = 1.00;

currentWindow = 1;
startTestWindow = 32;
startTestWeek = (startTestWindow-1) * windowSize + 1;

darkAlphaPortChoice = 1;

for i = startTestWeek:nWeeks - 12;
    CZeSD_testRet = CZeSD_testRet * fullModelReturns(i,1);
    KP_SSD_testRet = KP_SSD_testRet * fullModelReturns(i,2);
    L_SSD_testRet = L_SSD_testRet * fullModelReturns(i,3);
    LR_ASSD_testRet = LR_ASSD_testRet * fullModelReturns(i,4);
    MeanVar_testRet = MeanVar_testRet * fullModelReturns(i,5);
    RMZ_SSD_testRet = RMZ_SSD_testRet * fullModelReturns(i,6);
    SP500_testRet = SP500_testRet * fullIndexReturns(i, 1); 
    
    % Choose portfolio
    darkAlphaPortChoice = bestModelIndex(currentWindow, 1);
    darkAlphaReturn = darkAlphaReturn * fullModelReturns(i, darkAlphaPortChoice);    
    
    % Increment window
    if rem(i, windowSize) == 0
        currentWindow = currentWindow + 1;
    end
    
end

fprintf('Our models return was %.4f per year \n', nthroot(darkAlphaReturn, 3) - 1);
fprintf('Index return was %.4f per year \n', nthroot(SP500_testRet, 3) - 1);
fprintf('CZeSD return was %.4f per year \n', nthroot(CZeSD_testRet, 3) - 1);
fprintf('KP_SSD return was %.4f per year \n', nthroot(KP_SSD_testRet, 3) - 1);
fprintf('L_SSD return was %.4f per year \n', nthroot(L_SSD_testRet, 3) - 1);
fprintf('MeanVar return was %.4f per year \n', nthroot(MeanVar_testRet, 3) - 1);
fprintf('RMZ_SSD return was %.4f per year \n', nthroot(RMZ_SSD_testRet, 3) - 1);



