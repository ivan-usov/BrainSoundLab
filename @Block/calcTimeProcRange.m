function [tMin, tMax] = calcTimeProcRange(this, group, chan)
% Calculate time processing range based on the PSTH plot, use mean and
% standard deviation of the spontaneous activity as a validation of the
% PSTH peak presence

if nargin ~= 3
    error('Block:calcTimeProcRange', 'Invalid number of input arguments.');
end

% TODO: remove after the nStdDev is clarified
BSL = guidata(gcf);
nStdDev = BSL.nStdDev_psth;

% t_start = -0.2s, t_end = 0.8s, number of bins = 1000
% 1s = 1000; 0.2s = 200, 0.05s = 50

% Calculate spike rate
spikes = this.getSpikeTimings(-0.2, 0.8, group, chan);
n_all = histcounts(cell2mat(spikes(:)), linspace(-0.2, 0.8, 1001));
n_all = n_all/numel(spikes)/0.001;

% Make the spike time distribution smooth (reason for using hann(9)?)
kernel = hann(9);
kernel = kernel/sum(kernel);
sn_all = filtfilt(kernel, 1, n_all);

% Spike spontaneous activity (from -0.15s to -0.05s)
mSpont = this.spontRateMean{group}(chan);
sSpont = this.spontRateStd{group}(chan);

% Peak is supposed to be between 0s and 0.5s
ind = sn_all(200:700) >= mSpont + nStdDev*sSpont;
tMin = (find(ind, 1, 'first')-1)/1000;
tMax = (find(ind, 1, 'last')-1)/1000;

% In case of spontaneous activity is too large (mSpont + nStdDev*sSpont is ...
% always bigger than sn_all(200:700))
if isempty(tMin) || isempty(tMax)
    tMin = 0;
    tMax = 0.2;
end

