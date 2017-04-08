clc;
clear;

%% Read in data from files
DowJones = load('datasets/DowJones.mat');
FF49Industries = load('datasets/FF49Industries.mat');
FTSE100 = load('datasets/FTSE100.mat');
NASDAQ100 = load('datasets/NASDAQ100.mat');
NASDAQComp = load('datasets/NASDAQComp.mat');
SP500 = load('datasets/SP500.mat');

save('weeklyReturnsData.mat', 'DowJones', 'FF49Industries', 'FTSE100', 'NASDAQ100', 'NASDAQComp', 'SP500'); 

%% Plot each market asset returns
figure(1);
suptitle('Market Assets Returns')

subplot(2,3,1);
plot(DowJones.Assets_Returns(:,1))
title('Dow Jones');

subplot(2,3,2);
plot(FF49Industries.Assets_Returns(:,1));
title('FF49 Industries');

subplot(2,3,3);
plot(FTSE100.Assets_Returns(:,1));
title('FTSE 100');

subplot(2,3,4);
plot(NASDAQ100.Assets_Returns(:,1));
title('NASDAQ 100');

subplot(2,3,5);
plot(NASDAQComp.Assets_Returns(:,1));
title('NASDAQ Comp');

subplot(2,3,6);
plot(SP500.Assets_Returns(:,1));
title('SP500');

%% Index returns
figure(2);
suptitle('Market Index Returns')

subplot(2,3,1);
plot(DowJones.Index_Returns)
title('Dow Jones');

subplot(2,3,2);
plot(FF49Industries.Index_Returns);
title('FF49 Industries');

subplot(2,3,3);
plot(FTSE100.Index_Returns);
title('FTSE 100');

subplot(2,3,4);
plot(NASDAQ100.Index_Returns);
title('NASDAQ 100');

subplot(2,3,5);
plot(NASDAQComp.Index_Returns);
title('NASDAQ Comp');

subplot(2,3,6);
plot(SP500.Index_Returns);
title('SP500');

%% FF49 Asset Allocation
CZeSD_FF49_reb = load('solutions\FF49Industries\OptPortfolios_CZeSD_FF49Industries');
CZeSD_FF49_reb = CZeSD_FF49_reb.temp_mat;

CZeSD_FF49_list = load('solutions\FF49Industries\OutofSamplePortReturns_CZeSD_FF49Industries_List');
CZeSD_FF49_list = CZeSD_FF49_list.temp_mat;

CZeSD_FF49_mat = load('solutions\FF49Industries\OutofSamplePortReturns_CZeSD_FF49Industries_Matr');
CZeSD_FF49_mat = CZeSD_FF49_mat.temp_mat;