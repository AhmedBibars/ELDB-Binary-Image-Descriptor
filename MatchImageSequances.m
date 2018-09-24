DiscriptorLength=SelectedComparisonsNum*CoparisonsPerPair;

%%%%%%%%%%%%%%%%%%Compute Database descriptors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VidReadObj = VideoReader(DatabaseVideoPath);
DBFramesNumber = VidReadObj.NumberOfFrames;
SizeLDBVect=CoparisonsPerPair*size(ComparisonVector,1);      %=CoparisonsPerPair =5 in case of ELDB2 & =3 in case of ELDB1 and LDB
DBDescriptorsMat=zeros(DBFramesNumber,SizeLDBVect);
disp('----------------------------------------------------------------------------');
disp('Computing database frames descriptors.')
tic
for i=1:DBFramesNumber
    Frame= read(VidReadObj,i);   
    %GrayFrontFrame=rgb2gray(Frame);
    GrayFrontFrame=SkyBlackining(Frame);
    ReducedFrontFrame=imresize(GrayFrontFrame,[ImageSize ,ImageSize]);
    ReducedFrontFrame=LocalNormalize(ReducedFrontFrame,8); % patch illumination normalization
    DBDescriptorsMat(i,:)=P_MLDB(ReducedFrontFrame,RegionsMat,ComparisonVector);
    %i
end
DBDescriptorsMat=DBDescriptorsMat>0; % convert to binary format.
ProcessingTime=toc;
disp(strcat('Number of database frames = ',{' '},num2str(DBFramesNumber),' frames'));
disp(strcat('Database frames discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(DBFramesNumber/ProcessingTime), ' Frames per second')); 
disp('----------------------------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%Compute Quaries frames descriptors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VidReadObj = VideoReader(QuaryVideoPath);
QuaryFramesNumber = VidReadObj.NumberOfFrames;
QuaryDescriptorsMat=zeros(QuaryFramesNumber,SizeLDBVect);
tic
disp('Computing Quary frames descriptors.')
for i=1:QuaryFramesNumber
    Frame= read(VidReadObj,i);
    GrayFrontFrame=rgb2gray(Frame);%SkyBlackining(FrontFrame);
    ReducedFrontFrame=imresize(GrayFrontFrame,[ImageSize ,ImageSize]);
    ReducedFrontFrame=LocalNormalize(ReducedFrontFrame,8); % patch illumination normalization
    QuaryDescriptorsMat(i,:)=P_MLDB(ReducedFrontFrame,RegionsMat,ComparisonVector);
    %i
end
QuaryDescriptorsMat=QuaryDescriptorsMat>0; % convert to binary format.
ProcessingTime=toc;
disp(strcat('Number of quary frames =',{' '},num2str(QuaryFramesNumber),' frames'));
disp(strcat('Quary frames discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(QuaryFramesNumber/ProcessingTime), ' Frames per second')); 
disp('----------------------------------------------------------------------------');

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
