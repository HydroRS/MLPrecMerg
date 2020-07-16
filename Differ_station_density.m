function [train_data_subregion,validation_data_subregion,train_data_subset, train_data_subset_subregion]...
    = Differ_station_density(train_data ,validation_data, denstity)

%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
  %% sample in subregions 70% for training and 30% for validation
    % subregions
    subregion_name={'SEC', 'YZ', 'NC', 'NEC', 'YGP', 'NWC', 'QTP', 'XJ'};
    
     % CMD station infor
 topography_predict=load('topography_predict.mat','topography_predict');
 topography_predict=topography_predict.topography_predict;
 
  subregion_data=load('subregion_data.mat','subregion_data');
 subregion_data=subregion_data.subregion_data;
 
%  subregion_data=cell(8,1);
%  parfor i=1:length(subregion_name)
%         subregion_data{i}=xlsread(strcat(Sugregions, subregion_name{i}, '.xlsx'));
%  end

%% subregion_data
   train_data_temp=[];
    train_data_subregion=cell(length(subregion_name),1);
    validation_data_temp=[];
     validation_data_subregion=cell(length(subregion_name),1);
    for i=1:length(subregion_name)
        subregion_data_temp=subregion_data{i};
        
        subregion_station=subregion_data_temp(:,1);
        train_data_ID=train_data(ismember(train_data,subregion_station)==1);
        
        validation_data_ID=validation_data(ismember(validation_data,subregion_station)==1);
       
        
        train_data_temp=[train_data_temp;train_data_ID];
        train_data_subregion{i}=train_data_ID;
        validation_data_temp=[validation_data_temp;validation_data_ID];
        validation_data_subregion{i}=validation_data_ID;
    end
    
    missed_sations=train_data(ismember(train_data,train_data_temp)==0);
    
    train_data_subregion{1}=[train_data_subregion{1};missed_sations];
%%

     rng(0);
    train_data_subset=[];
    unused_train_data_subset=[];
    train_data_subset_subregion=cell(length(subregion_name),1);
    
    for i=1:length(subregion_data)
        
        subregion_data_temp=subregion_data{i};
        temp_subregion_data=train_data_subregion{i};
        train_data_ID=datasample(temp_subregion_data(:,1),ceil(denstity*length(temp_subregion_data)),... % 80% of the training data
            'Replace',false);
           train_data_subset_subregion{i}=train_data_ID;
           
        Unused_station= temp_subregion_data(ismember(temp_subregion_data,train_data_ID)==0);
        
        train_data_subset=[train_data_subset;train_data_ID];
        unused_train_data_subset=[unused_train_data_subset;Unused_station];
    end
   

end

