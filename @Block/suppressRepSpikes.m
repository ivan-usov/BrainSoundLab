function suppressRepSpikes(this, tolerance, nRepSpikes)
% Find spikes that occure at the same time (withing 'tolerance' limit) and in
% more than 'nRepSpikes' channels

ts_diff = [this.ts(2:end) - this.ts(1:end-1); 1];
ind = (ts_diff < tolerance);
ts_diff(ind) = 0;
ts_diff(~ind) = 1;

ts_diff = diff([1; ts_diff]);
v_s = find(ts_diff == -1);
v_e = find(ts_diff == 1);
dist = v_e - v_s + 1;
ind = find(dist > nRepSpikes);
fin = true(length(this.ts), 1);
for k = ind'
    fin(v_s(k):v_e(k)) = false;
end

chan = this.chan(fin);
ts = this.ts(fin);

this.spikeTimings_sup = cell(1, this.nChannels);
for k = 1:this.nChannels
    idx = (chan == k);
    this.spikeTimings_sup{k} = ts(idx);
    
    % Spikes filters
    for l = 1:length(this.filtSpikes)
        this.filtSpikes(l).map{k} = this.filtSpikesData{l}(idx);
    end
end

this.spikeTimings = this.spikeTimings_sup;

