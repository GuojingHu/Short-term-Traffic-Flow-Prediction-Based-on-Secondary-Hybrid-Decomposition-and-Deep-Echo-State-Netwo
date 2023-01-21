clear
tic

net = DeepESN();
net.Nr = 20;
net.Nl = 5;
net.spectral_radius = 0.8;
net.input_scaling = 0.1;
net.inter_scaling = 0.1;
net.leaking_rate = 0.9;
net.input_scaling_mode = 'bynorm';
net.bias = 1;
net.washout = 0;
net.readout_regularization = 0.00001;
net.initialize;
test_sum = 0;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMF1被WPD分解 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

input=readtable('/Users/guojinghu/Desktop/data_136616/volume_IMF1.csv');          
x_input=input.x;
wpt=wpdec(x_input,3,'db1');      %'wpdec'to decompose
% wavelet packet coefficients. 
cfs3_0=wprcoef(wpt,[3 0]);       %'wprcoef' to reconstruct
cfs3_1=wprcoef(wpt,[3 1]);  
cfs3_2=wprcoef(wpt,[3 2]);  
cfs3_3=wprcoef(wpt,[3 3]);  
cfs3_4=wprcoef(wpt,[3 4]);  
cfs3_5=wprcoef(wpt,[3 5]);  
cfs3_6=wprcoef(wpt,[3 6]);  
cfs3_7=wprcoef(wpt,[3 7]);  


myTables = {cfs3_0, cfs3_1, cfs3_2, cfs3_3, cfs3_4, cfs3_5, cfs3_6, cfs3_7}; 
for j= 1:length(myTables)
    data = transpose(myTables{j});
    
    input = data(:,1:(size(data,2)-1));  % 1 到 1018 列数据
    target = data(:,2:size(data,2));     % 2 到 1019 列数据
    numTrain = floor(0.7*numel(data));  

    [~,test_pred] = net.train_test(input,target,(1:numTrain),(numTrain+1:size(input,2)));
    test_sum = test_sum + test_pred;

end








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMF2 ~ IMF12 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 2:12
net.initialize;

data1 = readmatrix("/Users/guojinghu/Desktop/data_136616/volume_IMF"+string(i)+".csv");
data2 = data1(2:end,2);
data = transpose (data2);

% 
input = data(:,1:(size(data,2)-1));  % 1 到 1018 列数据
target = data(:,2:size(data,2));     % 2 到 1019 列数据
numTrain = floor(0.7*numel(data));  

[~,test_pred3] = net.train_test(input,target,(1:numTrain),(numTrain+1:size(input,2)));
test_sum = test_sum + test_pred3;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMF2 ~ IMF12 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% for i = 8:12
% net.initialize;
% 
% data1 = readmatrix("/Users/guojinghu/Desktop/Paper4_Time series prediction/data_136149_5min/volume_IMF"+string(i)+".csv");
% data2 = data1(:,2);
% data = transpose (data2);
% 
% % 
% input = data(:,1:(size(data,2)-1));  % 1 到 1018 列数据
% target = data(:,2:size(data,2));     % 2 到 1019 列数据
% numTrain = floor(0.8*numel(data));  
% 
% [~,test_pred3] = net.train_test(input,target,(1:numTrain),(numTrain+1:size(input,2)));
% test_sum = test_sum + test_pred3;
% end
% 










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 作图 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vol_data = readmatrix("/Users/guojinghu/Desktop/data_136616/data_136616_5min.csv");
%vol_data2 = vol_data1{:,2};
%vol_data  = transpose(vol_data2);
YTest = vol_data(numTrain+2:end); % 919 ~ 1019

% Evaluation Index
RMSE = sqrt(mean((test_sum-YTest).^2));
MAE = mean(abs(test_sum-YTest));
MAPE = mean(abs((test_sum-YTest)/YTest));


% Plot
figure(1)
plot(vol_data(1:numTrain))
hold on
idx = numTrain:(size(vol_data,2)-1);
plot(idx,[data(numTrain) test_sum],'.-')
hold off
xlabel("Test Time (5 minute)", 'FontSize',12)
ylabel("Volume (veh)", 'FontSize',12)
title("Volume Forecast by CEEMDAN, WPD and DeepESN")
legend(["Observed" "Forecast"])



figure(2)
subplot(4,1,1)
plot(YTest)
hold on
plot(test_sum,'.-')
hold off
legend(["Observed" "Forecast"])
%xlabel("Test Time (5 minute)")
ylabel("Volume (veh)", 'FontSize',12)
title("Volume Forecast by CEEMDAN, WPD and DeepESN")

subplot(4,1,2)
stem(test_sum-YTest)
ylim([-100 100])
%xlabel("Test Time (5 minute)")
ylabel("Error", 'FontSize',12)
title("MAE = " + MAE)

subplot(4,1,3)
stem(test_sum-YTest)
ylim([-100 100])
%xlabel("Test Time (5 minute)")
ylabel("Error", 'FontSize',12)
title("MAPE = " + MAPE)

subplot(4,1,4)
stem(test_sum-YTest)
ylim([-100 100])
xlabel("Test Time (5 minute)", 'FontSize',12)
ylabel("Error", 'FontSize',12)
title("RMSE = " + RMSE)




timeElapsed = toc;










