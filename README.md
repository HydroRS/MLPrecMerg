# Satellite-gauge-Precipitaiton-Merging


A tool used to merge mutiple satellite-based precipiation and gauge observation based on the single/double machine learning algorithms including RF, ANN, SVM, EML, RF-RF, RF-ANN, RF-SVM and RF-EML. The optimization of the paramters of the ML algorithms were implemented through the parallel computing technique. 

The program can be easily applied to other fields such as ground water level mapping, soil moisture and precipitation downscaling, hydrological predictions, among others. These can be done just by changing the input and output variables. 


Please feel free to contact me if you have any questions, zhanglingky@lzb.ac.cn

# Usage
 The codes in included in the folder Src. TheThe main program is 'Main_Merge_ensemble.m'. We have also uploaded the test data. The user can download the test data, and modify the root folder in the main program 'Main_Merge_ensemble.m'. Then the program can run directly. Note that the SVM algorithm is not a built-in matlab function, the users need to download and install the Libsvm package before running the program. 


# Citation
> Please cite the program as follows:
Ling Zhang, Xin Li, Qimin Ma, Yanping Cao, Yingchun Ge. 2020, Merging satellite-based precipitation and gauge observations using a novel double machine learning approach (in preparation)

