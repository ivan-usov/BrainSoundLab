function [rateMean, rateStd] = calcActivityRate(this, t_min, t_max, group, chan)
% Calculate mean and std of the activity rate between t_min and t_max in spikes/sec

if nargin ~= 5
    error('BrainSoundLab:calcTimeProcRange', 'Invalid number of input arguments.');
end

% Bin size = 1 ms = 0.001 s
nBins = (t_max-t_min)/0.001;

spikes = this.getSpikeTimings(t_min, t_max, group, chan);
% spikes = arrayfun(@(k) vertcat(spikes{k,:}), (1:nTrials)', ...
%     'UniformOutput', false);

hc = histcounts(cell2mat(spikes(:)), linspace(t_min, t_max, nBins+1));
rate = hc/numel(spikes)/0.001;
rateMean = mean(rate);
rateStd = std(rate);

