function processData(this, token, group, chan)
% Parse input
if nargin < 2 || 4 < nargin
    error('Block:processData', 'Invalid number of input arguments.');
end
if nargin < 4
    chan = 1:this.nChannels;
end
if nargin < 3
    group = 1:this.nGroups;
end

% Update a progress indicator
progInd = findobj('Tag', 't_progressIndicator_experiment');
set(progInd, 'String', 'Processing...', 'BackgroundColor', [1, 0.7, 0.7]);
drawnow;

if strcmp(token, 'all')
    % Initial complete processing    
    spikesTimeRaster(this);
    spontActivity(this);
    postStimActivity(this);
    timeProcValues(this, group, chan);
    spikesTimeProc(this, group, chan);
    spontSpikesTimeProc(this, group, chan);
    peakParameters(this, group, chan);
    
    this.customAnalysis(group, chan);
    
elseif strcmp(token, 'timeRasterMod')
    % Change of timeRasterMin or timeRasterMax in the raster panel
    spikesTimeRaster(this);
    
elseif strcmp(token, 'timeProcMod')
    % Change of timeProcMin or timeProcMax in the raster panel
    spikesTimeProc(this, group, chan);
    spontSpikesTimeProc(this, group, chan);
    peakParameters(this, group, chan);
    
    this.customAnalysis(group, chan);
    
elseif strcmp(token, 'autoProcRange')
    % Auto range for timeProcMin and timeProcMax for a certain channel
    timeProcValues(this, group, chan);
    spikesTimeProc(this, group, chan);
    spontSpikesTimeProc(this, group, chan);
    peakParameters(this, group, chan);
    
    this.customAnalysis(group, chan);
    
elseif strcmp(token, 'fixProcRange')
    % Fix range for timeProcMin and timeProcMax of all channels and groups
    spikesTimeProc(this, group, chan);
    spontSpikesTimeProc(this, group, chan);
    peakParameters(this, group, chan);
    
    this.customAnalysis(group, chan);
end

this.displayData();

% Update a progress indicator
set(progInd, 'String', 'Ready', 'BackgroundColor', [0.7, 1, 0.7]);

function spikesTimeRaster(this)
% Spike timings within the time window (timeRasterMin, timeRasterMax)
for k = 1:this.nGroups
    for l = 1:this.nChannels
        this.spikesTimeRaster{k}{l} = this.getSpikeTimings( ...
            this.timeRasterMin, this.timeRasterMax, k, l);
    end
end


function spontActivity(this)
% Calculate the spontaneous activity rate (between -0.15 and -0.05 sec)
for k = 1:this.nGroups
    for l = 1:this.nChannels
        [this.spontRateMean{k}(l), this.spontRateStd{k}(l)] = ...
            calcActivityRate(this, -0.15, -0.05, k, l);
    end
end

function postStimActivity(this)
% Calculate the post stimulus activity rate (between 0.3 and 0.5 sec)
for k = 1:this.nGroups
    for l = 1:this.nChannels
        [this.postStimRateMean{k}(l), this.postStimRateStd{k}(l)] = ...
            calcActivityRate(this, 0.3, 0.5, k, l);
    end
end

function timeProcValues(this, group, chan)
% Time borders of the processing range on the PSTH histogram
for k = group
    for l = chan
        [this.timeProcMin{k}(l), this.timeProcMax{k}(l)] = ...
            this.calcTimeProcRange(k, l);
        this.autoProcTime{k}(l) = true;
    end
end

function spikesTimeProc(this, group, chan)
% Spike timings within the time window (timeProcMin, timeProcMax)
for k = group
    for l = chan
        t_min = this.timeProcMin{k}(l);
        t_max = this.timeProcMax{k}(l);
        this.spikesTimeProc{k}{l} = this.getSpikeTimings(t_min, t_max, k, l);
    end
end

function spontSpikesTimeProc(this, group, chan)
% Spike timings within the time window -0.15 to -0.05s
for k = group
    for l = chan
        this.spontSpikesTimeProc{k}{l} = this.getSpikeTimings(-0.15, -0.05, k, l);
    end
end

function peakParameters(this, group, chan)
% PSTH peak latency and amplitude
for k = group
    for l = chan
        [this.peakPos{k}(l), this.peakAmp{k}(l)] = ...
            this.calcPeakParameters(k, l);
    end
end

