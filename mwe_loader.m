clear;
clc;

MarketReturns = load('weeklyReturnsData.mat');

DowJones = load('datasets/DowJones.mat');
FF49Industries = load('datasets/FF49Industries.mat');
FTSE100 = load('datasets/FTSE100.mat');
NASDAQ100 = load('datasets/NASDAQ100.mat');
NASDAQComp = load('datasets/NASDAQComp.mat');
SP500 = load('datasets/SP500.mat');

save('weeklyReturnsData.mat', 'DowJones', 'FF49Industries', 'FTSE100', 'NASDAQ100', 'NASDAQComp', 'SP500');
