function enableItems(this)
% Enable GUI elements upon the first successful Block file openning

enableObjects = findobj( ...
    'Tag', 'lb_blocks_experiment', '-or', ...       % Experiment panel
    'Tag', 'lb_channels_experiment', '-or', ...
    'Tag', 'pb_saveDefault_information', '-or', ... % Information panel
    'Tag', 'pb_saveAs_information', '-or', ...
    'Tag', 'e_experimentComments_information', '-or', ...
    'Tag', 'e_blockComments_information', '-or', ...
    'Tag', 'pm_type_electrode', '-or', ...          % Electrode panel
    'Tag', 'e_timeRasterMin_raster', '-or', ...     % Raster panel
    'Tag', 'e_timeRasterMax_raster', '-or', ...
    'Tag', 'pm_sortBy_raster', '-or', ...
    'Tag', 'e_timeProcMin_raster', '-or', ...
    'Tag', 'e_timeProcMax_raster', '-or', ...
    'Tag', 'pb_left_raster', '-or', ...
    'Tag', 'pb_right_raster', '-or', ...
    'Tag', 'pb_autoRange_raster', '-or', ...
    'Tag', 'pb_fixRange_raster', '-or', ...
    'Tag', 'lb_repetitions_raster', '-or', ...
    'Tag', 'pb_selectAllRep_raster', '-or', ...
    'Tag', 'fixSpikeCount_psth', '-or', ...         % PSTH panel
    'Tag', 'e_nBins_psth', '-or', ...
    'Tag', 'e_nStdDev_psth');

set(enableObjects, 'Enable', 'on');
