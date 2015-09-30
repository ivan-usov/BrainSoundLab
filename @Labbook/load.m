function load(this, fileName, filePath)
% Read XLSX file that contains information about the experiment
if ~exist(fullfile(filePath, fileName), 'file')
    errordlg('Could not read the labbook file', 'BrainSoundLab');
    error('LabbookData:load', 'Could not read the Labbook file');
end

[~, ~, data] = xlsread(fullfile(filePath, fileName));
% data = cellfun(@removeNaN, data, 'UniformOutput', false);

this.date = data{3,2};
this.expID = data{3,4};
this.experimenter = data{3,6};

% Basic mouse data
this.mouse.age = data{6,2};
this.mouse.dateOfBirth = data{6,4};
this.mouse.strain = data{6,6};
this.mouse.gender = data{6,8};
this.mouse.weight = data{6,10};
this.mouse.comments = data{6,12};

% Pre-experiment exposure
this.exposure.what = data{9,2};
this.exposure.timeWindow = data{9,4};
this.exposure.comments = data{9,6};

% Head-fixation conditioning
% TODO: Head-fixation cond

% Behavioural testing
% TODO: Behavioural testing

% Anesthesia
ind = 37 + find(cellfun(@(x)all(isnan(x)), data(39:48,1)), 1, 'first');
this.anesthesia.what = data(39:ind,1);
this.anesthesia.time = data(39:ind,2);
this.anesthesia.amount = data(39:ind,3);

% Experiment comments (Rasmus' edition of the labbook template)
expCom = data(39:48,5);
ind = cellfun(@ischar, expCom);
this.experimentComments = expCom(ind);

% Craniotomy
this.craniotomy.area = data{51,2};
this.craniotomy.size = data{51,4};
this.craniotomy.pictures = data{51,6};
this.craniotomy.comments = data{51,8};

% Electrophy
this.electrode.ID = data{54,2};
this.electrode.type = data{54,4};
this.electrode.use = data{54,6};
this.electrode.noiseLevel = data{54,8};
this.electrode.threshold = data{54,10};
this.electrode.angleToZenit = data{55,2};
this.electrode.dyeOnProbe = data{55,4};
this.electrode.brainFixed = data{55,6};

% Blocks
this.penetrationNum = data(58:end,1);
this.region = data(58:end,2);
this.tipDepth = data(58:end,3);
this.blockNum = vertcat(data{58:end,4});
this.stimulusSet = data(58:end,5);
this.startTime = data(58:end,6);
this.audResponse = data(58:end,7);
this.bf = data(58:end,8);
this.lightPower = data(58:end,9);
this.videoEMG = data(58:end,10);
% Read block comments, removing NaNs
blockComments = data(58:end,11);
blockComments(cellfun(@(x) any(isnan(x)), blockComments)) = {''};
this.blockComments = blockComments;

% Clean blocks' data
ind = ~(cellfun(@(x)any(isnan(x)), this.stimulusSet) | isnan(this.blockNum));
this.penetrationNum = this.penetrationNum(ind);
this.region = this.region(ind);
this.tipDepth = this.tipDepth(ind);
this.blockNum = this.blockNum(ind);
this.stimulusSet = this.stimulusSet(ind);
this.startTime = this.startTime(ind);
this.audResponse = this.audResponse(ind);
this.bf = this.bf(ind);
this.lightPower = this.lightPower(ind);
this.videoEMG = this.videoEMG(ind);
this.blockComments = this.blockComments(ind);

function x = removeNaN(x)
if all(isnan(x))
    x = [];
end

