%%
%%
function outputSamplePos = ReverseSamplePos(PatchSampleID,SampleID)
    SampleNum = length(SampleID);
    for i=1:SampleNum
        if (SampleID(i)==PatchSampleID)
            outputSamplePos = i;
        end
    end
end
