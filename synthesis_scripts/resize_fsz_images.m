
%% Script to resize images from 320x320 to 256x256
orig_in = '~/proj/TextureSynthesis/stimuli/freeman_ziemba_simoncelli/orig';
orig_out = '~/proj/TextureSynthesis/stimuli/orig_fzs';

a = dir([orig_in '/*.png']);
files = {a.name};

%%
for fi = 1:length(files)
  fileI = files{fi};
  
  im = imread([orig_in '/' fileI]);
  
  im2 = imresize(im, 0.8);
  
  saveName = [orig_out '/' fileI];
  imwrite(im2, saveName);
  disp(sprintf('Saved img %s to location %s', fileI, orig_out));
end
  