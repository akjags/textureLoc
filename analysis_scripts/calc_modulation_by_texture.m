function mod = calc_modulation_by_texture(group, scans)

if ieNotDefined('group')
  group = 'MotionComp';
end
if ieNotDefined('scans')
  scans = 5:20;
end

v = newView;
v = viewSet(v, 'curGroup', group);
v = loadAnalysis(v, 'corAnal/corAnal.mat');

%% Loop through each group and calculate mod idx for each ROI
% Get the stimulus image on left and right sides from stimfile
left_rois = {'l_v1', 'l_v2'};
right_rois = {'r_v1', 'r_v2'};

r2cutoff = .05;
mod = struct();
for scan = scans
  v = viewSet(v, 'curScan', scan);
  stimfile = viewGet(v, 'stimfile');
  r_img = stimfile{1}.stimulus.runImageRight; % contralateral 
  l_img = stimfile{1}.stimulus.runImageLeft;
  if ~isfield(mod, r_img); mod.(r_img) = struct(); end
  if ~isfield(mod, l_img); mod.(l_img) = struct(); end
    
  for li = 1:length(left_rois)
    roi = left_rois{li};
    [modIdx, ~] = analyzeTextureBlocks(v, roi, scan, group, r2cutoff, 0);
    mod.(r_img) = append_struct_vec(mod.(r_img), roi(3:end), modIdx);
  end
  for ri = 1:length(right_rois)
    roi = right_rois{ri};
    
    [modIdx, ~] = analyzeTextureBlocks(v, roi, scan, group, r2cutoff, 0);
    mod.(l_img) = append_struct_vec(mod.(l_img), roi(3:end), modIdx);
  end
end

keyboard

%%
function struc = append_struct_vec(struc, field, value)

if ~isfield(struc, field)
  struc.(field) = [value];
else
  struc.(field) = [struc.(field) value];
end

