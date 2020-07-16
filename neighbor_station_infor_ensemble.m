function [ID_neighbor_train, ID_neighbor_D_train,ID_neighbor_vali,ID_neighbor_D_vali,ID_neighbor_vali01,ID_neighbor_D_vali01] =neighbor_station_infor_ensemble(train_station_infor,vali_station_infor,vali_station_infor01,neighbor_station_number )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% mete_infor=xlsread([topography_fold,mete_station_name]);
lat=train_station_infor(:,2);
lon=train_station_infor(:,3);
lat_vali=vali_station_infor(:,2);
lon_vali=vali_station_infor(:,3);
lat_vali01=vali_station_infor01(:,2);
lon_vali01=vali_station_infor01(:,3);
% neighbor_station_number=5;

ID_neighbor_train=zeros(length(lat),neighbor_station_number);
ID_neighbor_D_train=zeros(length(lat),neighbor_station_number);
ID_neighbor_vali=zeros(length(lat_vali),neighbor_station_number);
ID_neighbor_D_vali=zeros(length(lat_vali),neighbor_station_number);
ID_neighbor_vali01=zeros(length(lat_vali01),neighbor_station_number);
ID_neighbor_D_vali01=zeros(length(lat_vali01),neighbor_station_number);

 temp=[lon,lat];
for ii=1:length(lat)
    
   % For the training data, the current station will be excluded since it
   % will have a distance of zero
      temp(ii,:)=[0,0]; 
   [ID_neighbor_train(ii,:),ID_neighbor_D_train(ii,:)]=knnsearch(temp,[lon(ii),lat(ii)],'k',neighbor_station_number, 'Distance', @DISTFUN);
   
end

for ii=1:length(lat_vali)
   % For the validaiton data, the station is totally independent of the
   % training data
   [ID_neighbor_vali(ii,:),ID_neighbor_D_vali(ii,:)]=knnsearch([lon,lat],[lon_vali(ii),lat_vali(ii)],'k',neighbor_station_number, 'Distance', @DISTFUN);
  
end


for ii=1:length(lat_vali01)
   % For the validaiton data, the station is totally independent of the
   % training data
   [ID_neighbor_vali01(ii,:),ID_neighbor_D_vali01(ii,:)]=knnsearch([lon,lat],[lon_vali01(ii),lat_vali01(ii)],'k',neighbor_station_number, 'Distance', @DISTFUN);
end
%%


end
