% Step 2: Generate the LBP feature and N/C ratio

clear;
close all;

% Input dataset
load Patches_Labels.mat; FileNameList = Patches_Labels(2:435,1); %delete the headers
Num_patch = length(FileNameList);

% Initialize output
List = zeros(Num_patch, 10); % Size is calculated with Cell Size.

NumPoints = 12;
Radi = 3;
List_counter = 0;

% Generate patches for all samples.
FeatureVecIniFlag = 1;  % Feature vector initialization flag.
SampleFeatureVecIniFlag = 1;

for i=1 : Num_patch
    FileName = string(FileNameList(i));
    RGB_Image = imread(FileName);
   
    [GLCM_feature, Gabor_feature, LBP_feature, Fractal_feature, Lacunarity_feature, ...
    NC_feature, ImageEntropy] = GetNewPatchFeature(RGB_Image);

    if (FeatureVecIniFlag==1)
        LBP_vec_length = length(LBP_feature);
        FeatureVecIniFlag = 0;
    end
    if (SampleFeatureVecIniFlag==1)
        LBP_Vector = zeros(Num_patch,LBP_vec_length);
        NC_Vector = zeros(Num_patch,1);
        SampleFeatureVecIniFlag = 0;
    end

    LBP_Vector(i,:)=LBP_feature;
    NC_Vector(i)=NC_feature;
end
  
% Output and save LBP in both excel and mat files
PatchFileName='LBP.mat';
save(PatchFileName,'LBP_Vector');
xlswrite("LBP.xlsx", LBP_Vector);

% Output and save NC in both excel and mat files
PatchFileName='NC.mat';
save(PatchFileName,'NC_Vector');
xlswrite("NC.xlsx", NC_Vector);

