function [ allReturns ] = calc_returns(ModelReturns, IndexReturns, bestModelIndex, testStartWindow, windowSize, nWeeks, plotIsOn)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% Push returns to 1 for in-loop multiplication
fullModelReturns = 1 + ModelReturns;
fullIndexReturns = 1 + IndexReturns;
currentWindow = 1;
startTestWeek = (testStartWindow-1) * windowSize + 1;
allReturns = ones(1, 8);

for i = startTestWeek:nWeeks - 12;
    
    % Update all stochastic model returns
    allReturns(1) = allReturns(1) * fullModelReturns(i,1);
    allReturns(2) = allReturns(2) * fullModelReturns(i,2);
    allReturns(3) = allReturns(3) * fullModelReturns(i,3);
    allReturns(4) = allReturns(4) * fullModelReturns(i,4);
    allReturns(5) = allReturns(5) * fullModelReturns(i,5);
    allReturns(6) = allReturns(6) * fullModelReturns(i,6);
    allReturns(7) = allReturns(7) * fullIndexReturns(i, 1); 
    
    % Choose portfolio and update our return
    darkAlphaPortChoice = bestModelIndex(currentWindow, 1);
    allReturns(8) = allReturns(8) * fullModelReturns(i, darkAlphaPortChoice);    
    
    % Increment window
    if rem(i, windowSize) == 0
        currentWindow = currentWindow + 1;
    end
    
end

end

