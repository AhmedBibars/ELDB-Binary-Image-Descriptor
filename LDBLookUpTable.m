function [RegionsMat,ComparisonVector]= LDBLookUpTable (ImageSize,LevelsNum,Mode)  %Mode=1(linear),=2(Exp)

if Mode==1
    OutputSize= (LevelsNum+1)*(LevelsNum+2)*(2*(LevelsNum+1)+1)/6 -1;
    RegionsMat=zeros(OutputSize,4);
    i=1;
    for Level=1:LevelsNum
        Step_size=ImageSize/(Level+1);
        for V=1:Level+1
            for H=1:Level+1
                RegionsMat(i,1)=1+(V-1)*Step_size;
                RegionsMat(i,2)=V*Step_size;
                RegionsMat(i,3)=1+(H-1)*Step_size;
                RegionsMat(i,4)=H*Step_size;
                i=i+1;
            end
        end
    end

    Vector1=[];
    Vector2=[];

    for Level=1:LevelsNum
        GredLengh=Level+1;
        Shift=(Level)*(Level+1)*(2*(Level)+1)/6 -1;      
        for vc1=1:GredLengh*GredLengh-1
            Vector1=[Vector1;vc1*ones(GredLengh*GredLengh-vc1,1)+Shift];
            V=[[(vc1+1):1:GredLengh*GredLengh]']+Shift;
            Vector2=[Vector2;V];
        end
    end
    RegionsMat=round(RegionsMat);
else
    OutputSize=(1-4^(LevelsNum+1))/(-3)-1; %(LevelsNum+1)*(LevelsNum+2)*(2*(LevelsNum+1)+1)/6 -1;
    RegionsMat=zeros(OutputSize,4);
    i=1;
    for Level=1:LevelsNum
        Step_size=ImageSize/(2^Level);
        for V=1:2^Level
            for H=1:2^Level
                RegionsMat(i,1)=1+(V-1)*Step_size;
                RegionsMat(i,2)=V*Step_size;
                RegionsMat(i,3)=1+(H-1)*Step_size;
                RegionsMat(i,4)=H*Step_size;
                i=i+1;
            end
        end
    end
    
    Vector1=[];
    Vector2=[];
    for Level=1:LevelsNum
        GredLengh=2^Level;
        Shift=(1-4^(Level))/(-3)-1;
        for vc1=1:GredLengh*GredLengh-1
            Vector1=[Vector1;vc1*ones(GredLengh*GredLengh-vc1,1)+Shift];
            V=[[(vc1+1):1:GredLengh*GredLengh]']+Shift;
            Vector2=[Vector2;V];
        end
    end
end

ComparisonVector=[Vector1,Vector2];