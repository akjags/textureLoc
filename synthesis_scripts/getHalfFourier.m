function d = getHalfFourier(im)

% make sure there are an odd number of pixels
if iseven(size(im,1)),im = im(1:end-1,:);end
if iseven(size(im,2)),im = im(:,1:end-1);end

% take fourier transform of image
imf = fft2(im);

% get input dimensions
d.originalDims = size(im);

% get one half of fourier image
imfh = fftshift(imf);
imfh = imfh(1:d.originalDims(1),1:ceil(d.originalDims(2)/2));

% extract dc form half fourier image
d.dc = imfh(ceil(d.originalDims(1)/2),end);
halfFourier = imfh(1:(prod(size(imfh))-ceil(d.originalDims(1)/2)));

d.mag = abs(halfFourier);
d.phase = angle(halfFourier);
d.n = length(d.phase);
