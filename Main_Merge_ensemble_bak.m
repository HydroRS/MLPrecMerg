% *************************************************************************
%                        RF near-real-time SPP merge
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
topography_fold='D:\Work_2020\Papers\PCP_merge\predictor\topography\';
SPP_Folder='D:\Work_2020\Papers\PCP_merge\predictor\SSPs\';

% Statelite data folder
IMERG_Folder='F:\Data_ZL\GPM_IMERG\Early_Run\';
SW2RAIN_ASCAT_Folder='F:\Data_ZL\SW2R-ASC\';
PERSIANN_Folder='F:\Data_ZL\PERSIANN\';
GsMAP_Folder='F:\Data_ZL\GSMAP\00Z-23Z\';

CMD_Folder='F:\Data_ZL\CMD-PCP\raw_PCP_data\';
Sugregions='D:\Work_2020\Papers\PCP_merge\predictor\study area\Sugregions\';
mete_station_name='Station_location_Degree_new.xlsx';

% Defing the start and end day
start_day=[2007,1,1];
end_day=[2007,1,31];

% Defing exist flags for the data
% if the data has been read, we should set the flat=1
% this will save a lot of time since data reading is time-consuming
Matrix_exist=0;
IMERG_exist=1;
SM2RAIN_exist=1;
PRESIANN_exist=1;
GsMap_exist=1;
Distance_exist=1;
CMD_exist=1;

% The samples will mot change during the experiments
Change_samples=0;

% Define the number of neighbor stations
neighbor_station_number=5;

% machine learning method
method_flag=2;

% subregion RF flag
subregion_RF=0;
%% ===============================================================
%                       Get sub-region samples
% if change samples, the training and validaitons satations will be changed
% =========================================================================

% Get sub-region samples
if Change_samples==1
    [train_data,validation_data] = subregion_sample(topography_fold,...
        Sugregions,mete_station_name);
    
else
    train_data= xlsread('train_validation_data.xlsx','sheet1');
    validation_data=xlsread('train_validation_data.xlsx','sheet2');
 
  
  [ validation_subset01,validation_subset02 ] = half_test_data( Sugregions,...
      topography_fold,validation_data,mete_station_name );
  
      
end

if subregion_RF==1
    [train_data_,validation_data_] = subreigon_sample_individual(...
        topography_fold, mete_station_name,Sugregions,train_data,...
        validation_data );
end

%% ===============================================================
%                         Parellel Computing
% =========================================================================

% get number of cpus and set the parallel coumputing to ture if the number
% if cpus is greater than 1
paroptions = Parellel_set();
%% ===============================================================
%              Load data, and  constructing maxtrix
% =========================================================================

% Load data
[IMERG,SM2RAIN_ASCAT,PERSIANN,GsMap,CMD_obs,Distance]=read_predictor_output...
    (topography_fold,SPP_Folder,IMERG_Folder,SW2RAIN_ASCAT_Folder,...
    PERSIANN_Folder,GsMAP_Folder,CMD_Folder,mete_station_name,start_day,...
    end_day,IMERG_exist,SM2RAIN_exist,PRESIANN_exist,GsMap_exist,...
    Distance_exist,CMD_exist);


    % Constructing maxtrix
    if Matrix_exist==0
          [ train_region_ID,vali_region_ID,vali_region_ID01] = region_ID(...
              Sugregions,train_data,validation_subset01,validation_subset02);
         
        [Matrix_predictor_train,Matrix_predictor_valid,Matrix_predictor_valid01]=RF_matrix_ensemble(...
            topography_fold,mete_station_name,start_day,...
            end_day,CMD_obs,IMERG,SM2RAIN_ASCAT,...
            PERSIANN,GsMap,Distance,train_data,...
            validation_subset01,validation_subset02,...
            neighbor_station_number,train_region_ID,vali_region_ID,vali_region_ID01);
    else
        Matrix_predictor_train=load('Matrix_predictor_train.mat',...
            'Matrix_predictor_train');
        Matrix_predictor_train=Matrix_predictor_train.Matrix_predictor_train;
        Matrix_predictor_valid=load('Matrix_predictor_valid.mat',...
            'Matrix_predictor_valid');
        Matrix_predictor_valid=Matrix_predictor_valid.Matrix_predictor_valid;
         Matrix_predictor_valid01=load('Matrix_predictor_valid01.mat',...
            'Matrix_predictor_valid01');
        Matrix_predictor_valid01=Matrix_predictor_valid01.Matrix_predictor_valid01;
    end

        delta = datenum(end_day)-datenum(start_day)+1;
        % used for classify
        Out_train = Matrix_predictor_train(1:delta*length(train_data),1);
        % used for regression
        Out_train_regression = Matrix_predictor_train(1:delta*length(train_data),2);
        
        In_tain = Matrix_predictor_train(1:delta*length(train_data),3:end);
        
     
