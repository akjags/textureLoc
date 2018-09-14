function compare_roi_amplitudes(rois, r2cutoff, scan, group)

if ieNotDefined('r2cutoff')
  r2cutoff = .1;
end
if ieNotDefined('scan')
  scan = 1;
end
if ieNotDefined('group')
  group = 'Concatenation';
  group = 'Averages';
end
if ieNotDefined('rois')
  rois = {'V1', 'V2', 'V3', 'V4', 'LO1', 'LO2'};
  %rois = {'lV1', 'lV2', 'lV3', 'lV4', 'rV1', 'rV2', 'rV3', 'rV4'};
end
v = newView;
v = viewSet(v, 'curGroup', group);
v = loadAnalysis(v, 'corAnal/corAnal.mat');

roiAmps = [];
for i = 1:length(rois)
  roiAmps(i) = analyzeTextureBlocks(v, rois{i}, scan, group, r2cutoff, 0);
end

figure;
bar(roiAmps);
set(gca, 'XTick', 1:length(rois));
set(gca, 'XTickLabels', rois);
xlim([0, length(rois)+1]);
ylim([0, max(roiAmps)+.1]);
ylabel('fMRI Modulation Index');
set(gca, 'FontSize', 14);
title('P-S Texture Modulation Index by ROI');

keyboard
