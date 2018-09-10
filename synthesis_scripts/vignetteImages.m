% vignetteImages.m
%
%     date: 08/28/18
%       by: akshay jagadeesh
%
%     Given a directory containing images, generate a vignetted version of
%     each of those images and save it to the specified output directory.
function vignetteImages(inputDir, outputDir, verbose)

if ieNotDefined('inputDir')
  inputDir = '~/proj/TextureSynthesis/out_bw/v2';
end
if ieNotDefined('outputDir')
  outputDir = '~/proj/TextureSynthesis/out_bw_vig/v2';
end
if ieNotDefined('verbose')
  verbose = 1;
end

direc = dir([inputDir '/*.png']);
imNames = {direc.name};

%%

%disppercent(-inf, sprintf('Generating and saving vignette images'));
parfor imI = 1:length(imNames)
  im = imread([inputDir '/' imNames{imI}]);
  newim = im;
  imsz = size(im);
  center = [(imsz(1)+1)/2, (imsz(1)+1)/2];

  for i = 1:imsz(1)
    for j = 1:imsz(2)
      dist = pdist2([i,j], center);

      if dist > center(1)
        newim(i,j,:) = 127.5;
      end
    end
  end
  
  imwrite(newim, [outputDir '/' imNames{imI}]);
  if verbose
    disp(sprintf('Vignetted and saved image: %s', imNames{imI}));
  end
end

