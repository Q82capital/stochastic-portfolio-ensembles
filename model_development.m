%% Read in the data
clc;
clear all;
close all;

load('Data/IndexReturns.mat'); 
load('Data/ModelReturns.mat'); 

% Extract Constants
nWeeks = size(ModelReturns, 1);
nModels = size(ModelReturns, 2);
windowSize = 12;
nYears = 12;
nWindows = nWeeks/windowSize;

%% Calculate Scoring Predictors
holisticIndexYearlyReturn = nthroot(prod(IndexReturns + 1), nYears);
holisticModelYearlyReturn = zeros(1, nModels);
 for i = 1:nModels
    holisticModelYearlyReturn(1, i) = nthroot(prod(ModelReturns(:,i) + 1), nYears);
 end
 
%% Calculate Sharpe 

% Assumed constant 3% risk-free return on cash (see [Bridgewater] )
weeklyCashReturn = nthroot(1.03, 52) - 1;
RiskFreeReturns = ones(nWeeks, 1) * weeklyCashReturn;

for i = 1:nWindows
    startWeek = (i-1) * windowSize + 1;
    endWeek = startWeek + 11;
    windowSharpe(i, :) = sharpe(ModelReturns(startWeek:endWeek, :), RiskFreeReturns(startWeek:endWeek, :));
end

%% Calculate Alpha

% NOTE: using Jensen index 
for i = 1:nWindows
    startWeek = (i-1) * windowSize + 1;
    endWeek = startWeek + 11;
    windowAlpha(i, :) = portalpha(ModelReturns(startWeek:endWeek, :), IndexReturns(startWeek:endWeek, :), RiskFreeReturns(startWeek:endWeek, :), 'capm');
end

%% Calculate S.D. 

for i = 1:nWindows
    startWeek = (i-1) * windowSize + 1;
    endWeek = startWeek + 11;
    windowStd(i, :) = std(ModelReturns(startWeek:endWeek, :));
end

 %% Calculate R-Squared
windowRSquared = zeros(nWindows, nModels);

for i = 1:nWindows
    startWeek = (i-1) * windowSize + 1;
    endWeek = startWeek + 11;
    
    for j = 1:nModels
        windowRSquared(i,j) = max(0,1 - sum((IndexReturns(startWeek:endWeek)-ModelReturns(startWeek:endWeek, j)).^2)/sum((IndexReturns(startWeek:endWeek)-mean(IndexReturns(startWeek:endWeek))).^2));
    end
    
end

%% Calculate Beta
windowBeta = zeros(nWindows, nModels);

for i = 1:nWindows
    startWeek = (i-1) * windowSize + 1;
    endWeek = startWeek + 11;
    
    for j = 1:nModels
           calcRegStats = regstats(ModelReturns(startWeek:endWeek, j), IndexReturns(startWeek:endWeek));
           volBeta = calcRegStats.beta;
           windowBeta(i,j) = volBeta(2, 1);
    end
    
end

%% Put together all predictors and and reponses

predictors = [windowAlpha, windowBeta, windowStd, windowRSquared, windowSharpe];
predictors = predictors(1:length(predictors)-1, :); % remove last row

for i = 1:nWindows-1
    response(i, :) = windowAlpha(i+1,:);
end

%% Divide into train and test

allData = [predictors, response];

trainData = allData(1:31, :);
trainPred = trainData(:, 1:30);
trainResp = trainData(:, 31:end);

testData = allData (32:end, :);
testPred = testData(:, 1:30);
testResp = testData(:, 31:end);
%% Initialize NN

winnerCount = 0;
for i = 1:100

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
% 
% disp(bestModelIndex);


if nthroot(darkAlphaReturn, 3) - 1 > .20
    disp(bestModelIndex);
    winnerCount = winnerCount + 1;
end

end 

disp('We beat all startegies AND index %.2f percent of the time', winnerCount);


