function [Recall,Precision]=PrecisionRecall(GroundTruth,ResultVector,MatchDiffVector) 
RTMatchingNum=size(GroundTruth,1); %RT video frames number 
diff_V=abs(ResultVector-GroundTruth);
CorrectLocalization=diff_V<21;%26
% Result=sum(V1)
% Result=100*sum(V1)/(EndImage-StartImage+1)


Recall=zeros(100,1);
Precision=zeros(100,1);

IterationStep=(max(MatchDiffVector)-min(MatchDiffVector))/100;
assignin('base', 'test', IterationStep);
for i=1:100
    AcceptanceLevel=min(MatchDiffVector)+(i)*IterationStep;
    AcceptedPoints=MatchDiffVector<=AcceptanceLevel;
    Recall(i,1)=100*sum(AcceptedPoints)/RTMatchingNum;
    Precision(i,1)=100*sum(bitand(AcceptedPoints,CorrectLocalization))/sum(AcceptedPoints);
end
