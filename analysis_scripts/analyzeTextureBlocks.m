function [modIdx, signalAmp] = analyzeTextureBlocks(roiName, scan, group, r2cutoff, plotFigs)

if ieNotDefined('scan')
  scan = 1;
end
if ieNotDefined('r2cutoff')
  r2cutoff = .02;
end
if ieNotDefined('group')
  group = 'Concatenation';
end
if ieNotDefined('plotFigs')
  plotFigs = 1;
end

% Initialize mlr view
v = newView;
v = viewSet(v, 'curGroup', group);
v = viewSet(v, 'curScan', scan);

% Load roi t series
roi = loadROITSeries(v, roiName, scan);
tSeries = roi.tSeries;

% Load analysis
v = loadAnalysis(v, 'corAnal/corAnal.mat');
overlays = viewGet(v, 'overlays');
co_map = overlays(1).data{scan};

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

lag = 3;
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
nb = squeeze(mean(noiseBlocks,1));
tb = squeeze(mean(texBlocks,1));

nVox = sum(co>r2cutoff); totVox = length(co>r2cutoff);

%%
if plotFigs
  figure;
  subplot(3,1,1);
  plot(mean(nb,1)', 'b'); hold on;
  plot(mean(tb,1)', 'g');
  legend({'Noise', 'Texture'});
  title(sprintf('%s: (%d/%d voxels) Texture vs Spectrally Matched Noise', roiName, nVox, totVox), 'FontSize', 16);
  xlabel('Volumes');
  ylabel('BOLD (percent signal change)');
  set(gca, 'FontSize', 14);

  subplot(3,1,2);
  rndVox1 = randi(size(nb,1));
  plot(nb(rndVox1,:)', 'b'); hold on;
  plot(tb(rndVox1,:)', 'g');
  title(sprintf('Random %s Voxel 1', roiName));

  subplot(3,1,3);
  rndVox2 = randi(size(nb,1));
  plot(nb(rndVox2,:)', 'b'); hold on;
  plot(tb(rndVox2,:)', 'g'); 
  xlabel('Volumes');
  ylabel('BOLD (percent signal change)');
  title(sprintf('Random %s Voxel 2', roiName));
end

%% Part 2 correlation analysis
coh = overlays(1);
amps = overlays(2);
cor_map = coh.data{scan};
amp_map = amps.data{scan};
ncycles = viewGet(v,'ncycles',scan);
detrend = viewGet(v,'detrend',scan);
spatialnorm = viewGet(v,'spatialnorm',scan);
junkframes = viewGet(v,'junkframes',scan);
nframes = viewGet(v,'nframes',scan);
framePeriod = viewGet(v,'framePeriod',scan);
trigonometricFunction = viewGet(v,'trigonometricFunction',scan);

cor_tseries = mean(tSeries(co > r2cutoff,:,:),1)';
[coval, ampval, phval, ptseries] = computeCoranal(cor_tseries,ncycles,detrend,spatialnorm,trigonometricFunction);

singleCycle = mean(reshape(ptseries,nframes/ncycles,ncycles)');
singleCycleSte = std(reshape(ptseries,nframes/ncycles,ncycles)')/sqrt(ncycles);

% calculate fft
ft = fft(ptseries);
absft = abs(ft(1:round((length(ft)/2))));
signalAmp = absft(ncycles+1);
noiseFreq = round(2*length(absft)/3):length(absft);
noiseAmp = mean(absft(noiseFreq));
snr = signalAmp/noiseAmp;

cors = zeros(1,roi.n);
amplitudes = zeros(1,roi.n);
for voxI = 1:roi.n
  scanCoord = roi.scanCoords(:,voxI);
  amplitudes(voxI) = amp_map(scanCoord(1), scanCoord(2), scanCoord(3));
  cors(voxI) = cor_map(scanCoord(1), scanCoord(2), scanCoord(3));
end

roi_amp = mean(amplitudes(cors > r2cutoff));

disp(sprintf('(analyzeTextureBlocks) %s modulation amplitude is %.03f', roiName, mean(amplitudes)));
disp(sprintf('ROI Amplitudes: %.03f', roi_amp));
disp(sprintf('Signal Amplitude: %.03f', signalAmp));

modIdx = roi_amp;
%%
