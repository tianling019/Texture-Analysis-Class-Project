% Step 4 save the LBP feature based on patch location
clear; close all; clc;

% 1. Load your pre-trained model
load('MyPretrainedClassifier.mat'); % Must contain your model (e.g., ScoreCVSVMModel)
ScoreCVSVMModel = fitSVMPosterior(PatchClassifier);

% 2. Setup sample parameters
SampleID = 1;   
FeatureSelection = 3; % Choose LBP feature extraction

SampleFileName = strcat('S', num2str(SampleID), '.mat');
load(SampleFileName); % Contains 'PatchGrids'
Data3 = xlsread('LBP.xlsx');

% Input the image
SampleFileName = strcat(num2str(SampleID),'.jpg');
RGBImage = imread(SampleFileName);
PatchSizeX = 400; PatchSizeY = 400; 
% Calculate the patch grids.
[SizeY, SizeX, ~] = size(RGBImage);
NumX = floor(SizeX/PatchSizeX);
NumY = floor(SizeY/PatchSizeY);
% Initialize the outputs.
PatchGrids = zeros(NumY,NumX);
% Divide the whole sample image and calculate patch features.
for iterX = 1 : NumX
    for iterY = 1 : NumY
        StatX = (iterX - 1)*PatchSizeX + 1;
        EndX = iterX*PatchSizeX;
        StatY = (iterY - 1)*PatchSizeY + 1;
        EndY = iterY*PatchSizeY;
        PatchImage = RGBImage(StatY:EndY, StatX:EndX,:);
        AreaPercentage_R = GetPercentage(PatchImage(:,:,1), PatchSizeX, PatchSizeY);
        if ((AreaPercentage_R > 0.2))
            PatchGrids(iterY, iterX) = 1;   % Label as valid patch.
            [LBP_feature, NC_feature] = GetLBPFeature(PatchImage);
            % Initialize feature vectors
            LBP_vec_length = length(LBP_feature);
            LBP_Vector = zeros(NumY,NumX,LBP_vec_length);
            NC_Vector = zeros(NumY,NumX);
            LBP_Vector(iterY,iterX,:)=LBP_feature;
            NC_Vector(iterY,iterX)=NC_feature;
        end
    end
end
% Save patch grids.
PatchFileName=strcat('LBP',num2str(SampleID),'.mat');
save(PatchFileName,'LBP_Vector');

PatchFileName=strcat('NC',num2str(SampleID),'.mat');
save(PatchFileName,'NC_Vector');


CurrentImageGrids = PatchGrids;
[Size_Y, Size_X] = size(CurrentImageGrids);
% Compute the scaling boundaries based on this sample's patches
ScalingParameterMin = 0.0027;   
ScalingParameterMax = 0.9982;    % numbers from previous training samples
PatchPrediction = zeros(Size_Y, Size_X);
PatchScore = zeros(Size_Y, Size_X);
for iterX = 1 : Size_X
    for iterY = 1 : Size_Y
        if (CurrentImageGrids(iterY,iterX) == 1)
            % Extract features scaled matching THIS sample's true boundaries
            SinglePatchFeature = GetPatchFeature(SampleID, FeatureSelection, iterY, iterX, ScalingParameterMin, ScalingParameterMax);
            % Predict using your pre-trained model
            [class, score] = predict(ScoreCVSVMModel, SinglePatchFeature);
            
            PatchPrediction(iterY,iterX) = double(class);
            PatchScore(iterY,iterX) = score(2); % Posterior probability for tumor
        end
    end
end

% 5. Save the generated maps
DecisionMapFileName = strcat('LBP_SVM_Decision', num2str(SampleID), '.mat');
ProbMapFileName = strcat('LBP_SVM_Probability', num2str(SampleID), '.mat');
save(DecisionMapFileName, 'PatchPrediction');
save(ProbMapFileName, 'PatchScore');
     
%%
function SinglePatchFeature = GetPatchFeature(SampleID,FeatureSelection,iterY,iterX,ScalingParameterMin,ScalingParameterMax)
    % Load the sample data.  
    FileName = strcat('LBP',num2str(SampleID),'.mat');
    load(FileName,'LBP_Vector');
    Data3_ = LBP_Vector(iterY,iterX,:);
    Data3 = NaN(1,size(Data3_,3));
    Data3(:) = Data3_(1,:);    
    Data3_ = (Data3-ScalingParameterMin(1))/(ScalingParameterMax(1)-ScalingParameterMin(1));
    
    % Feature selection
    % 1:GLCM; 2:Gabor; 3:LBP; 4:Fractal measures;
    % 5:all; 6: N/C; 7:Image entropy; 
    switch (FeatureSelection)
        case (1)
            Data = Data1_;
        case (2)
            Data = Data2_;
        case (3)
            Data = Data3_;
        case (4)
            Data = [Data4_ Data5_];
        case (5)
            Data = [Data3_ Data6_];
        case (6)
            Data = Data6_;
        case (7)
            Data = Data7_;
    end
    SinglePatchFeature = Data;
end