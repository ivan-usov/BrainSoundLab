function AllChTRF()
BSL = guidata(gcf);
block = BSL.block;

sites = get(findobj('Tag', 'tab_channels_electrode'), 'Data');

for k = 1:block.nChannels
    ax = findobj('Tag', ['ax_allChTRF_' num2str(find(sites == k))], ...
        'Parent', BSL.panels.(['AllChTRF_', num2str(block.nChannels)]));
    
    image(block.custom.TRF{BSL.curGroup}{k}, 'CDataMapping', 'scaled', ...
        'Tag', ['im_allChTRF_' num2str(k)], 'Parent', ax, ...
        'ButtonDownFcn', @(h,ed)Callback_imageSelectCh(h, BSL));
    axis(ax, 'tight');
    set(ax, 'CLim', [0 max(block.custom.TRF_max{BSL.curGroup})]);
end

function Callback_imageSelectCh(hObject, BSL)
tag = get(hObject, 'Tag');
chan = sscanf(tag, 'im_allChTRF_%u');

BSL.curChannel = chan;

