# ELDB-Binary-image-descriptor
This project introduces ELDB binary image descriptor. This descriptor is used as a global image descriptor for place recognition applications. It represents an extension to the Local Difference Binary (LDB) image descriptor, that enhances its: 1) image matching accuracy, 2) robustness against appearance changes, and 3) its computational efficiency.

To compute the ELDB descriptor of an image. First, the locations of the randomly selected image-cells pairs should be determined using SelectCellPairs function. Then, the image is downscaled and normalized. then finally, the descriptor is computed using ELDB1 function. As the following:


```
Mode=1;         % 1: Linear growing grid, 2: Exponential growing grid.
ImageSize=64;   % Reduced image side-size
LevelsNum=15;   % Maximium grid side-size   (here maximium grid is of size 16X16 cells)
SelectedComparisonsNum=4000;  % Number of randomly selected cell-pairs.
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LevelsNum,Mode);         %randomly select cell-pairs
ReducedSizeImage=imresize(rgb2gray(Image),[ImageSize,ImageSize]);
NormalizedImage=LocalNormalize(ReducedSizeImage,8);  % Patch illumination normalization.
Descriptor=ELDB1(NormalizedImage,RegionsMat,ComparisonVector);
```
Note that, patch illumination normalization has to be performed for any image before computing its ELDB descriptor. 

Another alternative method to compute the ELDB descriptor of an image is to use the class "ELDB_Descriptor". This class contains some default values for the different parameters, that can be changed if needed. The following code illustrates how to use this class to compute both ELDB and LDB descriptors of an image:

```
Descriptor1=ELDB_Descriptor; % create object of the class
Descriptor1=Descriptor1.SelectRandomCellPairs;  %randomly select cell-pairs
Descriptor_ELDB=Descriptor1.ELDB(Image);     % compute ELDB descriptor of "Image". "Image" should be 3 channels colored image.
Descriptor_LDB=Descriptor1.LDB(Image);       % compute LDB descriptor of "Image".
```


To match an ELDB image descriptor with database matrix, each or its rows represents an ELDB descriptor of certain image, you can use LDBMatch function. This function generates a difference vector, each of each elements represents the Hamming distance between the input image and certain database image-descriptor. As the following:

```
DistanceVector=LDBMatch(QueryImageDescriptor,DatabaseDescriptorsMatrix);
```

The two files MatchImageSequances.m and MatchPanoramicImageSequances.m are used to match images in two regular videos or two panoramic videos, respectively. Before calling any of the two files, the following parameters have to be defined:
- DatabaseVideoPath: path of the database video.
- QuaryVideoPath: path of the query-images video.
- ImageSize:   side-size of the downsized image that will be used to generate the descriptor.
- SelectedComparisonsNum: number of randomly selected cell-pairs for each image (or for each sub-image in case of panoramic videos).
- CoparisonsPerPair: number of generated bits from each cell-pair comparison; =3 in case of ELDB1 and LDB, and =5 in case of ELDB2. 
- LDBLevels: number of grid levels (number of the levels in the image-pyramid).
- LDBMode:  =1 to select linear growing grid, or =2 to select exponential growing grid.
- P_MLDB: pointer to descriptor function. =@ELDB1 to select ELDB descriptor, or =@LDB to select LDB descriptor.

The following code show an example for using MatchImageSequances:

```
%%%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DatabaseVideoPath='G:\Nordland old\day1_orig.avi';    % Change to the path of database video.
QueryVideoPath='G:\Nordland old\night1_orig.avi';     % Change to the path of query-images video.
ImageSize=64;  %reduced image size
CoparisonsPerPair=3;       % 3 bits generated for each cell-pair comparison, 5 incase of ELDB2 
SelectedComparisonsNum=4000;       % number of randomly selected cell-pairs
ImagePreProcessing=@rgb2gray;  %@rgb2gray, or @SkyBlackining to select Sky-Blacking option. 
LDBLevels=5;                   %number of grid levels.
LDBMode=2;                           % 1:linear   2:Exponential 
P_MLDB=@ELDB1;                 % pointer to ELDB1 function;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load GroundTruth_Alderlay;  % groundtruth query/database equivelant frames, to compare matching results with it.
[RegionsMat,ComparisonVector]=SelectCellPairs(SelectedComparisonsNum,ImageSize,LDBLevels,LDBMode); %randomly select cell-pairs
MatchImageSequances;   %Match the two image sequences
```


The demos presented in this project measure the accuracy of the ELDB descriptor when used for place recognition by single-image matching. The datasets used are: 
1- Alderlay day/night dataset.
2- Surfares Paradise dataset.
3- Highway dataset.
4- CBD dataset.
Each of these datasets contains two videos, one is recorded at day time, while the other is recorded at nights. One of the two videos is considered as an image database, while the other is considered as a real-time image-queries.

The videos of the datasets are available at the following website of Queensland university of technology (QUT):
https://wiki.qut.edu.au/display/cyphy/Datasets
