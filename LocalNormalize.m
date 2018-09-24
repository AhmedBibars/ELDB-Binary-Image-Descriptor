function ln=LocalNormalize(IM,FilterSize)
% Patch illumination normalization
Filter1=ones(FilterSize,FilterSize)/(FilterSize*FilterSize);
num=single(IM)-imfilter(single(IM),Filter1,'replicate');
den=sqrt(imfilter(num.^2,Filter1,'replicate'));
den(den<1)=1; %0.0001  To avoid division on small values, because they cause noise in small-variation areas (Like Sky area)
ln=num./den;
