function groupData = getGroupingConditions(this, source)
% Return a blank group in case of no grouping condition present in the
% experiment file (default behaviour)

groupData{1} = ones([this.nTotal, 1]);
this.group(1).label = 'None';

