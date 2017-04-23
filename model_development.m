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


 