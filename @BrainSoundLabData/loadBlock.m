function status = loadBlock(this, blockListInd)
% Load the block according to the stimulus type

% 'status' reflects the success of the loading the block at the end of this function:
% status = 0 -> couldn't load the block
% stutus = 1 -> could load the block
status = 0;

% Clear uicontrols
set(findobj('Tag', 'lb_repetitions_raster'), 'Value', []);

% Update a progress indicator
progInd = findobj('Tag', 't_progressIndicator_experiment');
set(progInd, 'String', 'Loading...', 'BackgroundColor', [1, 0.7, 0.7]);
drawnow;

% Get blocks' filenames and a path from the labbook
[path, names] = this.labbook.getBlockPathAndNames();

blockNum = this.blockIndex{blockListInd, 1};
blockSpikeDataType = this.blockIndex{blockListInd, 2};

% Check the file existence
if strcmp(blockSpikeDataType, 'None')
    isExist = this.labbook.checkTDTBlockExistence();
    if ~isExist(blockNum)
        errordlg('Could not locate the block file', 'BrainSoundLab');
        % Update a progress indicator
        set(progInd, 'String', 'Ready', 'BackgroundColor', [0.7, 1, 0.7]);
        return
    end
end

% Create an instance of a block class according to the stimulus set
stimSet = experiment.stimAlias(this.labbook.stimulusSet{blockNum});
if isempty(stimSet)
    errordlg('Could not recognize the stimulus set', 'BrainSoundLab');
    % Update a progress indicator
    set(progInd, 'String', 'Ready', 'BackgroundColor', [0.7, 1, 0.7]);
    return
end

% Create an instance of the specific block class and load the data
this.block = experiment.(stimSet);

% Load a block
this.block.load(path, names{blockNum}, this.labbook.nChannels, blockSpikeDataType);

% Update a progress indicator
set(progInd, 'String', 'Processing...', 'BackgroundColor', [1, 0.7, 0.7]);
drawnow;

% Shape the GUI for a certain stimuli set analysis
this.setBlock();

% Default stimuli order
this.stimPrime = this.block.stim(1);
this.stimSecond = this.block.stim(2);

% Call the function which suppresses repeating spikes
this.block.suppressRepSpikes(this.tolerance, this.nRepSpikes);

% Update the channel and repetition list
set(findobj('Tag', 'lb_channels_experiment'), ...
    'String', num2cell(1:this.block.nChannels));
set(findobj('Tag', 'lb_repetitions_raster'), ...
    'String', num2cell(1:this.block.nRep), ...
    'Value', 1:this.block.nRep);

% Triger the current channel processing
this.block.selRep = 1:this.block.nRep;
this.block.processData('all');

this.setChannel();

% Update a progress indicator
set(progInd, 'String', 'Ready', 'BackgroundColor', [0.7, 1, 0.7]);

% Return with the positive status
status = 1;

