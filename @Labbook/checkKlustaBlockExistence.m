function isExist = checkKlustaBlockExistence(this)

% Get the expected block file names and the correponding path
[blockPath, blockNames] = getBlockPathAndNames(this);

% Check existence of 'kwik' folder
kwik_folder = fullfile(blockPath, 'kwik');
if exist(kwik_folder, 'dir') == 7
    % Check for the block files existence
    dirListing = dir(kwik_folder);
    dirNames = {dirListing.name};
    dirFileNames = dirNames(~[dirListing.isdir]);
    isExist = cellfun(@(s) any(strcmp([s '.mat'], dirFileNames)), blockNames);
    
else
    % No 'kwik' folder -> no kwik block files
    isExist = zeros(size(blockNames));
end

