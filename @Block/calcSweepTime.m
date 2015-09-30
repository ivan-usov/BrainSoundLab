function sweepTime = calcSweepTime(this)
% Calculate the sweepTime based on the maximum and minimum frequencies

% Border frequencies
fq_min = 2000;
fq_max = 48000;

sweepOct = abs(log2(fq_max/fq_min));
sweepTime = abs(sweepOct ./ this.stimConditions(:, 2))/1000; % seconds

