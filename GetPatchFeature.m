function SinglePatchFeature = GetPatchFeature(SampleID,FeatureSelection,iterY,iterX,ScalingParameterMin,ScalingParameterMax)
    % Load the sample data.
    % FileName = strcat('GLCM',num2str(SampleID),'.mat');
    % load(FileName,'GLCM_Vector');
    % Data1_ = GLCM_Vector(iterY,iterX,:);
    % Data1 = NaN(1,size(Data1_,3));
    % Data1(:) = Data1_(1,:);
    % 
    % FileName = strcat('Gabor',num2str(SampleID),'.mat');
    % load(FileName,'Gabor_Vector');
    % Data2_ = Gabor_Vector(iterY,iterX,:);
    % Data2 = NaN(1,size(Data2_,3));
    % Data2(:) = Data2_(1,:);    
    
    % FileName = strcat('LBP',num2str(SampleID),'.mat');
    FileName = strcat('LBP',num2str(SampleID),'.mat');
    load(FileName,'LBP_Vector');
    Data3_ = LBP_Vector(iterY,iterX,:);
    Data3 = NaN(1,size(Data3_,3));
    Data3(:) = Data3_(1,:);    
    
    % FileName = strcat('Fractal',num2str(SampleID),'.mat');
    % load(FileName,'Fractal_Vector');
    % Data4 = Fractal_Vector(iterY,iterX);
    % 
    % FileName = strcat('Lacunarity',num2str(SampleID),'.mat');
    % load(FileName,'Lacunarity_Vector');
    % Data5 = Lacunarity_Vector(iterY,iterX);
    
    % FileName = strcat('NC',num2str(SampleID),'.mat');
    % FileName = strcat('NC',num2str(SampleID),'.mat');
    % load(FileName,'NC_Vector');
    % Data6 = NC_Vector(iterY,iterX);
    
    % FileName = strcat('Entropy',num2str(SampleID),'.mat');
    % load(FileName,'Entropy_Vector');
    % Data7 = Entropy_Vector(iterY,iterX);
    
    % Feature scaling
    % Data1_ = (Data1-ScalingParameterMin(1))/(ScalingParameterMax(1)-ScalingParameterMin(1));
    % Data2_ = (Data2-ScalingParameterMin(2))/(ScalingParameterMax(2)-ScalingParameterMin(2));
    Data3_ = (Data3-ScalingParameterMin(1))/(ScalingParameterMax(1)-ScalingParameterMin(1));
    % Data4_ = (Data4-ScalingParameterMin(4))/(ScalingParameterMax(4)-ScalingParameterMin(4));
    % Data5_ = (Data5-ScalingParameterMin(5))/(ScalingParameterMax(5)-ScalingParameterMin(5));
    % Data6_ = (Data6-ScalingParameterMin(2))/(ScalingParameterMax(2)-ScalingParameterMin(2));
    % Data7_ = (Data7-ScalingParameterMin(7))/(ScalingParameterMax(7)-ScalingParameterMin(7));
    
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