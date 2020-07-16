function [ train_region_ID,vali_region_ID,vali_region_ID01] = region_ID(Sugregions,train_data,validation_data,validation_data01)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    subregion_name={'SEC', 'YZ', 'NC', 'NEC', 'YGP', 'NWC', 'QTP', 'XJ'};
   
    
    train_region_ID=zeros(length(train_data),1);
    vali_region_ID=zeros(length(validation_data),1);
     vali_region_ID01=zeros(length(validation_data01),1);
   
    for i=1:length(subregion_name)
        subregion_data_temp=xlsread(strcat(Sugregions, subregion_name{i}, '.xlsx'));
        
        subregion_station=subregion_data_temp(:,1);
        train_region_ID(ismember(train_data,subregion_station)==1)=i;
        vali_region_ID(ismember(validation_data,subregion_station)==1)=i;
        vali_region_ID01(ismember(validation_data01,subregion_station)==1)=i;
        
    end
    train_region_ID(train_region_ID==0)=1;

end

