# ML-PrecMerg: Machine learning (ML) based satellite-gauge precipitation merging apprpoach


This is a MATLAB toolbox used to merge mutiple satellite-based precipiation and gauge observation based on a novel double machine learning (DML) approach.The DML approach was mainly developed based on the classification model of random forest (RF) in combination with the regression models of the machine learning (ML) algorithms including RF, artificial neural network (ANN), support vector machine (SVM) and extreme learning machine (ELM). This led to four DML algorithms, i.e., RF-RF, RF-ANN, RF-SVM, and RF-LM. The optimization of the hyperparamters of the ML algorithms were implemented through the parallel computing-based and grid-research (PC-GR). 

The toolbox can be easily applied to other fields such as ground water level mapping, soil moisture and precipitation downscaling, hydrological predictions, among others. These can be done just by changing the input and output variables. 


# Usage
 The codes in included in the folder Src. TheThe main program is 'Main_Merge_ensemble.m'. We have also uploaded the test data. The user can download the test data, and modify the root folder in the main program 'Main_Merge_ensemble.m'. Then the program can run directly. Note that the SVM algorithm is not a built-in matlab function, the users need to download and install the Libsvm package before running the program. Libsvm package can be downloaded from heree https://www.csie.ntu.edu.tw/~cjlin/libsvm/, The version of your Matlab might not be compatibile with the new version, if so, you can use the 
olde version: https://www.csie.ntu.edu.tw/~cjlin/libsvm/oldfiles/. 


# Citation
> Please cite the program as follows:
Ling Zhang, Xin Li, Donghai Zheng, et al. 2021, Merging satellite-based precipitation and gauge observations using a novel double machine learning approach, Journal of Hydrology

# Contact me
Please feel free to contact me if you have any questions, zhanglingky@lzb.ac.cn
