function isExist = checkTDTBlockExistence(this)

% Get the expected block file names and the correponding path
[blockPath, blockNames] = getBlockPathAndNames(this);

% Check for the block files existence
dirListing = dir(blockPath);
dirNames = {dirListing.name};
dirFileNames = dirNames(~[dirListing.isdir]);
isExist = cellfun(@(s) any(strcmp([s '.mat'], dirFileNames)), blockNames);

