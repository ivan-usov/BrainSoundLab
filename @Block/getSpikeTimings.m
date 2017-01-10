function spikes = getSpikeTimings(this, t_min, t_max, group, chan)
% Find all spikes in a time window (t_min, t_max)

if nargin ~= 5
    error('Block:getSpikeTimings', 'Invalid number of input arguments.');
end

% Get all spike timings of a certain channel
spikeTimings = this.spikeTimings{chan};

if ~isempty(this.filtSpikes)
    map = true(size(spikeTimings));
    for k = 1:length(this.filtSpikes)
        filtParam = this.filtSpikes(k).val(this.filtSpikes(k).sel);
        map = map & ismember(this.filtSpikes(k).map{chan}, filtParam);
    end
    spikeTimings = spikeTimings(map);
end

spikes = arrayfun(@spike_count, this.stimTimings(:, this.selRep, group), ...
    'UniformOutput', false);

% Apply stimuli timing filters
if ~isempty(this.filtStim)
    ind = true(this.nTrials, 1);
    for k = 1:length(this.filtStim)
        allVal = this.filtStim(k).val;
        ind = ind & (this.filtStim(k).map == allVal(this.filtStim(k).sel));
    end
    spikes(~ind) = {[]};
end

    function spikes = spike_count(t0)
        ind1 = find(spikeTimings > t0 + t_min, 1, 'first');
        ind2 = find(spikeTimings < t0 + t_max, 1, 'last');
        spikes = spikeTimings(ind1:ind2) - t0;
    end
end

