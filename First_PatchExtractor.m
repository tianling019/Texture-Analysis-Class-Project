% Project 2 - Texture Analysis
% The code is to classify the MUSE images and show the predictions
% Author: Tongtong Lu (revised by Tianling Niu); Date: Oct 2026

clear all; close all; clc
SampleID = [1];
SampleNum = numel(SampleID);

% Patch size.
PatchSizeX = 400;
PatchSizeY = 400;

% Generate patches for all samples.
for IterSample = 1:SampleNum
    % Input the image
    SampleFileName = strcat(num2str(SampleID(IterSample)),'.jpg');
    RGBImage = imread(SampleFileName);
    % Calculate the patch grids.
    [SizeY, SizeX, ~] = size(RGBImage);
    NumX = floor(SizeX/PatchSizeX);
    NumY = floor(SizeY/PatchSizeY);
    PatchCounter = 0; % File name start number - 1.
    % Initialize the outputs.
    PatchGrids = zeros(NumY,NumX);
    % Divide the whole sample image and calculate patch features.
    for iterX = 1 : NumX
        for iterY = 1 : NumY
            StatX = (iterX - 1)*PatchSizeX + 1;
            EndX = iterX*PatchSizeX;
            StatY = (iterY - 1)*PatchSizeY + 1;
            EndY = iterY*PatchSizeY;
            PatchImage = RGBImage(StatY:EndY, StatX:EndX,:);    % Patch image.
            AreaPercentage_R = GetPercentage(double(PatchImage(:,:,1)), PatchSizeX, PatchSizeY);
            if ((AreaPercentage_R > 0.8))   % Set the area threshold here empirically.
                PatchGrids(iterY, iterX) = 1;   % Label as valid patch.
                PatchCounter = PatchCounter + 1;
                PatchFileName = "P" + SampleNum + "_" + num2str(PatchCounter) +".tif";
                imwrite(PatchImage,PatchFileName);
            end
        end
    end
    % Save patch grids.
    PatchFileName=strcat('S',num2str(SampleID(IterSample)),'.mat');
    save(PatchFileName,'PatchGrids');
end

PatchCounter
