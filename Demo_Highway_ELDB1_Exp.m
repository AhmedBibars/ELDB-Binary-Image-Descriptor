%%%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DatabaseVideoPath='G:\Binary Surf Highway\Night.wmv';
QuaryVideoPath='G:\Binary Surf Highway\Day.wmv';
ImageSize=64;
LDBLevels=4; 
LDBMode=2;                           % 1:linear   2:Exponential 
CoparisonsPerPair=3;       % 3 bits generated for each cell-pair comparison, 5 incase of ELDB2 
SelectedComparisonsNum=1000;       % number of randomly selected cell-pairs
DiscriptorLength=SelectedComparisonsNum*CoparisonsPerPair;
load GroundTruth_Highway;  % groundtruth quary/database equivelant frames, to compare our results with it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode); %randomly select cell-pairs

VidReadObj = VideoReader(DatabaseVideoPath);
DBNumberOfFrames = VidReadObj.NumberOfFrames;
SizeLDBVect=CoparisonsPerPair*size(ComparisonVector,1);      % 5* in case of MLDB & 3* in case of LDB
LDBFrontMat=zeros(DBNumberOfFrames,SizeLDBVect);
LDBRearMat=zeros(DBNumberOfFrames,SizeLDBVect);
LDBSide1Mat=zeros(DBNumberOfFrames,SizeLDBVect);
LDBSide2Mat=zeros(DBNumberOfFrames,SizeLDBVect);
disp('----------------------------------------------------------------------------');
disp('Computing database ELDB descriptors.');

tic
for i=1:DBNumberOfFrames
    Frame= read(VidReadObj,i);
    FrontFrame=Frame(1:175,1281:1792,:);  
    RearFrame=Frame(1:175,257:768,:);
    Side1Frame=Frame(1:175,769:1280,:);
    Side2Frame=[Frame(1:175,1793:2048,:),Frame(1:175,1:256,:)];
    
    GrayFrontFrame=rgb2gray(FrontFrame);%SkyBlackining(FrontFrame);
    GrayRearFrame=rgb2gray(RearFrame);%SkyBlackining(RearFrame);
    GraySide1Frame=rgb2gray(Side1Frame);%SkyBlackining(Side1Frame);
    GraySide2Frame=rgb2gray(Side2Frame);%SkyBlackining(Side2Frame);
    ReducedFrontFrame=imresize(GrayFrontFrame,[ImageSize ,ImageSize]);
    ReducedFrontFrame=LocalNormalize(ReducedFrontFrame,8);  %patch illumination normalization
    LDBFrontMat(i,:)=ELDB1 (ReducedFrontFrame,RegionsMat,ComparisonVector);
    ReducedRearFrame=imresize(GrayRearFrame,[ImageSize ,ImageSize]);
    ReducedRearFrame=LocalNormalize(ReducedRearFrame,8);    %patch illumination normalization
    LDBRearMat(i,:)=ELDB1 (ReducedRearFrame,RegionsMat,ComparisonVector);
    ReducedSide1Frame=imresize(GraySide1Frame,[ImageSize ,ImageSize]);
    ReducedSide1Frame=LocalNormalize(ReducedSide1Frame,8);  %patch illumination normalization
    LDBSide1Mat(i,:)=ELDB1 (ReducedSide1Frame,RegionsMat,ComparisonVector);
    ReducedSide2Frame=imresize(GraySide2Frame,[ImageSize ,ImageSize]);
    ReducedSide2Frame=LocalNormalize(ReducedSide2Frame,8);  %patch illumination normalization
    LDBSide2Mat(i,:)=ELDB1 (ReducedSide2Frame,RegionsMat,ComparisonVector);
