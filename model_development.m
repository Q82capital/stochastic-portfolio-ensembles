%% Read in the data
clc;
clear all;
close all;

Markets = load('Data/Markets.mat');
Models = load('Data/Models.mat');

%% Graph Model Returns
figure(1);
hold on;
plot(Models.NASDAQ100.CZeSD.OSReturns);
plot(Models.NASDAQ100.KP_SSD.OSReturns);
plot(Models.NASDAQ100.L_SSD.OSReturns);
plot(Models.NASDAQ100.LR_ASSD.OSReturns);
plot(Models.NASDAQ100.MeanVar.OSReturns);
plot(Models.NASDAQ100.RMZ_SSD.OSReturns);
plot(Models.NASDAQ100.OSIndexReturns, '+');
hold off
%% Calculate Weights
clc;

CZeSD = transpose(Models.NASDAQ100.CZeSD.OptPort);
KP_SSD = transpose(Models.NASDAQ100.KP_SSD.OptPort);
L_SSD = transpose(Models.NASDAQ100.L_SSD.OptPort);
LR_ASSD = transpose(Models.NASDAQ100.LR_ASSD.OptPort);
MeanVar = transpose(Models.NASDAQ100.MeanVar.OptPort);
RMZ_SSD = transpose(Models.NASDAQ100.RMZ_SSD.OptPort);

allModelWeights = [CZeSD, KP_SSD, L_SSD, LR_ASSD, MeanVar, RMZ_SSD];

%% Calculate Best Performer
models = fieldnames(Models.NASDAQ100);

% Calculate performance for each strategry
for i = 1:length(models)-1
    model = models{i};
    
    for window = 1:(floor(length(Models.NASDAQ100.(model).OSReturns)/12))
        performance(window, i) = mean(Models.NASDAQ100.(model).OSReturns(window : window + 12, 1));
    end
        
end

for week = 1:length(performance)
    weekly_perf = performance(week, :);
    [max_return, max_i] = max(weekly_perf);
    best_model(week, 1) = max_i;
end

%% Create final output
allModelWeights = allModelWeights(1:45, :); % Remove excess incomplete window
finalOutput = [allModelWeights, best_model];



    
