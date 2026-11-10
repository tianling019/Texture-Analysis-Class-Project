% Step 5: Margin/Sample Level Classification

% Clean workspace
%clear; close all; clc;

% Set decision fusion parameters
ProbLambda = 0.75;
DecisionLambda = 0.25;
ReverseProbLambda = 1 - ProbLambda;

% Select one sample
SampleID = 1; % change to 2 after running the first sample

DecisionMapFileName = strcat('LBP_SVM_Decision',num2str(SampleID),'.mat');
ProbMapFileName = strcat('LBP_SVM_Probability',num2str(SampleID),'.mat');
load(DecisionMapFileName);  % Load PatchPrediction
load(ProbMapFileName);  % Load PatchScore
MapHeight = size(PatchPrediction,1);
MapWidth = size(PatchPrediction,2);

ProbArray = reshape(PatchScore,[],1);
ProbArray = sort(ProbArray,'descend');
ProbArrayLength = nnz(ProbArray);

PatchSelection = zeros(ProbArrayLength,1);
for iterPatch = 1:ProbArrayLength
    TumorProb = ProbArray(iterPatch);
    if ((TumorProb>=ProbLambda)||(TumorProb<=ReverseProbLambda))
        PatchSelection(iterPatch)=1;    % Patch selected.
    end        
end
NumPatchSelection = sum(PatchSelection);
MeanTumorProb = 0;
MeanNormalProb = 0;
for iterPatch = 1:ProbArrayLength
    if (PatchSelection(iterPatch)==1)
        TumorProb = ProbArray(iterPatch);
        NormalProb = 1-ProbArray(iterPatch);
        MeanTumorProb = MeanTumorProb + TumorProb;
        MeanNormalProb = MeanNormalProb + NormalProb;
    end
end    
MeanTumorProb = MeanTumorProb/NumPatchSelection;
MeanNormalProb = MeanNormalProb/NumPatchSelection;
if (MeanTumorProb>=MeanNormalProb*DecisionLambda)    
    diagnosis = 1;
else
    diagnosis = 0;
end


% Display prediction
fprintf('Sample ID: %d\n', SampleID);
fprintf('Predicted diagnosis: %d\n', diagnosis);

if diagnosis == 1
    disp('Prediction: Tumor (Postive Margin)');
else
    disp('Prediction: Normal (Negative Margin)');
end
