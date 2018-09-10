
%% Set directories
orig_dir = '~/proj/TextureSynthesis/stimuli/out_fzs/orig';
ps_dir = '~/proj/TextureSynthesis/stimuli/out_fzs/ps_stim';
tex_dir = '~/proj/TextureSynthesis/stimuli/out_fzs/tex';
smpI = 11;

% get image names
imnames = dir([orig_dir '/*.png']);
imnames = {imnames.name};

tex_pre1 = 'pool1_';
tex_pre2 = 'pool2_';
tex_pre3 = 'pool4_';
ps_pre = 'tex-320x320-';

%% Create figure and plot
figure;

for fi = 1:length(imnames)
  
  fnm = imnames{fi};
  % split up filename by hyphens
  file_pre = strsplit(fnm, '.');
  file_pre = strsplit(file_pre{1}, '-');
  
  imname = sprintf('%s%s-smp%i.png', file_pre{1}, file_pre{2}, smpI);
  imname2 = sprintf('%s_smp%i.png', strjoin(file_pre, '-'), smpI);
  % Load the original image, PS, and our texture.
  im_orig = imread([orig_dir '/' fnm]);
  im_ps = imread([ps_dir '/' ps_pre imname]);
  im_pool1 = imread([tex_dir '/' tex_pre1 imname2]);
  im_pool2 = imread([tex_dir '/' tex_pre2 imname2]);
  im_pool4 = imread([tex_dir '/' tex_pre3 imname2]);

  % display in a subplot
  subplot(nRows, length(imnames), fi);
  imshow(im_orig);
  title('Original', 'FontSize', 16);
  
  subplot(nRows, length(imnames), length(imnames)+fi);
  imshow(im_ps);
  title('Portilla-Simoncelli', 'FontSize', 16);
  
  subplot(nRows, length(imnames), 2*length(imnames)+fi);
  imshow(im_pool1);
  title('Pool1 Texture', 'FontSize', 16);
  
  subplot(nRows, length(imnames), 3*length(imnames)+fi);
  imshow(im_pool2);
  title('Pool2 Texture', 'FontSize', 16);

  subplot(nRows, length(imnames), 4*length(imnames)+fi);
  imshow(im_pool4);
  title('Pool4 Texture', 'FontSize', 16);

end

figpos = [1 5 1920 1100];
set(gcf, 'Position', figpos);
