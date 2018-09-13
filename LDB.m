function [Output]= LDB (GrayImage,RegionsMat,ComparisonVector)
OutSize=size(RegionsMat,1);
Diffx=[GrayImage(:,2:size(GrayImage,2))-GrayImage(:,1:(size(GrayImage,2)-1)),zeros(size(GrayImage,1),1)];
Diffy=[GrayImage(1:(size(GrayImage,1)-1),:)-GrayImage(2:size(GrayImage,1),:);zeros(1,size(GrayImage,2))];
%[Diffx,Diffy]=imgradientxy(GrayImage);

IntegralFrame=integralImage(GrayImage);
IntegralDiffx=integralImage(Diffx);
IntegralDiffy=integralImage(Diffy);


AvgMat=zeros(OutSize,1);
DiffxMat=zeros(OutSize,1);
DiffyMat=zeros(OutSize,1);

for i=1:OutSize
    Startcolumn=RegionsMat(i,1);
    Endcolumn=RegionsMat(i,2);
    StartRow=RegionsMat(i,3);
    EndRow=RegionsMat(i,4);
           % J(eR+1,eC+1) - J(eR+1,sC) - J(sR,eC+1) + J(sR,sC)
    AvgMat(i,1)= IntegralFrame(EndRow+1,Endcolumn+1) - IntegralFrame(EndRow+1,Startcolumn) - IntegralFrame(StartRow,Endcolumn+1) + IntegralFrame(StartRow,Startcolumn);
    DiffxMat(i,1)=IntegralDiffx(EndRow+1,Endcolumn+1) - IntegralDiffx(EndRow+1,Startcolumn) - IntegralDiffx(StartRow,Endcolumn+1) + IntegralDiffx(StartRow,Startcolumn);
    DiffyMat(i,1)=IntegralDiffy(EndRow+1,Endcolumn+1) - IntegralDiffy(EndRow+1,Startcolumn) - IntegralDiffy(StartRow,Endcolumn+1) + IntegralDiffy(StartRow,Startcolumn);
end

AvgOut=(AvgMat(ComparisonVector(:,1),1)-AvgMat(ComparisonVector(:,2),1))>0;
DiffxOut=(DiffxMat(ComparisonVector(:,1),1)-DiffxMat(ComparisonVector(:,2),1))>0;
DiffyOut=(DiffyMat(ComparisonVector(:,1),1)-DiffyMat(ComparisonVector(:,2),1))>0;

Output=[AvgOut;DiffxOut;DiffyOut];