%% ===============================================================
%                         RF, ANN & SVM
% =========================================================================

pcp_threshold=5; % mm
% ---set the training period-----
% 1=year,2=month,3=day
train_period=3;


for ii=1:2 % two subset test data
    if ii==1
        validation_data=validation_subset01;
        % prediction by RF, SVM, ANN
        Prediction_sub_test01_train=[];
        Prediction_sub_test01_vali=[];
          Out_vali = Matrix_predictor_valid(1:delta*length(validation_data),2);
        In_vali = Matrix_predictor_valid(1:delta*length(validation_data),3:end);
    elseif ii==2
          % prediction by RF, SVM, ANN
        Prediction_sub_test02_train=[];
        Prediction_sub_test02_vali=[];
        validation_data=validation_subset02;
          Out_vali = Matrix_predictor_valid01(1:delta*length(validation_data),2);
        In_vali = Matrix_predictor_valid01(1:delta*length(validation_data),3:end);
    end
    
    
        
        
    % RF
    % paramters
leaf=5;
ntrees=30;
fboot=1;
surrogate='off';

    tic
    [ Performance,y,y_vali,Weights ] = TreeBagger_train_origin(...
        start_day,end_day,train_period,In_tain,Out_train,Out_train_regression,In_vali,Out_vali,...
        leaf,ntrees, fboot,surrogate,paroptions,train_data,validation_data,pcp_threshold,subregion_RF);
    toc
    if ii==1
        Prediction_sub_test01_train=[Prediction_sub_test01_train,y];
        Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
    elseif ii==2
        Prediction_sub_test02_train=[Prediction_sub_test02_train,y];
        Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali];
    end
    
 
 % ANN
    hiddenSizes= [10,20,30];
    radon_run=10;
    tic
    [ Performance,y,y_vali,Weights_class,Weights_regress ] = ANN_train(...
        start_day,end_day,train_period,In_tain,Out_train,Out_train_regression,In_vali,Out_vali,...
        leaf,ntrees, fboot,surrogate,paroptions,train_data,validation_data,pcp_threshold,...
        hiddenSizes, radon_run);
    toc
 if ii==1
        Prediction_sub_test01_train=[Prediction_sub_test01_train,y];
        Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
    elseif ii==2
        Prediction_sub_test02_train=[Prediction_sub_test02_train,y];
        Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali];
    end
    
    
     % SVM
    tic
    c_range=-10:2:10;
    grange=-10:2:10;
    v=5;
    [ Performance,y,y_vali] = SVM_train(...
        start_day,end_day,train_period,In_tain,Out_train,Out_train_regression,In_vali,Out_vali,...
        leaf,ntrees, fboot,surrogate,paroptions,train_data,validation_data,pcp_threshold,c_range,grange,v);
    toc
    if ii==1
        Prediction_sub_test01_train=[Prediction_sub_test01_train,y];
        Prediction_sub_test01_vali=[Prediction_sub_test01_vali,y_vali];
    elseif ii==2
        Prediction_sub_test02_train=[Prediction_sub_test02_train,y];
        Prediction_sub_test02_vali=[Prediction_sub_test02_vali,y_vali];
    end
end
save('Prediction_sub_test01_train.mat','Prediction_sub_test01_train','-v7.3');
save('Prediction_sub_test01_vali.mat','Prediction_sub_test01_vali','-v7.3');
save('Prediction_sub_test02_train.mat','Prediction_sub_test02_train','-v7.3');
save('Prediction_sub_test02_train.mat','Prediction_sub_test02_train','-v7.3');

%% ===============================================================
%                         Post process
% =========================================================================


xlswrite([num2str(start_day(1)),'_',num2str(start_day(2)),'_',...
    num2str(start_day(3)),'-',num2str(end_day(1)),'_',...
    num2str(end_day(2)),'_', num2str(end_day(3)),'_train_period',...
    num2str(train_period),'.xlsx'],...
    Performance,'sheet1');

xlswrite([num2str(start_day(1)),'_',num2str(start_day(2)),'_',...
    num2str(start_day(3)),'-',num2str(end_day(1)),'_',...
    num2str(end_day(2)),'_', num2str(end_day(3)),'_train_period',...
    num2str(train_period),'.xlsx'], Weights,'sheet2');
% 
% xlswrite([num2str(start_day(1)),'_',num2str(start_day(2)),'_',...
%     num2str(start_day(3)),'-',num2str(end_day(1)),'_',...
%     num2str(end_day(2)),'_', num2str(end_day(3)),'_train_period',...
%     num2str(train_period),'.xlsx'], Weights_regress,'sheet3');


