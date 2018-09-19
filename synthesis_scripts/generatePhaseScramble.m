%% generatePhaseScramble.m
%
%   Function to generate phase scrambled (spectrally matched noise) images
%    and save them out to a directory
%
%    by: akshay jagadeesh
%  date: 08/18/2018
%
function generatePhaseScramble(origImPath, outDirPath)

orig_ims = dir([origImPath '/*.png']);
orig_ims = {orig_ims.name};

disppercent(-inf, sprintf('(generatePhaseScramble) Phase scrambling images in directory %s', origImPath));
for imI = 1:length(orig_ims)
  
  imPath = [origImPath '/' orig_ims{imI}];
  
  im = phaseScrambleIm(imPath);
  
  imname = orig_ims{imI};
  %imname = strsplit(orig_ims{imI}, '_');
  %imname = strjoin({imname{2:end}}, '_'); % get the part of the filename after the pool layer
  saveName = sprintf('%s/noise_%s', outDirPath, imname);
  imwrite(im, saveName, 'PNG');
  disppercent(imI / length(orig_ims));
end

disppercent(inf);
