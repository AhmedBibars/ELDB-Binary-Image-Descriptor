function [GrayOutputImage]=SkyBlackining(InputImage)
%C=-1.16*InputImage(:,:,1)+0.363*InputImage(:,:,2)+1.43*InputImage(:,:,3)-82.3;
%figure;imshow(C);
% Mask=zeros(size(C,1),size(C,2));
% Mask(5:(size(Mask,1)-10),5:(size(Mask,2)-10))=1;
% Mask = logical(Mask);
% BinaryImage = activecontour(C,Mask);
% figure;imshow(BinaryImage);
% threshold = graythresh(C);
% bw = im2bw(C,threshold);
% figure;imshow(bw);

gray=rgb2gray(InputImage);
threshold = graythresh(gray);
bw = im2bw(gray,threshold);
%figure;imshow(bw);
GrayOutputImage=gray.*uint8(~bw);