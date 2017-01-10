function [spikes, clustNum, snips, su] = loadKlustaSpikeData(blockPath, blockName)
% Function to load a preprocessed Klustakwik block file

% Access Klusta mat file
matFile = matfile(fullfile(blockPath, 'kwik', [blockName '.mat'])); 

spikesData = matFile.spikes;
spikes.ts = spikesData(:, 1); % spike timings
clustNum = spikesData(:, 2); % spike cluster numbers
su = spikesData(:, 3); % single unit spikes
spikes.chan = spikesData(:, 4); % spike channel numbers

% Averaged waveforms per cluster (snips)
waveformsData = matFile.waveforms;
snips = waveformsData.waveforms;

