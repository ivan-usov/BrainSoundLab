function stimCond = getStimuliConditions(this, source)
% This function is called when there is no stimuli conditions defined in
% the experiment file, which should result in error

error('Block:getStimuliConditions', ...
    'There must be at least one stimulus defined in the experiment file');

