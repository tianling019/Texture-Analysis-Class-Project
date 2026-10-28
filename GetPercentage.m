function [Percentage] = GetPercentage(Image, X, Y)
% Get the percentage of tissue area
    BackgroundThrd = 5; % Set the background threshold here.
    ImageSize = X * Y;
    PixelCounter = 0;
    for i = 1:X
        for j = 1:Y
            if (Image(j,i)>=BackgroundThrd)
                PixelCounter = PixelCounter + 1;
            end
        end
    end
    Percentage = PixelCounter/ImageSize;
end

