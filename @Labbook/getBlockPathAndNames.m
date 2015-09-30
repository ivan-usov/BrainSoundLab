function [blockPath, blockNames] = getBlockPathAndNames(this)
% Return the expected block path and names depending on the experimenter

if strcmp(this.experimenter, 'RKC') % Rasmus
    tag = num2str(this.date);
else % Tania, Stiti, ...
    tag = this.expID;
end

blockPath = [this.path, tag];
blockNames = arrayfun(@(bn) [tag '_' 'Block-' num2str(bn)], ...
        this.blockNum, 'UniformOutput', false);
    
    