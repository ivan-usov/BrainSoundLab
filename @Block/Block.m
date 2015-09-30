classdef Block < handle
    
    properties % Basic block information
        name = char.empty;  % block file name
        path = char.empty;  % block file path
        
        nChannels           % total number of channels in the block
        nGroups             % total number of groups in the block
        
        nRep                % total number of repetitions
        selRep              % selected repetitions for processing
        
        nTotal              % total number of trials
        nTrials             % number of trials per one repetiton
    end
    
    properties
        stim % stimuli parameters (maximum length = 2)
        stimConditions
        stimTimings
        
        % Groups and filters
        group        
        filtStim
        filtSpikes
        
        spikeTimings_raw
        spikeTimings_sup
        
        snips
    end
    
    properties
        timeRasterMin = -0.2;    % min time in the raster plot (seconds)
        timeRasterMax = 0.8;     % max time in the raster plot (seconds)
        
        timeProcMin             % min processing time (seconds)
        timeProcMax             % max processing time (seconds)
        autoProcTime
        
        peakPos                 % psth peak latency (seconds)
        peakAmp                 % psth peak amplitude (spikes/second)
        
        spikesTimeRaster
        spikesTimeProc
        
        spontRateMean
        spontRateStd
        
        postStimRateMean
        postStimRateStd
        
        custom
    end
    
    properties (Transient) % Utility properties
        stim0 = struct(...
            'label', 'Number', ...
            'val', 1, ...
            'len', 1, ...
            'ind', []); % in case of sorting by trial number
        spikeTimings
        ts
        chan
        filtSpikesData
    end
    
    methods(Static)
        [ts, chan, snips, clustNum] = ...
            loadKlustaSpikeData(blockPath, blockName, nChannels);
    end
    
end

