%% Neural Network
clear all
close all
clc

%% Read Microsoft Excel spreadsheet file from the data base generated by Abaqus
filename = 'database.xlsx';
data(:,:) = xlsread(filename);
% Fetch the data of the force vector
for n =1:3960
    data4(:,n) =data3(1:45,2*n);
end

% for different thickness
for n = 1:792
    data5(:,n) = [0.3;data4(:,n)];
end

for n = 793:1584 
    data5(:,n) = [0.35;data4(:,n)];
end

for n = 1585:2376
    data5(:,n) = [0.4;data4(:,n)];
end

for n = 2377:3168
    data5(:,n) = [0.45;data4(:,n)];
end

for n = 3169:3960
    data5(:,n) = [0.5;data4(:,n)];
end

% ANN input
data5 = data5';
save('Ann_input.mat','data5')

% ANN output
load('ANN_output.mat')

% Ann_output0_3 = ANN_output(1:180,:);
% save('Ann_output0_3.mat','Ann_output0_3')


%% Solve an Input-Output Fitting problem with a Neural Network
x = data5';
t = ANN_output';

% Normalization
[xn,xs] = mapminmax(x);
[tn,ts] = mapminmax(t);

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainlm';  % Bayesian Regularization backpropagation.


% Create a Fitting Network
hiddenLayerSize =[50,50,50];
net = fitnet(hiddenLayerSize,trainFcn);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,xn,tn);%,'useGPU','yes','showResources','yes');

% Test the Network
yn = net(xn);
y = mapminmax('reverse',yn,ts);
e = gsubtract(t,y);
ee = e(3,:);
%performance = perform(net,t,y);

% View the Network


save('Ann.mat','net','ts','xs','e','y','t')

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotfit(net,x,t)


