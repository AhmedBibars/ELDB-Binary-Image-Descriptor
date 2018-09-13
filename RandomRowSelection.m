function [OutputMat]= RandomRowSelection(InputMat,SelectedNum)
InputMatSize=size(InputMat,1);
RandomIndexes = randperm(InputMatSize); % randperm(InputMatSize+1)
RandomIndexes=RandomIndexes(1:SelectedNum); %RandomIndexes(1:SelectedNum)-1
OutputMat=InputMat(RandomIndexes,:);