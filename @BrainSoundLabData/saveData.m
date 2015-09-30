function isSaved = saveData(this)
% GUI Callback function for the 'Save' button in the Information panel

if isempty(this.dataPath)
    isSaved = this.saveDataAs();
else
    isSaved = true;
    
    % Save the whole block with all information
    block = this.block;
    labbook = this.labbook;
    save(fullfile(this.dataPath, this.dataName), 'block', 'labbook');
    
    % Data saved, and no longer differ from data in the file
    this.isDataModified = false;
end

