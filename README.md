# ELDB-Binary-image-discriptor
This project introduces ELDB binary image descriptor. This descriptor is used as a global image discriptor for place recogntion applications.
ELDB represents an extenstion to the Local Diffrence Binary (LDB) binary image discriptor that enhances its: ) image matching accuricy, 2) robustness againest apperance changes, and 3) its computional effeciency.

To compute the ELDB discriptor of an image. First, the locations of the randomly selected image-cells pairs should be determined using SelectCellPairs function. Then, the discriptor is computed using ELDB1 function. As the following:

```
Mode=1;         % 1: Linear growing grid, 2: Exponential growing grid.
ImageSize=64;   % Reduced image side-size
LevelsNum=15;   % Maximium grid side-size   (here maximium grid is of size 15X15 cells)
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode);         %randomly select cell-pairs
ReducedSizeImage=imresize(rgeb2gary(image),[ImageSize,ImageSize]);
ELDB_Descriptor=ELDB1(ReducedSizeImage,RegionsMat,ComparisonVector);
```
To match an ELDB image descriptor with database martix, each or its rows represents an ELDB discriptor of certain image, you can use LDBMatch function. This function generats a diffrence vector, each of each elements represents the Hamming distance between the input image and certain database image-descriptor. As the following:

```
DistanceVector=LDBMatch(QuaryImageDescriptor,DatabaseDescriptorsMatrix);
```

The two files MatchImageSequances and MatchPanoramicImageSequances are used to match images in two regular videos or two panormanic vedios, respectivly. Before calling any of the two files, the following parameters has to be defied:
- DatabaseVideoPath: path of the database video.
- QuaryVideoPath: path of the quaries images video.
- ImageSize=64:   side-size of the downsized image that will be used to generate the discriptor.
- SelectedComparisonsNum: number of randomly selected cell-pairs for each image (or for each sub-image in case of panoramic videos).
- CoparisonsPerPair=3  : number of generated bits from each cell-pair comparison; =3 in case of ELDB1 and LDB, and =5 incase of ELDB2.    - LDBLevels: number of grid levels (number of the levels in the image-pyramid).
- LDBMode:      =1 to select linear growing grid   =2 to select exponential growing grid.
- P_MLDB: pointer to desriptor function. =@ELDB1 to select ELDB descriptir, or =@LDB to select LDB descriptor.

The following code show an example for using MatchImageSequances:

```
%%%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DatabaseVideoPath='G:\Binary Surf Highway\Night.wmv';
QuaryVideoPath='G:\Binary Surf Highway\Day.wmv';
ImageSize=64;   %redused image size
FrameCropStart=33;FrameCropEnd=172; %interest area in the frame (vertical limits).
CoparisonsPerPair=3;       % 3 bits generated for each cell-pair comparison, 5 incase of ELDB2. 
SelectedComparisonsNum=1000;       % number of randomly selected cell-pairs per sub-image (each frame is divided to 4 sub-images).
load GroundTruth_Highway;  % groundtruth quary/database equivelant frames, to compare our results with it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%1- ELDB Exponential
LDBLevels=4;
LDBMode=2;                           % 1:linear   2:Exponential 
P_MLDB=@ELDB1; % pointer to ELDB1 function;
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode); %randomly select cell-pairs
MatchPanoramicImageSequances;   %Match the two panoramic image sequences
```


The Demos presented in this project measure the accuricy of ELDB when used for place recgnition by single-image matching. The datasets used are:
1- Alderlay day/night dataset.
2- Surfares Paradise dataset.
3- Highway dataset.
4- CBD dataset.
Each of this datasets contains two videos, one is recoreded at day time, while the other is recoreded at nights. One of the two videos is considered as an image database, while the other is considered as a real-time image-queries.

The videos of the datasets are avilable at the following website of queensland university of technology (QUT):
https://wiki.qut.edu.au/display/cyphy/Datasets


