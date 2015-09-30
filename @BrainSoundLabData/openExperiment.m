function openExperiment(this)
% GUI Callback function for the 'Open' button in the Experiment panel

% Prompt user to select the desired Experiment labbook file (*.xlsx)
[labbookFileName, labbookFilePath] = uigetfile({'*.xlsx', ...
    'Labbook file (*.xlsx)'}, 'Select Labbook file to open');
if labbookFileName == 0
    return; % Cancel or close button was pressed
end

% Change the current folder for the easier future navigation
% cd(labbookFilePath);

% Create a new Labbook with the information from the Excel file
this.labbook = Labbook(labbookFileName, labbookFilePath);

% Experiment name in the panel
set(findobj('Tag', 'e_name_experiment'), ...
    'String', this.labbook.expID, 'TooltipString', this.labbook.expID);

% GUI list of the recorded blocks from the labbook file and the stimulus
% conditions
isExistTDT = this.labbook.checkTDTBlockExistence();
isExistKlusta = this.labbook.checkKlustaBlockExistence();

% The color of the blocks:
%   missing blocks -> red
%   matlab TDT block file -> black
%   klustakwik block file -> blue
[blockList, blockIndex] = cellfun(@createBlockList, num2cell(this.labbook.blockNum), ...
    this.labbook.stimulusSet, num2cell(isExistTDT), num2cell(isExistKlusta), ...
    num2cell(1:length(this.labbook.blockNum)).', 'UniformOutput', false);

% Update the list of blocks in the Experiment panel
blockList = vertcat(blockList{:});
set(findobj('Tag', 'lb_blocks_experiment'), 'String', blockList);

% Save blockIndex for 'this.loadBlock' function
this.blockIndex = vertcat(blockIndex{:});

% Index of the first existent block data
ind = find(isExistTDT | isExistKlusta, 1, 'first');
if isempty(ind)
    errordlg('Could not find any existent Block', 'BrainSoundLab');
    return
end

% Try to load the first existent block by default
% (see 'set.curBlock(this, val)' in BrainSoundLabData.m)
this.curBlock = ind;

function [lines, index] = createBlockList(bn, ss, isExistTDT, isExistKlusta, k)
if isExistTDT && isExistKlusta % Both blocks
    lines = {[num2str(bn) ': ' ss]; ...
        ['<HTML><BODY color="Blue">', num2str(bn), ': ', ss]};
    index = {k, 'TDT'; k, 'Klusta'};
    
elseif isExistTDT && ~isExistKlusta % Only TDT file
    lines = {[num2str(bn) ': ' ss]};
    index = {k, 'TDT'};
    
elseif ~isExistTDT && isExistKlusta % Only Klusta files
    lines = {['<HTML><BODY color="Blue">', num2str(bn), ': ', ss]};
    index = {k, 'Klusta'};
    
else % None
    lines = {['<HTML><BODY color="Red">', num2str(bn) ': ' ss]};
    index = {k, 'None'};
end

