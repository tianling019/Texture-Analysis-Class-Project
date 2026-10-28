function [scaledVec, minValue, maxValue]  = FeatureScaling(FeatureVec,TrainLabel)
    % Using Train set for scaling to avoid data leakage.
    %{
    DataSize = length(TrainLabel);
    FeatureWidth = size(FeatureVec,2);
    TrainSize = sum(TrainLabel);
    TrainFeatureVec = zeros(TrainSize,FeatureWidth);
    TrainFeatureVecPoint = 1;
    for i = 1:DataSize
        if (TrainLabel(i)==1)
            TrainFeatureVec(TrainFeatureVecPoint,:) = FeatureVec(i,:);
            TrainFeatureVecPoint = TrainFeatureVecPoint + 1;
        end
    end
    %}
    TrainFeatureVec = FeatureVec(TrainLabel==1,:);
    
    minValue = min(TrainFeatureVec,[],'all');
    maxValue = max(TrainFeatureVec,[],'all');
    % Apply the scaling to the full data set.
    scaledVec = (FeatureVec-minValue)/(maxValue-minValue);
end