end
ProcessingTime=toc;
disp(strcat('Number of database frames =',{' '},num2str(DBNumberOfFrames),' Panoramic frames'));
disp(strcat('Database ELDB discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(DBNumberOfFrames/ProcessingTime), ' Panoramic frames per second')); 
disp('----------------------------------------------------------------------------');

LDBFrontMat=LDBFrontMat>0;
LDBRearMat=LDBRearMat>0;
LDBSide1Mat=LDBSide1Mat>0;
LDBSide2Mat=LDBSide2Mat>0;
LDBDatabase=[LDBFrontMat,LDBRearMat,LDBSide1Mat,LDBSide2Mat];
clear LDBFrontMat LDBRearMat LDBSide1Mat LDBSide2Mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VidReadObj = VideoReader(QuaryVideoPath);
RTNumberOfFrames = VidReadObj.NumberOfFrames;
RtLDBFrontMat=zeros(RTNumberOfFrames,SizeLDBVect);
RtLDBRearMat=zeros(RTNumberOfFrames,SizeLDBVect);
RtLDBSide1Mat=zeros(RTNumberOfFrames,SizeLDBVect);
RtLDBSide2Mat=zeros(RTNumberOfFrames,SizeLDBVect);
tic
disp('Computing Quary frames ELDB descriptors.');
for i=1:RTNumberOfFrames
    Frame= read(VidReadObj,i);
    FrontFrame=Frame(1:175,1281:1792,:);  
    RearFrame=Frame(1:175,257:768,:);
    Side1Frame=Frame(1:175,769:1280,:);
    Side2Frame=[Frame(1:175,1793:2048,:),Frame(1:175,1:256,:)];
    
    GrayFrontFrame=rgb2gray(FrontFrame);%SkyBlackining(FrontFrame);
    GrayRearFrame=rgb2gray(RearFrame);%SkyBlackining(RearFrame);
    GraySide1Frame=rgb2gray(Side1Frame);%SkyBlackining(Side1Frame);
    GraySide2Frame=rgb2gray(Side2Frame);%SkyBlackining(Side2Frame);
    ReducedFrontFrame=imresize(GrayFrontFrame,[ImageSize ,ImageSize]);
    ReducedFrontFrame=LocalNormalize(ReducedFrontFrame,8);  %patch illumination normalization
    RtLDBFrontMat(i,:)=ELDB1 (ReducedFrontFrame,RegionsMat,ComparisonVector);
    ReducedRearFrame=imresize(GrayRearFrame,[ImageSize ,ImageSize]);
    ReducedRearFrame=LocalNormalize(ReducedRearFrame,8);    %patch illumination normalization
    RtLDBRearMat(i,:)=ELDB1 (ReducedRearFrame,RegionsMat,ComparisonVector);
    ReducedSide1Frame=imresize(GraySide1Frame,[ImageSize ,ImageSize]);
    ReducedSide1Frame=LocalNormalize(ReducedSide1Frame,8);  %patch illumination normalization
    RtLDBSide1Mat(i,:)=ELDB1 (ReducedSide1Frame,RegionsMat,ComparisonVector);
    ReducedSide2Frame=imresize(GraySide2Frame,[ImageSize ,ImageSize]);
    ReducedSide2Frame=LocalNormalize(ReducedSide2Frame,8);  %patch illumination normalization
    RtLDBSide2Mat(i,:)=ELDB1 (ReducedSide2Frame,RegionsMat,ComparisonVector);
end
ProcessingTime=toc;
disp(strcat('Number of quary frames =',{' '},num2str(RTNumberOfFrames),' Panoramic frames'));
disp(strcat('Quary frames ELDB discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(RTNumberOfFrames/ProcessingTime), ' Panoramic Frames per second')); 
disp('----------------------------------------------------------------------------');

RtLDBFrontMat=RtLDBFrontMat>0;
RtLDBRearMat=RtLDBRearMat>0;
RtLDBSide1Mat=RtLDBSide1Mat>0;
RtLDBSide2Mat=RtLDBSide2Mat>0;
RTLDBMat=[RtLDBFrontMat,RtLDBRearMat,RtLDBSide1Mat,RtLDBSide2Mat];
clear RtLDBFrontMat RtLDBRearMat RtLDBSide1Mat RtLDBSide2Mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RtDbDistanceMat=zeros(DBNumberOfFrames,RTNumberOfFrames,'single');  % Distance matrix
MatchDiff=zeros(RTNumberOfFrames,1,'single');
CurrentImage=zeros(RTNumberOfFrames,1,'single');
disp('Finding best database-match for each quary frame.');
tic
for i=1:RTNumberOfFrames
    RtDbDistanceMat(:,i)=LDBMatch(RTLDBMat(i,:),LDBDatabase); % Compute Hamming distance between query(i) and each discriptor in the database
    [minval,minLoc]=min(RtDbDistanceMat(:,i));
    MatchDiff(i,1)=minval;   % Hamming distance between quary(i) and its best database-match.
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
Toplot=255*((RtDbDistanceMat-MinV)/(MaxV-MinV));  % put the values in the gray-scale range [0,255] 
Toplot=round(Toplot);
Toplot=uint8(Toplot);
figure;imshow(Toplot);
title('Distance Matrix, Highway, ELDB_{Exp.}');
%%%%Best Match%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;plot(GT(:,1));hold on;
plot(CurrentImage,'x');
xlabel('Quary frame number','FontSize', 20,'FontWeight','bold','Color','k');  % 'bold'/'normal'  'k'=black
ylabel('Database frame number','FontSize', 20,'FontWeight','bold','Color','k');
legend('Ground truth','Best match','Location','Best');

