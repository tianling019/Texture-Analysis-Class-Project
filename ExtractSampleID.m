%%
function outputSampleID = ExtractSampleID(cellFileName)
    strFileName = cell2str(cellFileName);
    startLocation = 5;
    endLocation = strfind(strFileName,'_');
    SampleID = strFileName(startLocation:endLocation(1)-1);
    outputSampleID = str2num(SampleID);
end