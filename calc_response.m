function [response, targetHits] = calc_response(windowAlpha, targetAlpha, nWindows, nModels)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% Find which models hit the alpha target
targetHits = zeros(nWindows-1, nModels);
response = zeros(nWindows-1, nModels);

for i = 1:nWindows-1
    for j = 1:nModels
        if windowAlpha(i,j) > targetAlpha
            targetHits(i,j) = 1;
        else
            targetHits(i,j) = 0;
        end
    end
    
    % Don't modify target hits (will be returned and used later)
    response(i,:) = targetHits(i,:);
    
    % Make sure at least one model is selected
    if sum(response(i,:)) == 0
        [~, maxIndex] = max(windowAlpha(i,:));
        response(i, maxIndex) = 1;
    end
    
    % Normalize to one (for propabilistic interpretation)
    response(i,:) = response(i,:)/sum(response(i,:));
        
end

    
end

