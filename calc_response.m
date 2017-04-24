function [response] = calc_response(windowAlpha, nWindows, nModels)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

response = zeros(nWindows-1, nModels);

for i = 1:nWindows-1
    response(i, :) = windowAlpha(i+1,:);
end

end

