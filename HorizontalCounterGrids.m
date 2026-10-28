function DivisionResults = HorizontalCounterGrids(Gray_Image, Scale, HorizontalScale)
    Scale_real = double(Scale);
    HorizontalScale_real = double(HorizontalScale);
    ImageSize = size(Gray_Image,2);
    NumGrids = floor(ImageSize/Scale_real);
    DivisionResults = zeros(NumGrids);
    for i = 1:NumGrids
        for j = 1:NumGrids
            ImageGrid = Gray_Image((i-1)*Scale+1:i*Scale, (j-1)*Scale+1:j*Scale);
            MaxInsensity = max(ImageGrid,[],'all');
            MinIntesntiy = min(ImageGrid,[],'all');
            HorizontalCounter = floor((MaxInsensity -MinIntesntiy)/HorizontalScale_real) + 1;
            DivisionResults(i,j) = HorizontalCounter;
        end
    end
end
