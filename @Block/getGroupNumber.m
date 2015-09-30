function groupNum = getGroupNumber(this)
% Return the linear group number based on the selected values among all groups

if length(this.group) == 1
    groupNum = this.group.sel;
else
    mat = combvec(this.group.sel);
    arg = mat2cell(mat, ones(size(mat,1), 1), size(mat,2));
    groupNum = sub2ind([this.group.len], arg{:});
end

