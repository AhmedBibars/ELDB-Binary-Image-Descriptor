function [Output]= ELDB1 (GrayImage,RegionsMat,ComparisonVector)
OutSize=size(RegionsMat,1);
AbsDiffx=abs([GrayImage(:,2:size(GrayImage,2))-GrayImage(:,1:(size(GrayImage,2)-1)),zeros(size(GrayImage,1),1)]);
AbsDiffy=abs([GrayImage(1:(size(GrayImage,1)-1),:)-GrayImage(2:size(GrayImage,1),:);zeros(1,size(GrayImage,2))]);

IntegralFrame=integralImage(GrayImage);
IntegralAbsDiffx=integralImage(AbsDiffx);
IntegralAbsDiffy=integralImage(AbsDiffy);

% [ImageSize1,ImageSize2]=size(GrayImage);
% Thx=IntegralAbsDiffx(ImageSize1,ImageSize2)/(ImageSize1*ImageSize2);
% Thy=IntegralAbsDiffy(ImageSize1,ImageSize2)/(ImageSize1*ImageSize2);

AvgMat=zeros(OutSize,1);
AbsDiffxMat=zeros(OutSize,1);
AbsDiffyMat=zeros(OutSize,1);

for i=1:OutSize
    Startcolumn=RegionsMat(i,1);
    Endcolumn=RegionsMat(i,2);
    StartRow=RegionsMat(i,3);
    EndRow=RegionsMat(i,4);
           % J(eR+1,eC+1) - J(eR+1,sC) - J(sR,eC+1) + J(sR,sC)
    AvgMat(i,1)= IntegralFrame(EndRow+1,Endcolumn+1) - IntegralFrame(EndRow+1,Startcolumn) - IntegralFrame(StartRow,Endcolumn+1) + IntegralFrame(StartRow,Startcolumn);
    AbsDiffxMat(i,1)=IntegralAbsDiffx(EndRow+1,Endcolumn+1) - IntegralAbsDiffx(EndRow+1,Startcolumn) - IntegralAbsDiffx(StartRow,Endcolumn+1) + IntegralAbsDiffx(StartRow,Startcolumn);
    AbsDiffyMat(i,1)=IntegralAbsDiffy(EndRow+1,Endcolumn+1) - IntegralAbsDiffy(EndRow+1,Startcolumn) - IntegralAbsDiffy(StartRow,Endcolumn+1) + IntegralAbsDiffy(StartRow,Startcolumn);
end


AvgOut=(AvgMat(ComparisonVector(:,1),1)-AvgMat(ComparisonVector(:,2),1))>0;
AbsDiffxOut=(AbsDiffxMat(ComparisonVector(:,1),1)-AbsDiffxMat(ComparisonVector(:,2),1))>0;%Thx;
AbsDiffyOut=(AbsDiffyMat(ComparisonVector(:,1),1)-AbsDiffyMat(ComparisonVector(:,2),1))>0;%Thy;

Output=[AvgOut;AbsDiffxOut;AbsDiffyOut];