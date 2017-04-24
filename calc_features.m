function [ features, windowAlpha ] = calc_features( ModelReturns, IndexReturns, nWeeks, nWindows, windowSize, nModels )
% Calculate all predictors for the model
%   Detailed explanation goes here

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

features = [windowAlpha, windowBeta, windowStd, windowRSquared, windowSharpe];
features = features(1:end-1, :); % remove last row

end

