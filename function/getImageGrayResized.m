function [imageOut] = getImageGrayResized(message, index, resizeFactor)
%GETIMAGEGRAYRESIZED return the gray image from the pod message
%   ADD A DESCRIPTION

    image = readImage(message{index,1});
    image = imrotate(image, 180);
    image = imresize(image, resizeFactor);
    
    imageOut = im2double(rgb2gray(image));

end

