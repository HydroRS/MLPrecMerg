function [ train_data,validation_data ] = subregion_sample(topography_fold, Sugregions,mete_station_name )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
  %% sample in subregions 70% for training and 30% for validation
    % subregions
    subregion_name={'SEC', 'YZ', 'NC', 'NEC', 'YGP', 'NWC', 'QTP', 'XJ'};
    
     % CMD station infor
 topography_predict=xlsread([topography_fold,mete_station_name]);
    
    train_data=[];
    validation_data=[];
    for i=1:length(subregion_name)
        subregion_data_temp=xlsread(strcat(Sugregions, subregion_name{i}, '.xlsx'));
        
        subregion_station=subregion_data_temp(:,1);
        train_data_ID=datasample(subregion_data_temp(:,1),ceil(0.7*length(subregion_data_temp)),... % 70% used for training 
            'Replace',false);
        ID_temp=ismember(subregion_station,train_data_ID);
        validation_data_ID= subregion_station(ID_temp==0);
        
        train_data=[train_data;train_data_ID];
        validation_data=[validation_data;validation_data_ID];
    end
    
    % some station is overlooked when extracting subregion sations
    % they were added to the training data
    id_overlook=ismember(topography_predict(:,1),[train_data;validation_data]);
    temp=topography_predict(:,1);
    station_overlook=temp(id_overlook==0);
    train_data=[train_data;station_overlook];
    
    % exclude the last four stations
    id_exclude=find(ismember(train_data,[52661;52633;52645;52657])==1);
    train_data(id_exclude)=[];
    id_exclude=find(ismember(validation_data,[52661;52633;52645;52657])==1);
    validation_data(id_exclude)=[];
    
    
    xlswrite('train_validation_data.xlsx',train_data,'sheet1');
    xlswrite('train_validation_data.xlsx',validation_data,'sheet2');

end

