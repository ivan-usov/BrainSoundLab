function spikes = getSpikeTimings(this, t_min, t_max, group, chan)
% Find all spikes in a time window (t_min, t_max)

if nargin ~= 5
    error('Block:getSpikeTimings', 'Invalid number of input arguments.');
end

% Get all spike timings of a certain channel
spikeTimings = this.spikeTimings{chan};

if ~isempty(this.filtSpikes)
    for k = 1:length(this.filtSpikes)
        filtParam = this.filtSpikes(k).val(this.filtSpikes(k).sel);
        map = ismember(this.filtSpikes(k).map{chan}, filtParam);
    end
    spikeTimings = spikeTimings(map);
end

spikes = arrayfun(@spike_count, this.stimTimings(:, this.selRep, group), ...
    'UniformOutput', false);

    function spikes = spike_count(t0)
        ind1 = find(spikeTimings > t0 + t_min, 1, 'first');
        ind2 = find(spikeTimings < t0 + t_max, 1, 'last');
        spikes = spikeTimings(ind1:ind2) - t0;
    end
end

