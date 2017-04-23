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
        windowRSquared(i,j) = max(0,1 - sum((ModelReturns(startWeek:endWeek, j)-IndexReturns(startWeek:endWeek)).^2)/sum((ModelReturns(startWeek:endWeek, j)-mean(ModelReturns(startWeek:endWeek, j))).^2));
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

allData = [predictors, response];


