% Step 3: Cross Validation on patches

% Clean workspace
clear all; close all; clc; 

load Patches_Labels.mat;
text_data = Patches_Labels(2:435,1);
cat1 = text_data; 
cat1 = categorical(cat1);
cat2 = Patches_Labels(2:435,2);
cat2 = categorical(cat2);

% Properly initialize CatLabel
CatLabel = zeros(size(cat2));
CatLabel(cat2=="T") = 1;
CatLabel(cat2=="N") = 0;

% Load the sample data.
Data1 = xlsread("LBP.xlsx");
Data2 = xlsread("NC.xlsx");
Data = [Data1 Data2];

% Create indices for the 5-fold cross-validation.
K_fold = 5;
rng('default'); % For reproducibility
indices = crossvalind('Kfold', length(CatLabel), K_fold); % Properly generates 1 to 5 split indices

% Initialize an object to measure the performance of the classifier.
cp = classperf(CatLabel);
ROC_AUC = zeros(K_fold,1);

% Pre-allocate performance metrics
accuracy = zeros(K_fold,1);
sensitivity = zeros(K_fold,1);
specificity = zeros(K_fold,1);

figure; % Open a figure for ROC plotting
% Perform the classification
for i = 1: K_fold
    test = (indices == i);
    train = ~test;
    
    mdl = fitcsvm(Data(train,:),CatLabel(train,:),'BoxConstraint',20,'KernelFunction','polynomial');
    [class, score] = predict(mdl,Data(test,:));
    classperf(cp,class,test);
    
    % ROC curve (changed positive class marker from '1' to numeric 1)
    [X,Y,T,AUC] = perfcurve(CatLabel(test,:),score(:,2), 1);
    ROC_AUC(i) = AUC;
    
    plot(X,Y)
    xlabel('False positive rate')
    ylabel('True positive rate')
    title('ROC for Classification by SVM');
    hold on
    
    % Compute confusion matrix elements
    trueLabels = CatLabel(test,:);
    predLabels = class;
    
    TP = sum((trueLabels == 1) & (predLabels == 1));
    TN = sum((trueLabels == 0) & (predLabels == 0));
    FP = sum((trueLabels == 0) & (predLabels == 1));
    FN = sum((trueLabels == 1) & (predLabels == 0));
    
    % Save metrics for this fold
    accuracy(i) = (TP + TN) / (TP + TN + FP + FN);
    sensitivity(i) = TP / (TP + FN);
    specificity(i) = TN / (TN + FP);
end

fprintf('K-Fold Cross Validation (k=%d) with Support Vector Machines (BoxConstraint=20)\n', K_fold)
fprintf('Accuracy: %f ± %f\n', mean(accuracy), std(accuracy));
fprintf('Sensitivity: %f ± %f\n', mean(sensitivity), std(sensitivity));
fprintf('Specificity: %f ± %f\n\n', mean(specificity), std(specificity));

Mean_AUC = mean(ROC_AUC);
fprintf('Mean AUC: %f ± %f\n', mean(ROC_AUC), std(ROC_AUC));
