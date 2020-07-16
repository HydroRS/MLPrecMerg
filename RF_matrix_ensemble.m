% --------------------------------------------------------------------
%             Constructing the matrix used for the RF-merge
%                  By Ling Zhang, zhanglingky@lzb.ac.cn
% --------------------------------------------------------------------
function[Matrix_predictor_train,Matrix_predictor_valid,Matrix_predictor_valid01]=RF_matrix_ensemble(topography_fold,mete_station_name,start_day,end_day,...
    CMD_obs,IMERG,SM2RAIN_ASCAT,PERSIANN,GsMap,Distance,...
    train_data,validation_data,validation_data01,neighbor_station_number, train_region_ID,vali_region_ID,vali_region_ID01,output_folder)
Pop_crit=0.5;
% clc;clear;
% topography_fold='D:\Work_2020\Papers\PCP_merge\predictor\topography\';
% SPP_Folder='D:\Work_2020\Papers\PCP_merge\predictor\SSPs\';
%
% % Statelite data folder
% IMERG_Folder='F:\Data_ZL\GPM_IMERG\Early_Run\';
% SW2RAIN_ASCAT_Folder='F:\Data_ZL\SW2R-ASC\';
% PERSIANN_Folder='F:\Data_ZL\PERSIANN\';
% GsMAP_Folder='F:\Data_ZL\GSMAP\00Z-23Z\';
%
% CMD_Folder='F:\Data_ZL\CMD-PCP\raw_PCP_data\';
% Sugregions='D:\Work_2020\Papers\PCP_merge\predictor\study area\Sugregions\';
% mete_station_name='Station_location_Degree_new.xlsx';
%
% % Defing the start and end day
% start_day=[2007,1,1];
% end_day=[2011,12,31];
%
% % Defing exist flags for the data
% Matrix_exist=1;
% IMERG_exist=1;
% SM2RAIN_exist=1;
% PRESIANN_exist=1;
% GsMap_exist=0;
% Distance_exist=1;
% CMD_exist=1;

% CMD station infor
topography_predict=load('topography_predict.mat','topography_predict');
 topography_predict=topography_predict.topography_predict;
 

% train data
   Used_Id_train=zeros(length(train_data),1);
   temp_station=topography_predict(:,1);
    for mm=1:length(train_data)
        id=find(temp_station==train_data(mm));
        Used_Id_train(mm)=id;  
    end
     train_station_infor=topography_predict(Used_Id_train,:);
 
  % validation data_subset 01
      Used_Id_validation=zeros(length(validation_data),1);
   temp_station=topography_predict(:,1);
    for mm=1:length(validation_data)
        id=find(temp_station==validation_data(mm));
        Used_Id_validation(mm)=id;  
    end
     vali_station_infor=topography_predict(Used_Id_validation,:);
 
  % validation data_subset 02
      Used_Id_validation01=zeros(length(validation_data01),1);
   temp_station=topography_predict(:,1);
    for mm=1:length(validation_data01)
        id=find(temp_station==validation_data01(mm));
        Used_Id_validation01(mm)=id;  
    end
     vali_station_infor01=topography_predict(Used_Id_validation01,:);


   [ID_neighbor_train, ID_neighbor_D_train,ID_neighbor_vali,ID_neighbor_D_vali,ID_neighbor_vali01,ID_neighbor_D_vali01]...
                = neighbor_station_infor_ensemble(train_station_infor,vali_station_infor,vali_station_infor01,neighbor_station_number);
            
            
Matrix_predictor_train=[];
Matrix_predictor_valid=[];
Matrix_predictor_valid01=[];

sum_day=1;
for year = start_day(1):end_day(1)
    
    % end month
    if year==end_day(1)
        end_month=end_day(2);
    else
        end_month=12;
    end
    
    current_day=1;
    for month = 1:end_month
        % end day
        if month==end_day(2)&&year==end_day(1)
            num_day=end_day(3);
        else
            num_day=eomday(year, month);
        end
        
        for  month_day =1:num_day
            [num2str(year),'-',num2str(month),'-',num2str(month_day)]
            
            %% calculate neighbor station information
         
            % neighbor informaiton for training data
            CMD_obs_data=CMD_obs(Used_Id_train,sum_day)';
            neighbor_station_train=zeros(length(train_station_infor),1);
            neighbor_station_train_occur=zeros(length(train_station_infor),1);
            
            for mm=1:length(train_station_infor)
                 % Ref
                % Li T, Shen H, Yuan Q, Zhang X, Zhang L. Estimating Ground-Level PM2.5  by Fusing Satellite and Station Observations:
                % A Geo-Intelligent Deep Learning Approach. Geophysical Research Letters, 2017, 44(23):11, 911-985, 993.
                
                inverse_d2=1./ID_neighbor_D_train(mm,:).^2;
                weights=inverse_d2/sum(inverse_d2);
                neighbor_station_train(mm)=sum(weights.*(CMD_obs_data(ID_neighbor_train(mm,:))));
                
                % Ref
                % Thornton P E, Running S W, White M A. Generating surfaces of daily meteorological variables over large regions of complex terrain.
                % Journal of Hydrology, 1997, 190(3):214-251
                
                temp=CMD_obs_data(ID_neighbor_train(mm,:));
                temp(temp>0)=1;
                neighbor_station_train_occur(mm)=sum(weights.*temp);
