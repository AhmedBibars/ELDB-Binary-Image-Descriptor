# ELDB-Binary-image-discriptor
This project introduces ELDB binary image descriptor. This descriptor is used as a global image descriptor for place recognition applications. ELDB descriptor represents an extension to the Local Difference Binary (LDB) binary image descriptor that enhances its: ) image matching accuracy, 2) robustness against appearance changes, and 3) its computational efficiency.

To compute the ELDB descriptor of an image. First, the locations of the randomly selected image-cells pairs should be determined using SelectCellPairs function. Then, the descriptor is computed using ELDB1 function. As the following:


```
Mode=1;         % 1: Linear growing grid, 2: Exponential growing grid.
ImageSize=64;   % Reduced image side-size
LevelsNum=15;   % Maximium grid side-size   (here maximium grid is of size 15X15 cells)
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode);         %randomly select cell-pairs
ReducedSizeImage=imresize(rgeb2gary(image),[ImageSize,ImageSize]);
ELDB_Descriptor=ELDB1(ReducedSizeImage,RegionsMat,ComparisonVector);
```
To match an ELDB image descriptor with database matrix, each or its rows represents an ELDB descriptor of certain image, you can use LDBMatch function. This function generates a difference vector, each of each elements represents the Hamming distance between the input image and certain database image-descriptor. As the following:

```
DistanceVector=LDBMatch(QuaryImageDescriptor,DatabaseDescriptorsMatrix);
```

The two files MatchImageSequances and MatchPanoramicImageSequances are used to match images in two regular videos or two panormanic vedios, respectivly. Before calling any of the two files, the following parameters has to be defied:
- DatabaseVideoPath: path of the database video.
- QuaryVideoPath: path of the queries images video.
- ImageSize=64:   side-size of the downsized image that will be used to generate the descriptor.
- SelectedComparisonsNum: number of randomly selected cell-pairs for each image (or for each sub-image in case of panoramic videos).
- CoparisonsPerPair=3  : number of generated bits from each cell-pair comparison; =3 in case of ELDB1 and LDB, and =5 in case of ELDB2. 
- LDBLevels: number of grid levels (number of the levels in the image-pyramid).
- LDBMode:  =1 to select linear growing grid   =2 to select exponential growing grid.
- P_MLDB: pointer to descriptor function. =@ELDB1 to select ELDB descriptor, or =@LDB to select LDB descriptor.

The following code show an example for using MatchImageSequances:

```
%%%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DatabaseVideoPath='G:\Nordland old\day1_orig.avi';
QuaryVideoPath='G:\Nordland old\night1_orig.avi';
ImageSize=64;  %redused image size
CoparisonsPerPair=3;       % 3 bits generated for each cell-pair comparison, 5 incase of ELDB2 
SelectedComparisonsNum=4000;       % number of randomly selected cell-pairs
ImagePreProcessing=@rgb2gray;  %@rgb2gray, or@SkyBlackining to select Sky-Blacking option. 
LDBLevels=5;                   %number of grid levels.
LDBMode=2;                           % 1:linear   2:Exponential 
P_MLDB=@ELDB1;                 % pointer to ELDB1 function;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load GroundTruth_Alderlay;  % groundtruth quary/database equivelant frames, to compare our results with it.
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode); %randomly select cell-pairs
MatchImageSequances;   %Match the two image sequences
```


The Demos presented in this project measure the accuracy of the ELDB descriptor when used for place recognition by single-image matching. The datasets used are: 
1- Alderlay day/night dataset.
2- Surfares Paradise dataset.
3- Highway dataset.
4- CBD dataset.
Each of this datasets contains two videos, one is recorded at day time, while the other is recorded at nights. One of the two videos is considered as an image database, while the other is considered as a real-time image-queries.

The videos of the datasets are available at the following website of Queensland university of technology (QUT):
https://wiki.qut.edu.au/display/cyphy/Datasets
