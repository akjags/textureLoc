function compare_roi_amplitudes(rois, r2cutoff, scan, group)

if ieNotDefined('r2cutoff')
  r2cutoff = .25;
end
if ieNotDefined('scan')
  scan = 2;
end
if ieNotDefined('group')
  group = 'Concatenation';
end
if ieNotDefined('rois')
  rois = {'l_v1', 'l_v2', 'l_v3', 'l_v4', 'r_v1', 'r_v2', 'r_v3', 'r_v4'};
end

roiAmps = [];
for i = 1:length(rois)
  roiAmps(i) = analyzeTextureBlocks(rois{i}, scan, group, r2cutoff, 0);
end

figure;
plot(roiAmps, '*');
set(gca, 'XTick', 1:length(rois));
set(gca, 'XTickLabels', rois);
xlim([0, length(rois)+1]);
ylim([0, 1]);
ylabel('fMRI Modulation Index');
set(gca, 'FontSize', 14);

keyboard
