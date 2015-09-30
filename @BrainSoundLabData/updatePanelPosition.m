function updatePanelPosition(this)
% Update the open panels positions

figPos = get(gcf, 'Position');
% Coordinates of the "first row" panels
x1 = 1;
y1 = 1 + figPos(4);

% Coordinates of the "second row" panels
x2 = 1 + 301;
y2 = 1 + figPos(4);

x3 = 1 + 1302;
y3 = 1 + figPos(4);

% Calculate open panels positions
for k = 1:length(this.openPanels)
    panPos = get(this.openPanels(k), 'Position');
    
    if panPos(3) == 300
%         if (y1<=panPos(4) && k~=1)
%             x1 = x1 + panPos(3) + 1;
%             y1 = 1 + figPos(4);
%         end
        
        y1 = y1 - panPos(4);
        
        panPos(1) = x1;
        panPos(2) = y1;
        
    elseif panPos(3) > 600
%         if (y2<=panPos(4) && k~=1)
%             x2 = x2 + 1000 + 1;
%             y2 = 1 + figPos(4);
%         end
        
        y2 = y2 - panPos(4);
        
        panPos(1) = x2;
        panPos(2) = y2;
    else
%         if (y3<=panPos(4) && k~=1)
%             x3 = x3 + 540 + 1;
%             y3 = 1 + figPos(4);
%         end
        
        y3 = y3 - panPos(4);
        
        panPos(1) = x3;
        panPos(2) = y3;
    end
    
    set(this.openPanels(k), 'Position', panPos);
end

