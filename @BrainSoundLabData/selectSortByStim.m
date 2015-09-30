function selectSortByStim(this, label)
% Find the index of the selected stimulus
ind = strcmp(label, {this.block.stim(:).label});

if any(ind)
    % Sort trials by particular stimulus
    this.stimPrime = this.block.stim(ind);
%     ind(this.stimFixed.k) = true;
    this.stimSecond = this.block.stim(~ind);
else
    % Sort trials by number
    this.stimPrime = this.block.stim0;
    this.stimSecond = this.block.stim0;
end

