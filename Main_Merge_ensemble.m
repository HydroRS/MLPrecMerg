% *************************************************************************
%     Merge satellite and gauge precipitation based on SML and DEML 
%                   By Ling Zhang, zhanglingky@lzb.ac.cn
%
% Chinese Academy of Sciences
% Address: 320 West Donggang Road, Lanzhou 730000, China
% E-mail: zhanglingky@lzb.ac.cn  Web: www.xiaolingzi.com
% ReserchGate: www.researchgate.net/profile/Ling_Zhang65
% Tel: +86-15101205730
% *************************************************************************
%%
clc;clear;

% root folder
Root_folder='D:\Work_2020\MyCodes\Satellite-gauge-Merging\';

% Downloaded Satellite data (Raw data)
IMERG_Folder=[Root_folder,'test_data\SPPs\raw_data\IMERG\'];
SW2RAIN_ASCAT_Folder=[Root_folder,'test_data\SPPs\raw_data\SM2RAIN\'];
PERSIANN_Folder=[Root_folder,'test_data\SPPs\raw_data\PERSIANN\'];
GsMAP_Folder=[Root_folder,'test_data\SPPs\raw_data\GSMaP\'];

% Downloaded Gauge observations 
CMD_Folder=[Root_folder,'test_data\Gauge_observations\raw_data\'];

% The observations at all the gautes were saved in a singel matrix.
% The estimates of the satellite products at the the grids where the 
% gauge exists were exatracted and save in single matrixes. 
Observe_folder=[Root_folder,'test_data\Gauge_observations\'];
SPP_Folder=[Root_folder,'test_data\SPPs\'];

% we sample the gauges used for traning the machine lenarning algorithms 
% at the subregional level due to the uneven distribution.
Sugregions=[Root_folder,'test_data\Gauge_observations\subregions\'];
mete_station_name='gauge_information.xlsx';

% the merged results at the validaition gauges
output_folder=[Root_folder,'test_data\Result\'];


%% Define  paramters

% 70% gauges used for training the ML algorithsm, and 30% for validaton
% The users can slected different proportions of the training data.
% 1 means all the trainig data were used, while 0.5 means half of the 
% training data were used. This facilitate the analyses on the impacts
% if gauge density on the performance of the ML algorithms
denstity=1;

% Defing the start and end day
start_day=[2007,1,1];
end_day=[2007,1,31];


% Defing flags for different data
% if the data has been read from the raw data, we should set the flat=1
% this will save a lot of time since data reading is time-consuming
IMERG_exist=1;
SM2RAIN_exist=1;
PRESIANN_exist=1;
GsMap_exist=1;
CMD_exist=1;

% Before training the algorithms, we should construct a matrix in which the
% observations, the statellite precipitation, and the auxiliary variables 
% were all included. 
Matrix_exist=0;


% Due the random sample, each run of the program will lead to different
% samples. The samples will mot change during the experiments
% if it is set to 0
Change_samples=0;

% Define the number of neighbor stations used to calculate the terms used
% for accounting the spatial autocrrelation. 
neighbor_station_number=5;

% We divided the validation gauges into two parts randomly 
% The divison can be kept constant if subtest_data_unchanged=0;
subtest_data_unchanged=1;

%% ===============================================================
%       Get random samples for traing and validation the ML algorithms                   
% =========================================================================
if Change_samples==1
    [train_data,validation_data] = subregion_sample(topography_fold,...
        Sugregions,mete_station_name); 
else
    
    train_data=load ('train_data.mat','train_data');
    train_data=train_data.train_data;
    validation_data=load ('validation_data.mat','validation_data');
    validation_data=validation_data.validation_data;
    
    % A proportion of the training data, defined the density, were used to
    % train the ML algorithms
    [train_data_subregion,validation_data_subregion,train_data_subset, ...
        train_data_subset_subregion]...
        = Differ_station_density(train_data ,validation_data, denstity);
    train_data=train_data_subset;
    
    
    % We divided the validation gauges into two parts
    if subtest_data_unchanged==0
        [ validation_subset01,validation_subset02 ] = ...
            half_test_data(Sugregions,Observe_folder,validation_data,...
            mete_station_name );
        
        save([output_folder,'validation_subset01.mat'],...
            'validation_subset01');
   
        save([output_folder,'validation_subset02.mat'],...
            'validation_subset02');
    else
     validation_subset01=load([output_folder,'validation_subset01.mat'],...
            'validation_subset01');
     validation_subset01=validation_subset01.validation_subset01;
        
     validation_subset02= load([output_folder,'validation_subset02.mat'],...
            'validation_subset02');
        validation_subset02=validation_subset02.validation_subset02;
    end
    
end

%% ===============================================================
%                         Parellel Computing
% Get number of cpus and set the parallel coumputing to ture if the number
% if cpus is greater than 1
% =========================================================================
paroptions = Parellel_set();


%% ===============================================================
%              Loading data and constructing input-ouput maxtrix
% =========================================================================

% Load data
[IMERG,SM2RAIN_ASCAT,PERSIANN,GsMap,CMD_obs,Distance]=read_predictor_output...
    (Observe_folder,SPP_Folder,IMERG_Folder,SW2RAIN_ASCAT_Folder,...
    PERSIANN_Folder,GsMAP_Folder,CMD_Folder,mete_station_name,start_day,...
    end_day,IMERG_exist,SM2RAIN_exist,PRESIANN_exist,GsMap_exist,...
    Distance_exist,CMD_exist);


% Constructing maxtrix
if Matrix_exist==0
    [ train_region_ID,vali_region_ID,vali_region_ID01] = region_ID(...
        Sugregions,train_data,validation_subset01,validation_subset02);
    
   % Preparing the matrix incluingd inputs and outputs for training the ML
   % algorithms
   [Matrix_predictor_train,Matrix_predictor_valid,Matrix_predictor_valid01]...
       =RF_matrix_ensemble(Observe_folder,mete_station_name,start_day,...
        end_day,CMD_obs,IMERG,SM2RAIN_ASCAT,...
        PERSIANN,GsMap,Distance,train_data,...
        validation_subset01,validation_subset02,...
        neighbor_station_number,train_region_ID,...
        vali_region_ID,vali_region_ID01,output_folder);
else
    Matrix_predictor_train=load([output_folder,'Matrix_predictor_train.mat'],...
        'Matrix_predictor_train');
    Matrix_predictor_train=Matrix_predictor_train.Matrix_predictor_train;
    
    Matrix_predictor_valid=load([output_folder,'Matrix_predictor_valid.mat'],...
        'Matrix_predictor_valid');
    Matrix_predictor_valid=Matrix_predictor_valid.Matrix_predictor_valid;
    
    Matrix_predictor_valid01=load([output_folder,'Matrix_predictor_valid01.mat'],...
        'Matrix_predictor_valid01');
    Matrix_predictor_valid01=Matrix_predictor_valid01.Matrix_predictor_valid01;
end


%% ===============================================================
%                         Initialization
% =========================================================================
delta = datenum(end_day)-datenum(start_day)+1;

% output used for classification at the training gauges
Out_train = Matrix_predictor_train(1:delta*length(train_data),1);

% ouput used for regression at the training gauges
Out_train_regression = Matrix_predictor_train(1:delta*length(train_data),2);

% inputs used for both classification and regression at the training gauges
In_tain = Matrix_predictor_train(1:delta*length(train_data),3:end);

% ouputs at the validation gauges (subset 01)
Out_vali = Matrix_predictor_valid(1:delta*length(validation_subset01),2);
% inputs at the validation gauges (subset 01)
In_vali = Matrix_predictor_valid(1:delta*length(validation_subset01),3:end);

% ouputs at the validation gauges (subset 02)
Out_vali01 = Matrix_predictor_valid01(1:delta*length(validation_subset02),2);
% inputs at the validation gauges (subset 02)
In_vali01 = Matrix_predictor_valid01(1:delta*length(validation_subset02),3:end);

%% ===============================================================
%                   Single machine learing (SML)
%                       RF, ANN, SVM and EML
% =========================================================================
Prediction_sub_test_train=[];
Prediction_sub_test01_vali=[];
Prediction_sub_test02_vali=[];
Performance_all_first_stage=[];

% this needs to define when calculate POD, FAR and CSI
pcp_threshold=5;

% The merging can  be conducted at the daily, monthly or annual
% scales, 1=year,2=month,3=day.
%  train_period define the merging time scales
train_period=3;

%############################# RF #########################
leaf=5;
ntrees=30;
fboot=1;
surrogate='off';

tic
[ Performance,y,y_vali,y_vali01,Weights ] = TreeBagger_train_origin(...
    start_day,end_day,train_period,In_tain,Out_train,Out_train_regression,...
    In_vali,Out_vali,In_vali01,Out_vali01,leaf,ntrees, fboot,surrogate,...
    paroptions,train_data,validation_subset01,validation_subset02,pcp_threshold);
toc

Prediction_sub_test_train=[Prediction_sub_test_train,y];
Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali01];
Performance_all_first_stage=[Performance_all_first_stage;Performance];

%############################# ANN ########################
hiddenSizes= [10,20,30];
radon_run=10;
tic

[ Performance,y,y_vali,y_vali01 ] = ANN_train(start_day,end_day,train_period,...
    In_tain,Out_train,Out_train_regression,In_vali,Out_vali,...
    In_vali01,Out_vali01,train_data,validation_subset01,...
    validation_subset02,pcp_threshold, hiddenSizes, radon_run);
toc

Prediction_sub_test_train=[Prediction_sub_test_train,y];
Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali01];
Performance_all_first_stage=[Performance_all_first_stage;Performance];

%############################# SVM #########################
% Note: SVM is not built-in function.Install the Libsvm package 
% before the utilizaiton. Ref: Chang, C.-C., Lin, C.-J., 2011. 
%  LIBSVM: A library for support vector machines
tic
c_range=-10:2:10;
grange=-10:2:10;
v=5;
[ Performance,y,y_vali,y_vali01] = SVM_train(start_day,end_day,train_period,....
    In_tain,Out_train,Out_train_regression,In_vali,Out_vali, In_vali01,...
    Out_vali01,train_data,validation_subset01,validation_subset02,...
    pcp_threshold,c_range,grange,v);
toc
Prediction_sub_test_train=[Prediction_sub_test_train,y];
Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali01];
Performance_all_first_stage=[Performance_all_first_stage;Performance];

%############################# EML #########################
% Ref: uang, G., Zhou, H., Ding, X., Zhang, R., 2012. 
% Extreme Learning Machine for Regression and Multiclass Classification.
% IEEE Transactions on Systems, Man, and Cybernetics, Part B (Cybernetics), 
% 42(2): 513-529
tic
hiddenSizes=[10,20,30];% [10,20,30];
radon_run=10;
[ Performance,y,y_vali,y_vali01] = ELM_train(start_day,end_day,train_period,....
    In_tain,Out_train,Out_train_regression,In_vali,Out_vali,In_vali01,...
    Out_vali01,train_data,validation_subset01,validation_subset02,...
    pcp_threshold,hiddenSizes, radon_run);
toc
%     Prediction_sub_test01_vali(:,4)=[];
%     Prediction_sub_test02_vali(:,4)=[];
Prediction_sub_test_train=[Prediction_sub_test_train,y];
Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali01];
Performance_all_first_stage=[Performance_all_first_stage;Performance];

save([output_folder,'Prediction_sub_test01_vali.mat'],...
                     'Prediction_sub_test01_vali','-v7.3');
save([output_folder,'Prediction_sub_test02_vali.mat'],...
                     'Prediction_sub_test02_vali','-v7.3');

 %% =============================================================% 
 %                   Double machine learning (DML)
 %========================================================================% 
 
 %############################# RF-RF #########################
 tic
 [ Performance,y,y_vali,y_vali01,y_class,y_vali_class,y_vali01_class,Weights] =...
     double_TreeBagger_train_origin(start_day,end_day,train_period,In_tain,...
     Out_train,Out_train_regression,In_vali,Out_vali,In_vali01,Out_vali01,...
     leaf,ntrees, fboot,surrogate,paroptions,train_data,validation_subset01,...
     validation_subset02,pcp_threshold);
 toc
 Prediction_sub_test_train=[Prediction_sub_test_train,y];
 Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
 Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali01];
 Performance_all_first_stage=[Performance_all_first_stage;Performance];
 
 
 %############################# RF-ANN #########################
 % ANN
 hiddenSizes= [10,20,30];
 radon_run=10;
 tic
 
 [ Performance,y,y_vali,y_vali01 ] = ANN_train(start_day,end_day,train_period,...
     In_tain,Out_train,Out_train_regression,In_vali,Out_vali,In_vali01,...
     Out_vali01,train_data,validation_subset01,validation_subset02,pcp_threshold,...
     hiddenSizes, radon_run);
 toc
 
 y_vali(y_vali_class==0)=0;
 y_vali01(y_vali01_class==0)=0;
 
 Prediction_sub_test_train=[Prediction_sub_test_train,y];
 Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
 Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali01];
 Performance_all_first_stage=[Performance_all_first_stage;Performance];
 
 
 %############################# RF-SVM #########################
 tic
 c_range=-10:2:10;
 grange=-10:2:10;
 v=5;
 [ Performance,y,y_vali,y_vali01] = SVM_train(start_day,end_day,train_period,...
     In_tain,Out_train,Out_train_regression,In_vali,Out_vali,In_vali01,...
     Out_vali01,train_data,validation_subset01,validation_subset02,...
     pcp_threshold,c_range,grange,v);
 toc
 y_vali(y_vali_class==0)=0;
 y_vali01(y_vali01_class==0)=0;
 
 Prediction_sub_test_train=[Prediction_sub_test_train,y];
 Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
 Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali01];
 Performance_all_first_stage=[Performance_all_first_stage;Performance];
 
 %############################# RF-EML #########################
 
 hiddenSizes=[10,20,30];% [10,20,30];
 radon_run=20;
 hiddenSizes=[10,20,30];% [10,20,30];
 radon_run=10;
 [ Performance,y,y_vali,y_vali01] = ELM_train(start_day,end_day,train_period,...
     In_tain,Out_train,Out_train_regression,In_vali,Out_vali,In_vali01,...
     Out_vali01,train_data,validation_subset01,validation_subset02,...
     pcp_threshold,hiddenSizes, radon_run);
 y_vali(y_vali_class==0)=0;
 y_vali01(y_vali01_class==0)=0;
 
 % save results
 Prediction_sub_test_train=[Prediction_sub_test_train,y];
 Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
 Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali01];
 Performance_all_first_stage=[Performance_all_first_stage;Performance];
 
 save([output_folder,'Prediction_sub_test01_vali.mat'],...
     'Prediction_sub_test01_vali','-v7.3');
 save([output_folder,'Prediction_sub_test02_vali.mat'],...
     'Prediction_sub_test02_vali','-v7.3');
