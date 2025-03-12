%% by HD calculate doppler
function doppler=calculateDoppler(trackResults,currMeasSample,channelList,settings)

for channelNr = channelList 
    % measurment point location 
    for index = 1: length(trackResults(channelNr).absoluteSample)
        if(trackResults(channelNr).absoluteSample(index) > currMeasSample )
            break
        end 
    end
    index = index - 1;
    carrFreq=trackResults(channelNr).carrFreq(index);
    doppler(channelNr)=(carrFreq-settings.IF)*settings.c/1575.42e6; % m/s
end