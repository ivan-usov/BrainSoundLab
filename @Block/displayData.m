function displayData(this)

% Default analysis for all type of blocks
display.Raster();
display.PSTH();

% Custom panels display
for k = 1:length(this.panels)
    display.(this.panels{k});
end

