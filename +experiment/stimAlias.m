function stimName = stimAlias(stimName)
% Set of aliases for the experiment names

if any(strcmpi(stimName, {'ToneCoarse'}))
    stimName = 'ToneFine';
    
elseif any(strcmpi(stimName, {'WN'}))
    stimName = 'WhiteNoise';
    
elseif strfind(stimName, '2tones')
    stimName = 'TwoTones';
    
end

% Check for the presence of a class file with the name 'stimName' in the
% '+experiment' folder, return an empty string if there is no such file
if exist(fullfile('+experiment', stimName), 'file') == 0
    stimName = '';
end

