function mod = calc_modulation_by_texture(group, scans)

if ieNotDefined('group')
  group = 'MotionComp';
end
if ieNotDefined('scans')
  scans = 1:2:8;
end

v = newView;
v = viewSet(v, 'curGroup', group);
v = loadAnalysis(v, 'corAnal/corAnal.mat');

%% Loop through each group and calculate mod idx for each ROI
% Get the stimulus image on left and right sides from stimfile
left_rois = {'lV1', 'lV2', 'lV3', 'lV4'};
right_rois = {'rV1', 'rV2', 'rV3', 'rV4'};
rois = {'V1', 'V2', 'V3', 'V4'};

r2cutoff = .15;

mod = struct();
for scan = scans
  v = viewSet(v, 'curScan', scan);
  stimfile = viewGet(v, 'stimfile');
  img = stimfile{1}.stimulus.runImage; % contralateral 
  if ~isfield(mod, img); mod.(img) = struct(); end

  for ri = 1:length(rois)
    roi = rois{ri};
    [modIdx, ~] = analyzeTextureBlocks(v, roi, scan, group, r2cutoff, 0);
    mod.(img) = append_struct_vec(mod.(img), roi, modIdx);
  end
    
end

%%
stims = fields(mod);
rois = fields(mod.(stims{1}));
modArr = zeros(length(stims), length(rois));
for si = 1:length(stims)
  stim = stims{si};
  for ri = 1:length(rois)
    roi = rois{ri};
    modArr(si, ri) = mean(mod.(stim).(roi));
  end
end
   
%% Plot Mod indexes
figure;
bar(modArr);
set(gca, 'XTickLabel', stims);
set(gca, 'FontSize', 14);
legend(rois);
title('Texture (P-S) Modulation by Image', 'FontSize', 18);
ylabel('Modulation Index');

%%
keyboard

%%
function struc = append_struct_vec(struc, field, value)

if ~isfield(struc, field)
  struc.(field) = [value];
else
  struc.(field) = [struc.(field) value];
end

