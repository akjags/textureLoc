% postprocess_texture.m
% 
%   by: akshay jagadeesh
%   date: 09/07/2018
%
%   inputs:
%     - tex_dir: directory in which the synthesized textures sit.
%     - img_dir: directory in which the original images for each tex family are.
%     - out_dir: directory to save the postprocessed textures out to (if empty, defaults to tex_dir).
%
function postprocess_texture(tex_dir, img_dir, out_dir)

if ieNotDefined('out_dir')
  out_dir = tex_dir;
end
if ieNotDefined('dirname');
  dirname = 'out_fzs';
end

wd = '~/proj/TextureSynthesis';
tex_dir = sprintf('%s/stimuli/%s/tex', wd, dirname);
skip=1
if skip == 0
%% Download textures
disp(sprintf('The number of textures generated in that directory is : '));
system(sprintf('ssh akshayj@login.sherlock.stanford.edu "ls ~/TextureSynthesis/%s/*/*.png | wc -l"', dirname));
x = input('Do you want to download those files to your local stimuli folder? (y or n) ', 's');
if strcmp(x, 'y')
  disp(sprintf('Downloading images to %s/stimuli/%s', wd, dirname));
%  system(sprintf('mkdir -p tex_dir'));
  mkdir(sprintf('%s/stimuli/%s', wd, dirname), 'tex');
  system(sprintf('rsync -ar --exclude=iters "akshayj@login.sherlock.stanford.edu:~/TextureSynthesis/%s/*" %s/stimuli/%s/tex', dirname, wd, dirname));
else
  disp('Ok see ya');
  return
end

%% Restructure directories and rename files.
d = dir([tex_dir '/v*']);
d = {d.name};
disppercent(-inf, '(postprocess_texture) Restructuring texture directories');
for di = 1:length(d)
  % loop through each subdirectory and move files back to texture directory
  sd1 = dir([tex_dir '/' d{di} '/*pool*']);
  files = {sd1.name};
  status = [];
  for fi = 1:length(files)
    txi = strsplit(files{fi}, '.');
    oldfilename = sprintf('%s/%s/%s', tex_dir, d{di}, files{fi});
    newfilename = sprintf('%s/%s_smp%i.%s', tex_dir, txi{1}, di, txi{2});
    status(fi) = movefile(oldfilename, newfilename);
  end
  if sum(status) == length(files); rmdir([tex_dir '/' d{di}]);
  else disp('Uh oh not all files were properly moved.'); end
  disppercent(di / length(d));
end
disppercent(inf);
end


img_dir = sprintf('%s/stimuli/%s/orig', wd, dirname);
if ~exist(img_dir)
  x = input('(postprocess_texture) Original image directory not found. Enter full path to orig im directory: ', 's');
  copyfile(x, img_dir);
  if ~exist(img_dir)
    disp('Image directory  not found. Luminance equalization cannot run.'); 
    return
  end
end

x = input('(postprocess_texture) Running luminance histogram equalization. Are you okay with overwriting raw images? Press y to proceed or n to skip luminance histogram equalization : ', 's');
if strcmp(x, 'y')
  a = dir([tex_dir '/*.png']);
  fns = {a.name};

  disppercent(-inf, 'Equalizing luminance distributions');
  for fi = 1:length(fns)
    file = fns{fi};
    
    name = strsplit(file, '_');

    % Load both texture and original image
    imgI = imread([tex_dir '/' file]);
    imgOrig = imread([img_dir '/' name{2} '.png']);

    % modify texture to equalize its histogram
    for i = 1:size(imgI,3)
      im_new(:,:,i) = histeq(imgI(:,:,i), imhist(vectify(imgOrig(:,:,i))));
    end

    % Write out to new directory
    imwrite(im_new, [tex_dir '/' file]);

    disppercent(fi/ length(fns));
  end
  disppercent(inf);
end

x = input('(postprocess_texture) Do you want to generate the phase-scrambled noise images at this time? (y or n) ', 's');
noise_out_dir = [wd '/stimuli/' dirname '/noise'];
if strcmp(x, 'y')
  mkdir(noise_out_dir);
  generatePhaseScramble(tex_dir, noise_out_dir);
end

keyboard

x = input('Do you want to vignette the TEXTURE images and save them to the tex_vig folder? ', 's');
if strcmp(x, 'y')
  tex_vig_dir = [wd '/stimuli/' dirname '/tex_vig'];
  mkdir(tex_vig_dir);
  vignetteImages(tex_dir, tex_vig_dir);
end

x = input('Do you want to vignette the NOISE images and save them to the noise_vig folder? ', 's');
if strcmp(x 'y')
  noise_vig_dir = [wd '/stimuli/' dirname '/tex_vig'];
  mkdir(noise_vig_dir);
  vignetteImages(noise_out_dir, noise_vig_dir, 0);
end
