% Step 2: Generate the LBP feature and N/C ratio

clear;
close all;

% Input dataset
SampleID = 1;

FileName = sprintf('Patches_Labels%d.mat', SampleID);
Data = load(FileName);
FieldName = sprintf('Patches_Labels%d', SampleID);
FileNameList = Data.(FieldName);
FileNameList(1,:) = [];
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
  
% Output and save LBP in both Excel and MAT files
PatchFileName = sprintf('LBP_%d.mat', SampleID);
save(PatchFileName, 'LBP_Vector');

ExcelFileName = sprintf('LBP_%d.xlsx', SampleID);
xlswrite(ExcelFileName, LBP_Vector);

% Output and save NC in both Excel and MAT files
PatchFileName = sprintf('NC_%d.mat', SampleID);
save(PatchFileName, 'NC_Vector');

ExcelFileName = sprintf('NC_%d.xlsx', SampleID);
xlswrite(ExcelFileName, NC_Vector);

