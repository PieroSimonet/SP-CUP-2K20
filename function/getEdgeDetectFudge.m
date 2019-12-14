function [imageOut] = getEdgeDetectFudge(image, fudgeFactor)
%GETEDGEDETECTFUDGE return the edge-enfasized image with the fudge method
%   Detailed explanation goes here

    [~,threshold] = edge(image,'sobel');
    imageOut = edge(image,'sobel',threshold * fudgeFactor);
    
end

