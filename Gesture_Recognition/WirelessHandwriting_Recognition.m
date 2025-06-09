%% Load images and test

%% Load
clc; clear; close all;
net = load("PretrainedModel.mat").net;
images = load('TestingSet.mat').images;
labels = images.response;
testImgs = images.input;
imgNum = length(testImgs);

%% Test
idx = 20;%  change this parameter to check another repetition
figure;hold on;
for i = 1:imgNum
    X = testImgs{i};
    Y(i) = classify(net, X);
    if mod(i, 25) == idx
        subplot(2,5,floor(i/50)+1);
        imshow(X);
        text(10, 10, num2str(double(Y(i))-1));
    end
end
sgtitle('Recognition Example');

%% Result
confusion = confusionmat(labels, Y);
acc = sum(diag(confusion), 'all')/sum(confusion, 'all');
confusion = confusion./sum(confusion, 2);

figure('Color', [1 1 1]);
chart = heatmap(confusion*100);
chart.ColorbarVisible = 'off';
chart.CellLabelFormat = '%0.0f';
chart.XDisplayLabels = [0 1 2 3 4 5 6 7 8 9];
chart.YDisplayLabels = [0 1 2 3 4 5 6 7 8 9]';
chart.XLabel = 'Predicted label';
chart.YLabel = 'True label';
chart.Title = sprintf('Accuracy: %.1f%%', acc*100);
chart.FontSize = 14;
chart.FontName = 'Times New Roman';


