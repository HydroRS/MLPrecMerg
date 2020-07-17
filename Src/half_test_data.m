function [ validation_subset01,validation_subset02 ] = half_test_data( Sugregions,topography_fold,validation_data,mete_station_name )

%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
  %% sample in subregions 70% for training and 30% for validation
    % subregions
    subregion_name={'SEC', 'YZ', 'NC', 'NEC', 'YGP', 'NWC', 'QTP', 'XJ'};
    
     % CMD station infor
 topography_predict=xlsread([topography_fold,mete_station_name]);
    
    train_data=[];
    validation_data01=[];
    parfor i=1:length(subregion_name)
        subregion_data_temp=xlsread(strcat(Sugregions, subregion_name{i}, '.xlsx'));
        
        % validation station in current subregions
        ID_temp=ismember(validation_data,subregion_data_temp(:,1));
        temp_subregion_data=validation_data(ID_temp==1);
        
     
        train_data_ID=datasample(temp_subregion_data(:,1),ceil(0.5*length(temp_subregion_data)),... % 70% used for training 
            'Replace',false);
        ID_temp=ismember(temp_subregion_data,train_data_ID);
        validation_data_ID= temp_subregion_data(ID_temp==0);
        
        train_data=[train_data;train_data_ID];
        validation_data01=[validation_data01;validation_data_ID];
    end
    
      validation_subset01=train_data;
      validation_subset02=validation_data01;

end

