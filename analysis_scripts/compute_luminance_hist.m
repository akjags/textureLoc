function compute_luminance_hist(ims)

wd = '~/proj/TextureSynthesis/stimuli';

ims = {'bark', 'branch', 'bricks', 'cracks', 'drops', 'floor', 'glass', 'rocks', 'spikes', 'wood'};

nRows = 5; nCols = 4;

means = zeros(nRows, nCols, 2);
vars = zeros(nRows, nCols, 2);
kurts = zeros(nRows, nCols, 2);
skews = zeros(nRows, nCols, 2);
for i = 1:nRows
  im1 = reduce_dim(imread(sprintf('%s/out_bw/v1/1x1_pool1_%s.jpg', wd, ims{i})));
  im2 = reduce_dim(imread(sprintf('%s/out_bw/v1/1x1_pool4_%s.jpg', wd, ims{i})));
  im3 = reduce_dim(imread(sprintf('%s/spectral_noise/v1/noise_%s.jpg', wd, ims{i})));
  im4 = reduce_dim(imread(sprintf('%s/orig_bw/%s.jpg', wd, ims{i})));
  
  figure(1);
  subplot(nRows, nCols, (i-1)*nCols + 1);
  imhist(im1);
  title(sprintf('Pool1: %s', ims{i}), 'FontSize', 14);

  subplot(nRows, nCols, (i-1)*nCols + 2);
  imhist(im2);
  title(sprintf('Pool4: %s', ims{i}), 'FontSize', 14);

  subplot(nRows, nCols, (i-1)*nCols+3);
  imhist(im3);
  title(sprintf('Noise: %s', ims{i}), 'FontSize', 14);

  subplot(nRows, nCols, (i-1)*nCols+4);
  imhist(im4);
  title(sprintf('Original Image'), 'FontSize', 14);

  figure(2);
  subplot(nRows, nCols, (i-1)*nCols + 1);
  imshow(im1);
  subplot(nRows, nCols, (i-1)*nCols + 2);
  imshow(im2);
  subplot(nRows, nCols, (i-1)*nCols + 3);
  imshow(im3);
  subplot(nRows, nCols, (i-1)*nCols + 4);
  imshow(im4);

  for j = 1:4
    img = double(eval(sprintf('im%i', j)));
    means(i,j,1) = mean(img(:));
    vars(i,j,1) = var(img(:));
    skews(i,j,1) = skewness(img(:));
    kurts(i,j,1) = kurtosis(img(:));
  end

  %% Now, equalize histograms and replot
  figure(3);
  subplot(nRows, nCols, (i-1)*nCols + 1);
  im1 = histeq(im1, imhist(im4));
  imhist(im1);
  title(sprintf('Pool1: %s', ims{i}), 'FontSize', 14);

  subplot(nRows, nCols, (i-1)*nCols + 2);
  im2 = histeq(im2, imhist(im4));
  imhist(im2);
  title(sprintf('Pool4: %s', ims{i}), 'FontSize', 14);

  subplot(nRows, nCols, (i-1)*nCols+3);
  im3 = histeq(im3, imhist(im4));
  imhist(im3);
  title(sprintf('Noise: %s', ims{i}), 'FontSize', 14);

  subplot(nRows, nCols, (i-1)*nCols+4);
  imhist(im4);
  title(sprintf('Original Image'), 'FontSize', 14);

  figure(4);
  subplot(nRows, nCols, (i-1)*nCols + 1);
  imshow(im1);
  subplot(nRows, nCols, (i-1)*nCols + 2);
  imshow(im2);
  subplot(nRows, nCols, (i-1)*nCols + 3);
  imshow(im3);
  subplot(nRows, nCols, (i-1)*nCols + 4);
  imshow(im4);

   for j = 1:4
    img = double(eval(sprintf('im%i', j)));
    means(i,j,2) = mean(img(:));
    vars(i,j,2) = var(img(:));
    skews(i,j,2) = skewness(img(:));
    kurts(i,j,2) = kurtosis(img(:));
  end

  figure(5);
  
  b1 = [means(i,:,1); means(i,:,2)];
  b2 = [vars(i,:,1); vars(i,:,2)];
  b4 = [kurts(i,:,1); kurts(i,:,2)];
  b3 = [skews(i,:,1); skews(i,:,2)];

  stats = {'Mean', 'Variance', 'Skewness', 'Kurtosis'};
  for k = 1:4
    subplot(nRows, 4, (i-1)*4 + k);
    bar(eval(sprintf('b%i', k)));
    title(sprintf('%s %s: Before and After histEq', ims{i}, stats{k}), 'FontSize', 16);
    legend({'Pool1', 'Pool2', 'Noise', 'Original'}, 'Location', 'southeast');
    set(gca, 'XTick', 1:2); set(gca, 'XTickLabel', {'Before', 'After'});
  end

end

close 1 2 3 4 
% Plot mean, variance, skew, and kurtosis for each image vs texture.
keyboard



function img = reduce_dim(img)

if size(img,3) > 1
  img = img(:,:,1);
end
