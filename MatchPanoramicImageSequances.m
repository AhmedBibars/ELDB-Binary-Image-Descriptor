DiscriptorLength=SelectedComparisonsNum*CoparisonsPerPair;

%%%%%%%%%%%%%%%%%%Compute Database descriptors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VidReadObj = VideoReader(DatabaseVideoPath);
DBFramesNumber = VidReadObj.NumberOfFrames;
SizeLDBVect=CoparisonsPerPair*size(ComparisonVector,1);      %=CoparisonsPerPair =5 in case of ELDB2 & =3 in case of ELDB1 and LDB
LDBFrontMat=zeros(DBFramesNumber,SizeLDBVect);
LDBRearMat=zeros(DBFramesNumber,SizeLDBVect);
LDBSide1Mat=zeros(DBFramesNumber,SizeLDBVect);
LDBSide2Mat=zeros(DBFramesNumber,SizeLDBVect);
disp('----------------------------------------------------------------------------');
disp('Computing database ELDB descriptors.');

tic
for i=1:DBFramesNumber
    Frame= read(VidReadObj,i);
    Frame=rgb2gray(Frame);
    CropFrame=Frame(FrameCropStart:FrameCropEnd,:);
    ReducedFrame=imresize(CropFrame,[ImageSize,4*ImageSize]);
    NormFrame=LocalNormalize(ReducedFrame,8);
    LDBFrontMat(i,:)=P_MLDB(NormFrame(:,1:ImageSize),RegionsMat,ComparisonVector);
    LDBRearMat(i,:)=P_MLDB(NormFrame(:,ImageSize+1:2*ImageSize),RegionsMat,ComparisonVector);
    LDBSide1Mat(i,:)=P_MLDB(NormFrame(:,2*ImageSize+1:3*ImageSize),RegionsMat,ComparisonVector);
    LDBSide2Mat(i,:)=P_MLDB(NormFrame(:,3*ImageSize+1:4*ImageSize),RegionsMat,ComparisonVector);
end
ProcessingTime=toc;
disp(strcat('Number of database frames =',{' '},num2str(DBFramesNumber),' Panoramic frames'));
disp(strcat('Database discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(DBFramesNumber/ProcessingTime), ' Panoramic frames per second')); 
disp('----------------------------------------------------------------------------');

LDBFrontMat=LDBFrontMat>0;
LDBRearMat=LDBRearMat>0;
LDBSide1Mat=LDBSide1Mat>0;
LDBSide2Mat=LDBSide2Mat>0;
DBDescriptorsMat=[LDBFrontMat,LDBRearMat,LDBSide1Mat,LDBSide2Mat];
clear LDBFrontMat LDBRearMat LDBSide1Mat LDBSide2Mat

%%%%%%%%%%%%%%%%%%%Compute Quaries frames descriptors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VidReadObj = VideoReader(QuaryVideoPath);
QuaryFramesNumber = VidReadObj.NumberOfFrames;
RtLDBFrontMat=zeros(QuaryFramesNumber,SizeLDBVect);
RtLDBRearMat=zeros(QuaryFramesNumber,SizeLDBVect);
RtLDBSide1Mat=zeros(QuaryFramesNumber,SizeLDBVect);
RtLDBSide2Mat=zeros(QuaryFramesNumber,SizeLDBVect);
tic
disp('Computing Quary frames ELDB descriptors.');
for i=1:QuaryFramesNumber
    Frame= read(VidReadObj,i);
    Frame=rgb2gray(Frame);
    CropFrame=Frame(FrameCropStart:FrameCropEnd,:);
    ReducedFrame=imresize(CropFrame,[ImageSize,4*ImageSize]);
    NormFrame=LocalNormalize(ReducedFrame,8);
    RtLDBFrontMat(i,:)=P_MLDB(NormFrame(:,1:ImageSize),RegionsMat,ComparisonVector);
    RtLDBRearMat(i,:)=P_MLDB(NormFrame(:,ImageSize+1:2*ImageSize),RegionsMat,ComparisonVector);
    RtLDBSide1Mat(i,:)=P_MLDB(NormFrame(:,2*ImageSize+1:3*ImageSize),RegionsMat,ComparisonVector);
    RtLDBSide2Mat(i,:)=P_MLDB(NormFrame(:,3*ImageSize+1:4*ImageSize),RegionsMat,ComparisonVector);
end
ProcessingTime=toc;
disp(strcat('Number of quary frames =',{' '},num2str(QuaryFramesNumber),' Panoramic frames'));
disp(strcat('Quary frames ELDB discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(QuaryFramesNumber/ProcessingTime), ' Panoramic Frames per second')); 
disp('----------------------------------------------------------------------------');

RtLDBFrontMat=RtLDBFrontMat>0;
RtLDBRearMat=RtLDBRearMat>0;
RtLDBSide1Mat=RtLDBSide1Mat>0;
RtLDBSide2Mat=RtLDBSide2Mat>0;
QuaryDescriptorsMat=[RtLDBFrontMat,RtLDBRearMat,RtLDBSide1Mat,RtLDBSide2Mat];
clear RtLDBFrontMat RtLDBRearMat RtLDBSide1Mat RtLDBSide2Mat

%%%%%%%%%%%%%%%%%%%%%%%%%%Matching%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DistanceMatrix=zeros(DBFramesNumber,QuaryFramesNumber,'single'); % Distance matrix
MatchDiff=zeros(QuaryFramesNumber,1,'single');
CurrentImage=zeros(QuaryFramesNumber,1,'single');
disp('Finding best database-match for each quary frame.');
tic
for i=1:QuaryFramesNumber
    DistanceMatrix(:,i)=LDBMatch(QuaryDescriptorsMat(i,:),DBDescriptorsMat); % Compute Hamming distance between query(i) and each discriptor in the database
    [minval,minLoc]=min(DistanceMatrix(:,i));
    MatchDiff(i,1)=minval; % Hamming distance between quary(i) and its best database-match. 
    CurrentImage(i,1)=minLoc; % best database-match
    %i
end
ProcessingTime=toc;
disp(strcat('Avarage processing time of finding database match for a query frame =',{' '},num2str(ProcessingTime/QuaryFramesNumber),' sec.'));
display(strcat('Matching Rate =',{' '},num2str(QuaryFramesNumber/ProcessingTime),' Query frames per second'));
disp('----------------------------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Compute matching accuricy%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diff_V=abs(CurrentImage-GT(:,1));
CorrectLocalization=diff_V<21;
Result=sum(CorrectLocalization);
disp(strcat('Result:',{' '},num2str(Result),' correctly matched frames'));
Result=100*sum(CorrectLocalization)/(QuaryFramesNumber);
disp(strcat('Percent of correctly matched quary frames =',{' '}, num2str(Result), ' %'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Precision-Recall%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Recall,Precision]=PrecisionRecall(GT(:,1),CurrentImage,MatchDiff);