%                 if neighbor_station_train_occur(mm)> Pop_crit
%                    neighbor_station_train_occur(mm)=1;
%                 else
%                    neighbor_station_train_occur(mm)=0;
%                 end
                     
            end
            
               % neighbor informaiton for training data
               % For the validation data, only the neighbor training data
               % information was usd.
            CMD_obs_data=CMD_obs(Used_Id_train,sum_day)';
            neighbor_station_vali=zeros(length(vali_station_infor),1);
            
            neighbor_station_vali_occur=zeros(length(vali_station_infor),1);
            
            for mm=1:length(vali_station_infor)
                inverse_d2=1./ID_neighbor_D_vali(mm,:).^2;
                weights=inverse_d2/sum(inverse_d2);
                neighbor_station_vali(mm)=sum(weights.*(CMD_obs_data(ID_neighbor_vali(mm,:))));     
                
                 temp=CMD_obs_data(ID_neighbor_vali(mm,:));
                temp(temp>0)=1;
                neighbor_station_vali_occur(mm)=sum(weights.*temp);
            end
            
            neighbor_station_vali01=zeros(length(vali_station_infor01),1);
               neighbor_station_vali_occur01=zeros(length(vali_station_infor01),1);
            for mm=1:length(vali_station_infor01)
                inverse_d2=1./ID_neighbor_D_vali01(mm,:).^2;
                weights=inverse_d2/sum(inverse_d2);
                neighbor_station_vali01(mm)=sum(weights.*(CMD_obs_data(ID_neighbor_vali01(mm,:))));
                
                temp=CMD_obs_data(ID_neighbor_vali01(mm,:));
                temp(temp>0)=1;
                neighbor_station_vali_occur01(mm)=sum(weights.*temp);
                
                
            end
            
                   
            %% training data
            class_CMD=CMD_obs(Used_Id_train,sum_day);
            class_CMD(class_CMD>0)=1;
            
            temp=[class_CMD,...          % observation class
                CMD_obs(Used_Id_train,sum_day),... % observation
                IMERG(Used_Id_train,sum_day),...              % IMERG
                SM2RAIN_ASCAT(Used_Id_train,sum_day),...      % SM2RASCAT
                PERSIANN(Used_Id_train,sum_day),...           % PERSIANN
                GsMap(Used_Id_train,sum_day),...              % GsMap
               ones(length(Used_Id_train),1).*train_region_ID,...       % region ID
                topography_predict(Used_Id_train,2:4),...   % topography,lon,lat,eleve
                  neighbor_station_train...                   % neighbor infor
                    neighbor_station_train_occur...           % neighbor infor
                                       ];                           
            Matrix_predictor_train=[Matrix_predictor_train;temp];
            
           %  Other un-used predictor
           %  ones(length(Used_Id_train),1).*month,...      % month
           %  Distance(Used_Id_train,:)...                  % Distance   
           %  ones(length(Used_Id_train),1).*current_day,...% day of year 
            %% validation data
             class_CMD=CMD_obs(Used_Id_validation,sum_day);
            class_CMD(class_CMD>0)=1;
            
            temp01=[class_CMD,...        % observation class
                CMD_obs(Used_Id_validation,sum_day),...   % observation
                IMERG(Used_Id_validation,sum_day),...              % IMERG
                SM2RAIN_ASCAT(Used_Id_validation,sum_day),...      % SM2RASCAT
                PERSIANN(Used_Id_validation,sum_day),...           % PERSIANN
                GsMap(Used_Id_validation,sum_day),...              % GsMap
                 ones(length(Used_Id_validation),1).*vali_region_ID,...       % region ID
                topography_predict(Used_Id_validation,2:4),...   % topography
                 neighbor_station_vali...                   % neighbor infor
                    neighbor_station_vali_occur...         % neighbor infor
                ];                 
            Matrix_predictor_valid=[Matrix_predictor_valid;temp01];
            
              class_CMD=CMD_obs(Used_Id_validation01,sum_day);
            class_CMD(class_CMD>0)=1;
            
            temp02=[class_CMD,...        % observation class
                CMD_obs(Used_Id_validation01,sum_day),...   % observation
                IMERG(Used_Id_validation01,sum_day),...              % IMERG
                SM2RAIN_ASCAT(Used_Id_validation01,sum_day),...      % SM2RASCAT
                PERSIANN(Used_Id_validation01,sum_day),...           % PERSIANN
                GsMap(Used_Id_validation01,sum_day),...              % GsMap
                 ones(length(Used_Id_validation01),1).*vali_region_ID01,...       % region ID
                topography_predict(Used_Id_validation01,2:4),...   % topography
                 neighbor_station_vali01...                   % neighbor infor
                    neighbor_station_vali_occur01...         % neighbor infor
                ];                 
            Matrix_predictor_valid01=[Matrix_predictor_valid01;temp02];
            
             %  Other un-used predictor
             % ones(length(Used_Id_validation),1).*month,...      % month
             % Distance(Used_Id_validation,:)...                  % Distance
             %   ones(length(Used_Id_validation),1).*current_day,...% day of year
           
            current_day=current_day+1;
            sum_day=sum_day+1;
        end
    end
end
save([output_folder,'Matrix_predictor_train.mat'],'Matrix_predictor_train','-v7.3');
save([output_folder,'Matrix_predictor_valid.mat'],'Matrix_predictor_valid','-v7.3');
save([output_folder,'Matrix_predictor_valid01.mat'],'Matrix_predictor_valid01','-v7.3');

end


%%









