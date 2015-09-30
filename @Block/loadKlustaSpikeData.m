function [ts, chan, snips, clustNum] = loadKlustaSpikeData(blockPath, blockName, nChannels)
% Function to load a Klustakwik block file

% Presettings
sampleRate = 24414.0625;
blockPath = fullfile(blockPath, ['Klusta_' blockName]);

% Load spike timings
ts = hdf5read(fullfile(blockPath, [blockName '.kwik']), ...
    '/channel_groups/0/spikes/time_samples');
ts = double(ts)/sampleRate; % spiketimings in seconds

% Load the corresponding cluster numbers
clustNum = load(fullfile(blockPath, [blockName '.clu.1']), ...
    '-ascii');
% Remove the first value (length(clusters) = length(spikeTimings)+1)
clustNum = clustNum(2:end);

% Load masks
fid = fopen(fullfile(blockPath, '_klustakwik', [blockName '.dat.fmask.0']));
fscanf(fid, '%*f', 1); % Skip the first line
formatSpec = [repmat('%f %*f %*f', 1, nChannels), '%*f'];
allMasks = fscanf(fid, formatSpec, [nChannels, Inf])';
fclose(fid);

% Remove de-selected spikes (clusters == 0)
ind = (clustNum ~= 0);
clustNum = clustNum(ind);
ts = ts(ind);
allMasks = allMasks(ind, :);

% Calculate the channel number (with the max value of the 'maskSum')
chan = zeros(length(clustNum), 1);
for i = unique(clustNum)'
    ind = (clustNum == i);
    maskSum = sum(allMasks(ind, :));
    [~, chan(ind)] = max(maskSum);
end

% TODO: snips
snips = zeros(size(ts));

