%%
temp_ind1 = [1,2,3];     % dB
temp_ind2 = [1,2,3,4,5,6];   % Rates

x = cell(length(temp_ind1), length(temp_ind2));
y = cell(length(temp_ind1), length(temp_ind2));
for ii = 1:length(temp_ind1)
    for jj = 1:length(temp_ind2)
        [x{ii,jj}, y{ii,jj}] = postprocessing.DSIvsBF_all_SB(temp_ind1(ii), temp_ind2(jj));
    end
end

%%
