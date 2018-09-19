function classify_stim_types(roiList, scan, group)

if ieNotDefined('roiList')
  roiList = {'V1', 'V2', 'V3', 'V4'};
end
if ieNotDefined('scan')
  scan = 1;
end
if ieNotDefined('group')
  group = 'Concatenation';
end

r2cutoff = .2;

v = newView;
v = viewSet(v, 'curGroup', group);
v = viewSet(v, 'curScan', scan);
% Load analysis
overlays = viewGet(v, 'overlays');
if length(overlays) < 1
  v = loadAnalysis(v, 'corAnal/corAnal.mat');
  overlays = viewGet(v, 'overlays');
end
co_map = overlays(1).data{scan};

roi_acc = [];
for ri = 1:length(roiList)
  roiName = roiList{ri};

  % Load the time series for this ROI
  roi = loadROITSeries(v, roiName, scan, group);
  tSeries = roi.tSeries;

  blockLen = 9*2;
  tBlockStart = 1:blockLen:size(tSeries,2);

  % Get r2 for each voxel
  co = zeros(1,roi.n);
  for voxI = 1:roi.n
    scanCoord = roi.scanCoords(:,voxI);
    co(voxI) = co_map(scanCoord(1), scanCoord(2), scanCoord(3));
  end

  %% Get noise blocks and texture blocks
  ctr = 1;
  noiseBlocks = zeros(1, sum(co>r2cutoff), blockLen);
  texBlocks = zeros(1, sum(co>r2cutoff), blockLen);

  lag = 2;
  for startI = tBlockStart
    if startI == tBlockStart(1); ctr = ctr+1; continue; end % Skip first block
    if startI+lag+blockLen-1 > size(tSeries,2); continue; end % Skip last block

    ts = tSeries(co>r2cutoff, (startI+lag):(startI+lag+blockLen-1));
    if mod(ctr, 2) == 0 %even: noise trials
      noiseBlocks = [noiseBlocks; reshape(ts,1,size(ts,1), size(ts,2))];
    else % odd: texture trials
      texBlocks = [texBlocks; reshape(ts,1,size(ts,1), size(ts,2))];
    end
    ctr = ctr + 1;
  end
  noiseBlocks = noiseBlocks(2:end,:,:);
  texBlocks = texBlocks(2:end,:,:);
  nb = mean(noiseBlocks, 3); % nObservations x nVoxels
  tb = mean(texBlocks,3);


  % Perform mvpa classification on mean of noise blocks and texture blocks
  X = [nb; tb];
  Y = [zeros(size(nb,1),1); ones(size(tb,1),1)];
  mdl = fitcsvm(X,Y);
  cv_mdl = crossval(mdl, 'Leaveout', 'on');
  cv_loss = kfoldLoss(cv_mdl);
  labels = kfoldPredict(cv_mdl);
  disp(sprintf('%s (%i voxels) Crossvalidated Prediction Error: %g', roiName, size(nb,2), cv_loss));
  roi_acc(ri) = 1-cv_loss;

end

figure;
bar(roi_acc); hold on; hline(0.5);
ylim([0 1]);
set(gca, 'XTickLabel', roiList);
ylabel('Classification Accuracy');
set(gca, 'FontSize', 14);
%title('MVPA: Texture vs Noise by ROI');
keyboard
