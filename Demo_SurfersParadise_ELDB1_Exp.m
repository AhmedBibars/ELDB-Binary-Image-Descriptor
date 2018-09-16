%%%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DatabaseVideoPath='G:\surfars paradise\Day_Modified.avi';
QuaryVideoPath='G:\surfars paradise\Night_Modified.avi';
ImageSize=64;
LDBLevels=5;
LDBMode=2;                           % 1:linear   2:Exponential 
CoparisonsPerPair=3;       % 3 bits generated for each cell-pair comparison, 5 incase of ELDB2 
SelectedComparisonsNum=4000;       % number of randomly selected cell-pairs
DiscriptorLength=SelectedComparisonsNum*CoparisonsPerPair;
load GroundTruth_SurfersParadise;  % groundtruth quary/database equivelant frames, to compare our results with it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode); %randomly select cell-pairs

VidReadObj = VideoReader(DatabaseVideoPath);
DBNumberOfFrames = VidReadObj.NumberOfFrames;
SizeLDBVect=CoparisonsPerPair*size(ComparisonVector,1);      % 5* in case of MLDB & 3* in case of LDB
LDBFrontMat=zeros(DBNumberOfFrames,SizeLDBVect);
disp('----------------------------------------------------------------------------');
disp('Computing database ELDB descriptors.')
tic
for i=1:DBNumberOfFrames
    Frame= read(VidReadObj,i);   
    %GrayFrontFrame=rgb2gray(Frame);
    GrayFrontFrame=SkyBlackining(Frame);
    ReducedFrontFrame=imresize(GrayFrontFrame,[ImageSize ,ImageSize]);
    ReducedFrontFrame=LocalNormalize(ReducedFrontFrame,8); % patch illumination normalization
    LDBFrontMat(i,:)=ELDB1(ReducedFrontFrame,RegionsMat,ComparisonVector);
    %i
end
ProcessingTime=toc;
disp(strcat('Number of database frames = ',{' '},num2str(DBNumberOfFrames),' frames'));
disp(strcat('Database ELDB discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(DBNumberOfFrames/ProcessingTime), ' Frames per second')); 
disp('----------------------------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VidReadObj = VideoReader(QuaryVideoPath);
RTNumberOfFrames = VidReadObj.NumberOfFrames;
RtLDBFrontMat=zeros(RTNumberOfFrames,SizeLDBVect);
tic
disp('Computing Quary frames ELDB descriptors.')
for i=1:RTNumberOfFrames
    Frame= read(VidReadObj,i);
    GrayFrontFrame=rgb2gray(Frame);%SkyBlackining(FrontFrame);
    ReducedFrontFrame=imresize(GrayFrontFrame,[ImageSize ,ImageSize]);
    ReducedFrontFrame=LocalNormalize(ReducedFrontFrame,8); % patch illumination normalization
    RtLDBFrontMat(i,:)=ELDB1(ReducedFrontFrame,RegionsMat,ComparisonVector);
    %i
end
ProcessingTime=toc;
disp(strcat('Number of quary frames =',{' '},num2str(RTNumberOfFrames),' frames'));
disp(strcat('Quary frames ELDB discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(RTNumberOfFrames/ProcessingTime), ' Frames per second')); 
disp('----------------------------------------------------------------------------');

RtLDBFrontMat=RtLDBFrontMat>0;
LDBFrontMat=LDBFrontMat>0;
LDBDatabase=[LDBFrontMat];%,LDBRearMat,LDBSide1Mat,LDBSide2Mat];
RTLDBMat=[RtLDBFrontMat];%,RtLDBRearMat,RtLDBSide1Mat,RtLDBSide2Mat];
clear LDBFrontMat RtLDBFrontMat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RtDbDistanceMat=zeros(DBNumberOfFrames,RTNumberOfFrames,'single'); % Distance matrix
MatchDiff=zeros(RTNumberOfFrames,1,'single');
CurrentImage=zeros(RTNumberOfFrames,1,'single');
disp('Finding best database-match for each quary frame.');
tic
for i=1:RTNumberOfFrames
    RtDbDistanceMat(:,i)=LDBMatch(RTLDBMat(i,:),LDBDatabase); % Compute Hamming distance between query(i) and each discriptor in the database
    [minval,minLoc]=min(RtDbDistanceMat(:,i));
    MatchDiff(i,1)=minval; % Hamming distance between quary(i) and its best database-match. 
    CurrentImage(i,1)=minLoc; % best database-match
    %i
end
ProcessingTime=toc;
disp(strcat('Avarage processing time of finding database match for a query frame =',{' '},num2str(ProcessingTime/RTNumberOfFrames),' sec.'));
display(strcat('Matching Rate =',{' '},num2str(RTNumberOfFrames/ProcessingTime),' Query frames per second'));
disp('----------------------------------------------------------------------------');

diff_V=abs(CurrentImage-GT(:,1));
CorrectLocalization=diff_V<21;
Result=sum(CorrectLocalization);
disp(strcat('Result:',{' '},num2str(Result),' correctly matched frames'));
Result=100*sum(CorrectLocalization)/(RTNumberOfFrames);
disp(strcat('Percent of correctly matched quary frames =',{' '}, num2str(Result), ' %'));
%%%%Precision-Recall%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Recall,Precision]=PrecisionRecall(GT(:,1),CurrentImage,MatchDiff);
figure;plot(Recall,Precision);
axis([0 100 0 100]);grid;
title('Precision-Recall Curve');
%%%Display Distance matrix.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaxV=max(max(RtDbDistanceMat));
MinV=min(min(RtDbDistanceMat));
Toplot=255*((RtDbDistanceMat-MinV)/(MaxV-MinV)); % put the values in the gray-scale range [0,255]
Toplot=round(Toplot);
Toplot=uint8(Toplot);
figure;imshow(Toplot);
title('Distance Matrix, Surfers Paradise-ELDB_{Exp.}');
%%%%Best Match%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(GT(:,2));hold on;
plot(CurrentImage,'x');
xlabel('Quary frame number','FontSize', 20,'FontWeight','bold','Color','k');  % 'bold'/'normal'  'k'=black
ylabel('Database frame number','FontSize', 20,'FontWeight','bold','Color','k');
legend('Ground truth','Best match','Location','Best');