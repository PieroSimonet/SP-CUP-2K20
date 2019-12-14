function [Ieval] = getEdgeDetectFuzzy(image,edgeFIS)
%GETEDGEDETECTFUZZY return the edge-enfasized image with the fuzzy method
%   Detailed explanation goes here

    Gx = [-1 1];
    Gy = Gx';
    Ix = conv2(image,Gx,'same');
    Iy = conv2(image,Gy,'same');
    
    Ieval = zeros(size(image));
    for ii = 1:size(image,1)
        Ieval(ii,:) = evalfis(edgeFIS,[(Ix(ii,:));(Iy(ii,:))]');
    end
    
end

