function ln=localnormalize(IM,FilterSize)
%LOCALNORMALIZE A local normalization algorithm that uniformizes the local
%mean and variance of an image.
%  ln=localnormalize(IM,sigma1,sigma2) outputs local normalization effect of 
%  image IM using local mean and standard deviation estimated by Gaussian
%  kernel with sigma1 and sigma2 respectively.
%
%  Contributed by Guanglei Xiong (xgl99@mails.tsinghua.edu.cn)
%  at Tsinghua University, Beijing, China.
Filter1=ones(FilterSize,FilterSize)/(FilterSize*FilterSize); %avarage filter
num=single(IM)-imfilter(single(IM),Filter1,'replicate');
den=sqrt(imfilter(num.^2,Filter1,'replicate'));
den(den<7)=7; %0.0001
ln=num./den;
%ln=num;