%%%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DatabaseVideoPath='G:\SURF Features\Day.wmv';FrameCropStart=172;%172%175
QueryVideoPath='G:\SURF Features\Night.wmv';
ImageSize=64;    %reduced image size
FrameCropStart=7;FrameCropEnd=172; %interest area in the frame (vertical limits).
ComparisonsPerPair=3;       % 3 bits generated for each cell-pair comparison, 5 incase of ELDB2. 
SelectedComparisonsNum=1000;       % number of randomly selected cell-pairs per sub-image (each frame is divided to 4 sub-images).
load GroundTruth_CBD;  % groundtruth quary/database equivelant frames, to compare our results with it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%1- ELDB Exponential
LDBLevels=4;
LDBMode=2;                           % 1:linear   2:Exponential 
P_MLDB=@ELDB1; % pointer to ELDB1 function;
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode); %randomly select cell-pairs
MatchPanoramicImageSequances;  %Match the two panoramic image sequences

figure;plot(Recall,Precision);
axis([0 100 0 100]);grid;
xlabel('Recall');ylabel('Precision');
title('Precision-Recall Curve, ELDB_{Exp.}');
%%%Display Distance matrix.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaxV=max(max(DistanceMatrix));
MinV=min(min(DistanceMatrix));
DistanceMatrixDisplay=255*((DistanceMatrix-MinV)/(MaxV-MinV)); % put the values in the gray-scale range: [0,255]
DistanceMatrixDisplay=uint8(round(DistanceMatrixDisplay));
figure;imshow(DistanceMatrixDisplay);
title('Distance Matrix, CBD-ELDB_{Exp.}');
%%%%Best Match%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(GT(:,1));hold on;
plot(CurrentImage,'x');
xlabel('Quary frame number','FontSize', 20,'FontWeight','bold','Color','k');  % 'bold'/'normal'  'k'=black
ylabel('Database frame number','FontSize', 20,'FontWeight','bold','Color','k');
legend('Ground truth','Best match','Location','Best');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2- ELDB Linear

LDBLevels=15;
LDBMode=1;     % 1:linear   2:Exponential            
P_MLDB=@ELDB1; % pointer to ELDB1 function;
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode); %randomly select cell-pairs
RegionsMat=round(RegionsMat);
MatchPanoramicImageSequances;  %Match the two panoramic image sequences

figure;plot(Recall,Precision);
axis([0 100 0 100]);grid;
xlabel('Recall');ylabel('Precision');
title('Precision-Recall Curve, ELDB_{Linear}');
%%%Display Distance matrix.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaxV=max(max(DistanceMatrix));
MinV=min(min(DistanceMatrix));
DistanceMatrixDisplay=255*((DistanceMatrix-MinV)/(MaxV-MinV)); % put the values in the gray-scale range: [0,255]
DistanceMatrixDisplay=uint8(round(DistanceMatrixDisplay));
figure;imshow(DistanceMatrixDisplay);
title('Distance Matrix, CBD-ELDB_{Linear}');
%%%%Best Match%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(GT(:,1));hold on;
plot(CurrentImage,'x');
xlabel('Quary frame number','FontSize', 20,'FontWeight','bold','Color','k');  % 'bold'/'normal'  'k'=black
ylabel('Database frame number','FontSize', 20,'FontWeight','bold','Color','k');
legend('Ground truth','Best match','Location','Best');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3- LDB Linear

LDBLevels=15;
LDBMode=1;   % 1:linear   2:Exponential              
P_MLDB=@LDB; % pointer to ELDB1 function;
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode); %randomly select cell-pairs
RegionsMat=round(RegionsMat);
MatchPanoramicImageSequances;  %Match the two panoramic image sequences

figure;plot(Recall,Precision);
axis([0 100 0 100]);grid;
xlabel('Recall');ylabel('Precision');
title('Precision-Recall Curve, LDB');
%%%Display Distance matrix.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaxV=max(max(DistanceMatrix));
MinV=min(min(DistanceMatrix));
DistanceMatrixDisplay=255*((DistanceMatrix-MinV)/(MaxV-MinV)); % put the values in the gray-scale range: [0,255]
DistanceMatrixDisplay=uint8(round(DistanceMatrixDisplay));
figure;imshow(DistanceMatrixDisplay);
title('Distance Matrix, CBD-LDB');
%%%%Best Match%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(GT(:,1));hold on;
plot(CurrentImage,'x');
xlabel('Quary frame number','FontSize', 20,'FontWeight','bold','Color','k');  % 'bold'/'normal'  'k'=black
ylabel('Database frame number','FontSize', 20,'FontWeight','bold','Color','k');
legend('Ground truth','Best match','Location','Best');
