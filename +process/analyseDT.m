function analyseDT(group, chan)
BSL = guidata(gcf);
block = BSL.block;
if nargin == 0
    group = 1:block.nGroups;
    chan = 1:block.nChannels;
end

% There should be only one group (see the experiment file)
if group ~= 1
    error('BrainSoundLab:analyseDT', 'There should be only 1 group');
end

% There should be only two tones
if block.filtStim.len ~= 2
    error('BrainSoundLab:analyseDT', 'There should be only 2 tones');
end

% Preallocate in case of the first time calculation
if ~isfield(block.custom, 'DT_standard')
    block.custom.DT_standard_mean = cell(1, block.nChannels);
    block.custom.DT_standard_sigma = cell(1, block.nChannels);
    block.custom.DT_deviant_mean = cell(1, block.nChannels);
    block.custom.DT_deviant_sigma = cell(1, block.nChannels);
end

tones = block.filtStim.val;
if nnz(block.filtStim.map == tones(1)) < nnz(block.filtStim.map == tones(2))
    dev_tone = tones(1);
else
    dev_tone = tones(2);
end

is_dev = (block.filtStim.map == dev_tone);
is_std = ~is_dev;

is_dev_temp = is_dev;
is_dev_temp(end) = 1; % account for non-devaint tone ending
dev_pos = find(is_dev_temp); % positions of deviant tones
std_seq_len = dev_pos - [0; dev_pos(1:end-1)] - 1; % sequence length of standard tones

num_preced = []; % number of preceding standard tones
for i = 1:length(std_seq_len)
    num_preced = [num_preced; (0:std_seq_len(i)).']; %#ok<AGROW>
end

for l = chan
    spikes_num = cellfun(@numel, block.spikesTimeProc{1}{l});
    
    for k = 1:max(std_seq_len)+1
        spikes_std = spikes_num(num_preced == k-1 & is_std); % standard tones
        block.custom.DT_standard_mean{l}(k) = mean(spikes_std);
        block.custom.DT_standard_sigma{l}(k) = std(spikes_std);
        
        spikes_dev = spikes_num(num_preced == k-1 & is_dev); % deviant tones
        block.custom.DT_deviant_mean{l}(k) = mean(spikes_dev);
        block.custom.DT_deviant_sigma{l}(k) = std(spikes_dev);
    end
end

