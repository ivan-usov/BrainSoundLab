function isSaved = saveDataDefault(this)
% GUI Callback function for the 'Save default' button in the Information panel

% Get fileName and filePath (append 'BSL_' to the fileName)
[fileName, filePath] = uiputfile('*.mat', 'Save Data As', ...
    fullfile(this.dataPath, ['BSL_', this.dataName]));
if isequal(fileName, 0); isSaved = false; return
else isSaved = true;
end

% Append .mat if uiputfile returns fileName without this extension
% (this happens if user fileName already contains dot(s) in it)
[~, ~, ext] = fileparts(fileName);
if ~strcmp(ext, '.mat')
    fileName = [fileName '.mat'];
end

this.dataName = fileName;
this.dataPath = filePath;

% Save the whole block with all information
block = this.block;
labbook = this.labbook;
save(fullfile(this.dataPath, this.dataName), 'block', 'labbook');

% Data is saved, and no longer differ from data in the file
this.isDataModified = false;

