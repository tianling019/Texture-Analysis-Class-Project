function [GLCM_feature, Gabor_feature, LBP_feature, Fractal_feature, Lacunarity_feature, ...
          NC_feature, ImageEntropy] = GetNewPatchFeature(PatchImage)
    % Select R channel.
    RedImage = PatchImage(:,:,1);
    % Filtering
    RedImage = wiener2(RedImage, [3 3]);
    % Intensity normalization
    [counts, ~] = imhist(RedImage);
    Detect_threshold = 10; % Set 10 counts as the brightest/darkest detection threshold.
    Max = 257;
    intensity_sum =0;
    while (intensity_sum < Detect_threshold) 
        Max = Max - 1;
        intensity_sum = intensity_sum + counts(Max);
    end
    Min = 0;
    intensity_sum =0;
    while (intensity_sum < Detect_threshold) 
        Min = Min + 1;
        intensity_sum = intensity_sum + counts(Min);
    end
    Inorm = 255/(Max - Min) * (RedImage - Min); % Intensity normalization.
    Ieq = adapthisteq(RedImage);    % Histogram equalization.
    
    % GLCM
    % Calculate GLCM parameters
    NumLevel = 16;
    Distance = 3;    
    % 0 deg.
    GLCM = graycomatrix (Inorm,'offset',[0 Distance],'NumLevels',NumLevel,'Symmetric', true);
    % By default, graycomatrix calculates the GLCM based on horizontal proximity of the pixels: [0 1]. 
    stats1 = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
    % 45 deg.
    GLCM = graycomatrix (Inorm,'offset',[-Distance Distance],'NumLevels',NumLevel, 'Symmetric', true);
    stats2 = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
    % 90 deg.
    GLCM = graycomatrix (Inorm,'offset',[-Distance 0],'NumLevels',NumLevel, 'Symmetric', true);
    stats3 = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
    % 135 deg.
    GLCM = graycomatrix (Inorm,'offset',[-Distance -Distance],'NumLevels',NumLevel, 'Symmetric', true);
    stats4 = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
    % Form GLCM feature
    GLCM_feature = [stats1.Contrast stats1.Correlation stats1.Energy stats1.Homogeneity...
                    stats2.Contrast stats2.Correlation stats2.Energy stats2.Homogeneity...
                    stats3.Contrast stats3.Correlation stats3.Energy stats3.Homogeneity...
                    stats4.Contrast stats4.Correlation stats4.Energy stats4.Homogeneity...
                    ];
                
    % Gabor
    gaborArray = gabor(2:1:5,0:45:135);
    gaborMag = imgaborfilt(Inorm,gaborArray);
    featureVector_long = mean(reshape(gaborMag,[], size(gaborMag,3)));  
    % Long Feature normalization
    featureVector_long = bsxfun(@minus, featureVector_long, mean(featureVector_long));
    featureVector_long = bsxfun(@rdivide,featureVector_long,std(featureVector_long));    
    Gabor_feature = featureVector_long;
    
    % LBP
    NumPoints = 12;
    Radi = 3;
    LBP_value = extractLBPFeatures(Inorm,'NumNeighbors',NumPoints,'Radius',Radi,'Upright',false);
    LBP_feature = LBP_value;
    
    % Fractal
    % Calculate fractal dimension by differential box counting method
    ScaleSizeArray = [4 8 16 32 64 128];
    ScaleSizeLength = size(ScaleSizeArray,2);
    CounterResults = zeros(ScaleSizeLength, 1);
    ImageSize = size(Inorm,2);
    ImageSize = double(ImageSize);
    for j = 1:ScaleSizeLength
        Scale = ScaleSizeArray(j);
        Scale_real = double(Scale);
        HorizontalScale = floor(255*Scale_real/ImageSize);
        DivisionResults = HorizontalCounterGrids(Inorm, Scale, HorizontalScale);
        CounterResults(j) = sum(DivisionResults,'all');
    end
    % Calculate fractal dimension
    InNr = log(CounterResults);
    In1r = log(ImageSize./ScaleSizeArray);
    linear_model = polyfit(In1r,InNr',1);
    fractal_dimension = linear_model(1);
    Fractal_feature = fractal_dimension;
    
    % Lacunarity
    % Otsu Segmentation
    level = graythresh(Ieq);
    BW = imbinarize(Ieq, level*1);
    % Segmentation
    length = size(Ieq, 1);
    width = size(Ieq, 2);
    Intensity_thrd = 115; % Set the drak threshold here.
    Seg_figure = Ieq;
    for k = 1 : length
        for j = 1 : width
            if ((Inorm(k,j)>=Intensity_thrd)&&(BW(k,j)==1))
                Seg_figure(k,j) = 1;
            else
                Seg_figure(k,j) = 0;
            end
        end
    end
    Seg_figure = logical(Seg_figure);
    % Calculate lacunarity
    glBoxSize = 3;  % gliding box size:3, 5, 7, 9, 11, 13
    glBox = zeros(glBoxSize);
    newLength = length-glBoxSize+1;
    newWidth = width-glBoxSize+1;
    glidedBoxes = zeros(newLength, newWidth);
    % Generate gliding boxes.
    for iterLength = 1:newLength
        for iterWidth = 1:newWidth
            glBox = Seg_figure(iterLength:iterLength+glBoxSize-1, iterWidth:iterWidth+glBoxSize-1);
            FillCounter = 0;
            for iterBox1 = 1:glBoxSize
                for iterBox2 = 1:glBoxSize
                    if (glBox(iterBox1,iterBox2)==1)
                        FillCounter = FillCounter + 1;
                    end
                end
            end
            glidedBoxes(iterLength,iterWidth) = FillCounter;
        end
    end
    lineArrayBoxes = reshape(glidedBoxes(:,:),[],1);
    meanBoxes = mean(lineArrayBoxes);
    varBoxes = var(lineArrayBoxes);
    lac_2 = varBoxes/meanBoxes^2 + 1;
    Lacunarity_feature = lac_2;
    
    % N/C
    counter = 0;
    for k1 = 1 : length
        for k2 = 1 : width
            if (Seg_figure(k1, k2)==1)
                counter = counter + 1;
            end
        end
    end    
    nc_ratio = counter/(length*width);
    NC_feature = nc_ratio; 
    
    % Image entropy
    ImageEntropy = entropy(Inorm);
end
