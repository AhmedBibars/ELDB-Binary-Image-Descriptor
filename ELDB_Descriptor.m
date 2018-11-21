classdef ELDB_Descriptor
   properties
      DescriptorLength=12000;          % Descriptor length in bits.
      DescriptorMode=1;                % Modes 1:Linear grawing grids,  2: Exponential grawing grids
      LDBLevelsNum=15;                 % number of grid levels.
      ReducedImageSize=64;             % reduces image size,  default setting 64x64 pixels.
      IlluminationNormalize=1;         % perform patch-illumination-normalization for the images before computing the descriptor.
      RegionsMat;                      % image-cells reagions.
      ComparisonVector;                % selected cell-pairs numbers.
   end
   methods
      function obj=SelectRandomCellPairs (obj)  %Mode=1(linear),=2(Exp)

         if obj.DescriptorMode==1
            OutputSize= (obj.LDBLevelsNum+1)*(obj.LDBLevelsNum+2)*(2*(obj.LDBLevelsNum+1)+1)/6 -1;
            obj.RegionsMat=zeros(OutputSize,4);
            i=1;
            for Level=1:obj.LDBLevelsNum
                Step_size=obj.ReducedImageSize/(Level+1);
                for V=1:Level+1
                    for H=1:Level+1
                        obj.RegionsMat(i,1)=1+(V-1)*Step_size;
                        obj.RegionsMat(i,2)=V*Step_size;
                        obj.RegionsMat(i,3)=1+(H-1)*Step_size;
                        obj.RegionsMat(i,4)=H*Step_size;
                        i=i+1;
                    end
                end
            end

            Vector1=[];
            Vector2=[];

            for Level=1:obj.LDBLevelsNum
                GredLengh=Level+1;
                Shift=(Level)*(Level+1)*(2*(Level)+1)/6 -1;      
                for vc1=1:GredLengh*GredLengh-1
                    Vector1=[Vector1;vc1*ones(GredLengh*GredLengh-vc1,1)+Shift];
                    V=[[(vc1+1):1:GredLengh*GredLengh]']+Shift;
                    Vector2=[Vector2;V];
                end
            end
            obj.RegionsMat=round(obj.RegionsMat);
         else
            OutputSize=(1-4^(obj.LDBLevelsNum+1))/(-3)-1; %(obj.LDBLevelsNum+1)*(obj.LDBLevelsNum+2)*(2*(obj.LDBLevelsNum+1)+1)/6 -1;
            obj.RegionsMat=zeros(OutputSize,4);
            i=1;
            for Level=1:obj.LDBLevelsNum
                Step_size=obj.ReducedImageSize/(2^Level);
                for V=1:2^Level
                    for H=1:2^Level
                        obj.RegionsMat(i,1)=1+(V-1)*Step_size;
                        obj.RegionsMat(i,2)=V*Step_size;
                        obj.RegionsMat(i,3)=1+(H-1)*Step_size;
                        obj.RegionsMat(i,4)=H*Step_size;
                        i=i+1;
                    end
                end
            end
    
            Vector1=[];
            Vector2=[];
            for Level=1:obj.LDBLevelsNum
                GredLengh=2^Level;
                Shift=(1-4^(Level))/(-3)-1;
                for vc1=1:GredLengh*GredLengh-1
                    Vector1=[Vector1;vc1*ones(GredLengh*GredLengh-vc1,1)+Shift];
                    V=[[(vc1+1):1:GredLengh*GredLengh]']+Shift;
                    Vector2=[Vector2;V];
                end
            end
         end

         CompinedVector=[Vector1,Vector2]; 
         InputMatSize=size(CompinedVector,1);
         RandomIndexes = randperm(InputMatSize); 
         RandomIndexes=RandomIndexes(1:(obj.DescriptorLength/3)); 
         obj.ComparisonVector=CompinedVector(RandomIndexes,:);
      end
       
      function Descriptor = ELDB(obj,Image)
          Image=rgb2gray(Image);
          ReducedImage=imresize(Image,[obj.ReducedImageSize ,obj.ReducedImageSize]);
          if obj.IlluminationNormalize
              ReducedImage=obj.LocalNormalize(ReducedImage,8);
          end
          
          OutSize=size(obj.RegionsMat,1);
          AbsDiffx=abs([ReducedImage(:,2:size(ReducedImage,2))-ReducedImage(:,1:(size(ReducedImage,2)-1)),zeros(size(ReducedImage,1),1)]);
          AbsDiffy=abs([ReducedImage(1:(size(ReducedImage,1)-1),:)-ReducedImage(2:size(ReducedImage,1),:);zeros(1,size(ReducedImage,2))]);

          IntegralFrame=integralImage(ReducedImage);
          IntegralAbsDiffx=integralImage(AbsDiffx);
          IntegralAbsDiffy=integralImage(AbsDiffy);

          AvgMat=zeros(OutSize,1);
          AbsDiffxMat=zeros(OutSize,1);
          AbsDiffyMat=zeros(OutSize,1);

      for i=1:OutSize
         Startcolumn=obj.RegionsMat(i,1);
         Endcolumn=obj.RegionsMat(i,2);
         StartRow=obj.RegionsMat(i,3);
         EndRow=obj.RegionsMat(i,4);
           % J(eR+1,eC+1) - J(eR+1,sC) - J(sR,eC+1) + J(sR,sC)
         AvgMat(i,1)= IntegralFrame(EndRow+1,Endcolumn+1) - IntegralFrame(EndRow+1,Startcolumn) - IntegralFrame(StartRow,Endcolumn+1) + IntegralFrame(StartRow,Startcolumn);
         AbsDiffxMat(i,1)=IntegralAbsDiffx(EndRow+1,Endcolumn+1) - IntegralAbsDiffx(EndRow+1,Startcolumn) - IntegralAbsDiffx(StartRow,Endcolumn+1) + IntegralAbsDiffx(StartRow,Startcolumn);
         AbsDiffyMat(i,1)=IntegralAbsDiffy(EndRow+1,Endcolumn+1) - IntegralAbsDiffy(EndRow+1,Startcolumn) - IntegralAbsDiffy(StartRow,Endcolumn+1) + IntegralAbsDiffy(StartRow,Startcolumn);
      end

      AvgOut=(AvgMat(obj.ComparisonVector(:,1),1)-AvgMat(obj.ComparisonVector(:,2),1))>0;
      AbsDiffxOut=(AbsDiffxMat(obj.ComparisonVector(:,1),1)-AbsDiffxMat(obj.ComparisonVector(:,2),1))>0;%Thx;
      AbsDiffyOut=(AbsDiffyMat(obj.ComparisonVector(:,1),1)-AbsDiffyMat(obj.ComparisonVector(:,2),1))>0;%Thy;

      Descriptor=[AvgOut;AbsDiffxOut;AbsDiffyOut];
         
      end
      
      function LDB_Descriptor = LDB(obj,Image)
          Image=rgb2gray(Image);
          ReducedImage=imresize(Image,[obj.ReducedImageSize ,obj.ReducedImageSize]);
          if obj.IlluminationNormalize
              ReducedImage=obj.LocalNormalize(ReducedImage,8);
          end
          OutSize=size(obj.RegionsMat,1);
          Diffx=[ReducedImage(:,2:size(ReducedImage,2))-ReducedImage(:,1:(size(ReducedImage,2)-1)),zeros(size(ReducedImage,1),1)];
          Diffy=[ReducedImage(1:(size(ReducedImage,1)-1),:)-ReducedImage(2:size(ReducedImage,1),:);zeros(1,size(ReducedImage,2))];

          IntegralFrame=integralImage(ReducedImage);
          IntegralDiffx=integralImage(Diffx);
          IntegralDiffy=integralImage(Diffy);

          AvgMat=zeros(OutSize,1);
          DiffxMat=zeros(OutSize,1);
          DiffyMat=zeros(OutSize,1);

          for i=1:OutSize
             Startcolumn=obj.RegionsMat(i,1);
             Endcolumn=obj.RegionsMat(i,2);
             StartRow=obj.RegionsMat(i,3);
             EndRow=obj.RegionsMat(i,4);
              % J(eR+1,eC+1) - J(eR+1,sC) - J(sR,eC+1) + J(sR,sC)
             AvgMat(i,1)= IntegralFrame(EndRow+1,Endcolumn+1) - IntegralFrame(EndRow+1,Startcolumn) - IntegralFrame(StartRow,Endcolumn+1) + IntegralFrame(StartRow,Startcolumn);
             DiffxMat(i,1)=IntegralDiffx(EndRow+1,Endcolumn+1) - IntegralDiffx(EndRow+1,Startcolumn) - IntegralDiffx(StartRow,Endcolumn+1) + IntegralDiffx(StartRow,Startcolumn);
             DiffyMat(i,1)=IntegralDiffy(EndRow+1,Endcolumn+1) - IntegralDiffy(EndRow+1,Startcolumn) - IntegralDiffy(StartRow,Endcolumn+1) + IntegralDiffy(StartRow,Startcolumn);
          end

          AvgOut=(AvgMat(obj.ComparisonVector(:,1),1)-AvgMat(obj.ComparisonVector(:,2),1))>0;
          DiffxOut=(DiffxMat(obj.ComparisonVector(:,1),1)-DiffxMat(obj.ComparisonVector(:,2),1))>0;%Thx;
          DiffyOut=(DiffyMat(obj.ComparisonVector(:,1),1)-DiffyMat(obj.ComparisonVector(:,2),1))>0;%Thy;

          LDB_Descriptor=[AvgOut;DiffxOut;DiffyOut];
      end
      
      function NormalizedImage=LocalNormalize(obj,IM,FilterSize)
         % Patch illumination normalization
         Filter1=ones(FilterSize,FilterSize)/(FilterSize*FilterSize);
         num=single(IM)-imfilter(single(IM),Filter1,'replicate');
         den=sqrt(imfilter(num.^2,Filter1,'replicate'));
         den(den<1)=1; %0.0001  To avoid division on small values, because they cause noise in small-variation areas (Like Sky area)
         NormalizedImage=num./den;
      end
   end
end
