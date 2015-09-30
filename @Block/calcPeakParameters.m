function [peakLat, peakAmp] = calcPeakParameters(this, group, chan)
% Calculate peak latency and amplitude of the PSTH histogram using 0.001s
% bin size, 0 min time and 0.5 max time

if nargin ~= 3
    error('Block:calcPeakParameters', 'Invalid number of input arguments.');
end

spikes = this.spikesTimeProc{group}{chan};
n_all = histcounts(cell2mat(spikes(:)), linspace(0, 0.5, 501));

% Make the spike time distribution smooth (reason for using hann(9)?)
kernel = hann(9);
kernel = kernel/sum(kernel);
sn_all = filtfilt(kernel, 1, n_all);

[peakAmp, peakLat] = max(sn_all);
peakAmp = peakAmp/numel(spikes)/0.001;
peakLat = peakLat/1000;

