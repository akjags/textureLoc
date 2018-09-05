from skimage.io import imread
import os
import numpy as np

def preprocess_im(path):
    MEAN_VALUES = np.array([123.68, 116.779, 103.939]).reshape((1,1,1,3))
    image = imread(path)
    # Resize the image for convnet input, there is no change but just
    # add an extra dimension.
    image = np.reshape(image, ((1,) + image.shape))
    # Input to the VGG model expects the mean to be subtracted.
    image = image - MEAN_VALUES
    return image

if __name__ == "__main__":
    # First, preprocess the images.
    orig_ims = os.listdir('orig_ims2/')

    for im in orig_ims:
        if '.jpg' in im:
            imName = im.split('.')[0]
            new_im = preprocess_im('orig_ims2/'+im)
            np.save('orig_ims2/'+imName, new_im)
            print 'Preprocessed image ' + imName + ' saved' 
