% Step 5: Margin/Sample Level Classification

% Clean workspace
clear; close all; clc;

% Set decision fusion parameters
ProbLambda = 0.75;
DecisionLambda = 0.25;
ReverseProbLambda = 1 - ProbLambda;

% Select one sample
SampleLabel = 1;  % Ground-truth label: 1 = tumor, 0 = normal
SampleID = 1;

% Load decision and probability maps
DecisionMapFileName = strcat( ...
    'LBP_SVM_Decision', num2str(SampleID), '.mat');
ProbMapFileName = strcat( ...
    'LBP_SVM_Probability', num2str(SampleID), '.mat');

load(DecisionMapFileName);  % Load PatchPrediction
load(ProbMapFileName);      % Load PatchScore

MapHeight = size(PatchPrediction, 1);
MapWidth = size(PatchPrediction, 2);

% Process probability map
ProbArray = reshape(PatchScore, [], 1);
ProbArray = sort(ProbArray, 'descend');
ProbArrayLength = nnz(ProbArray);

PatchSelection = zeros(ProbArrayLength, 1);

for iterPatch = 1:ProbArrayLength
    TumorProb = ProbArray(iterPatch);

    if (TumorProb >= ProbLambda) || ...
       (TumorProb <= ReverseProbLambda)
        PatchSelection(iterPatch) = 1;
    end
end

NumPatchSelection = sum(PatchSelection);

MeanTumorProb = 0;
MeanNormalProb = 0;

for iterPatch = 1:ProbArrayLength
    if PatchSelection(iterPatch) == 1
        TumorProb = ProbArray(iterPatch);
        NormalProb = 1 - ProbArray(iterPatch);

        MeanTumorProb = MeanTumorProb + TumorProb;
        MeanNormalProb = MeanNormalProb + NormalProb;
    end
end

% Calculate mean probabilities
if NumPatchSelection > 0
    MeanTumorProb = MeanTumorProb / NumPatchSelection;
    MeanNormalProb = MeanNormalProb / NumPatchSelection;
else
    error('No patches were selected for decision fusion.');
end

% Make final prediction
if MeanTumorProb >= MeanNormalProb * DecisionLambda
    diagnosis = 1;
else
    diagnosis = 0;
end

% Display prediction
fprintf('Sample ID: %d\n', SampleID);
fprintf('Ground-truth label: %d\n', SampleLabel);
fprintf('Mean tumor probability: %.4f\n', MeanTumorProb);
fprintf('Mean normal probability: %.4f\n', MeanNormalProb);
fprintf('Predicted diagnosis: %d\n', diagnosis);

if diagnosis == 1
    disp('Prediction: Tumor');
else
    disp('Prediction: Normal');
end

% Evaluate this single sample
if SampleLabel == 1 && diagnosis == 1
    disp('Result: True Positive');
elseif SampleLabel == 1 && diagnosis == 0
    disp('Result: False Negative');
elseif SampleLabel == 0 && diagnosis == 0
    disp('Result: True Negative');
else
    disp('Result: False Positive');
end