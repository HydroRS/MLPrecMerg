function [ SM2RAIN_ASCAT ] = SM2RAIN_ASCAT( SW2RAIN_ASCAT_Folder,current_Folder,IMERG_Folder,mete_station_name, start_day, end_day)

% ----------------------------------------------------------------------------------------
%This codes are used to extract the PCP data from SW2RAIN_ASCA

% clc;clear

% data folder
% mete_station_name='Station_location_Degree_new.xlsx';
% SW2RAIN_ASCAT_Folder='F:\Data_ZL\SW2R-ASC\';
% current_Folder='D:\Work_2020\Papers\PCP_merge\predictor\SSPs\\';
% IMERG_Folder='F:\Data_ZL\GPM_IMERG\Early_Run\';
%% Reading CMD station location
CMD_Station_Location=xlsread([current_Folder,mete_station_name]);
lon=CMD_Station_Location(:,3);
lat=CMD_Station_Location(:,2);
Station_Name=CMD_Station_Location(:,1);

% Basic info of the SM2RAIN data
namefile=[SW2RAIN_ASCAT_Folder,'SM2RAIN_ASCAT_0125_2007_v1.1.nc'];
lon_=ncread(namefile,'Longitude');
lat_=ncread(namefile,'Latitude');

% Basic info of the IMERG Early Run data

namefile='3B-DAY-E.MS.MRG.3IMERG.20000601-S000000-E235959.V06.nc4.nc4';
lon_IMERG=ncread([IMERG_Folder,namefile],'lon');
lat_IMERG=ncread([IMERG_Folder,namefile],'lat');


%% Reading SW2RAIN-ASCAT data for each CMD station
% start_day=[2007,1,1];
% end_day=[2017,1,3];
delta = datenum(end_day)-datenum(start_day)+1;
delta_temp=datenum([end_day(1),12,31])-datenum([start_day(1),1,1])+1;
% Id_nan_all=[];
SM2RAIN_Prec_All_Station=zeros(delta_temp,length(CMD_Station_Location));
parfor i=1:length(lon)
    
    Station_Name(i)
    % Coordinates of the station you want to extract
    lonlat_stat=[lon(i),lat(i)];
    lon_stat=lon(i);
    lat_stat=lat(i);
    %Extraction of the pixel closest to the IMERG coordinates
    ID_lon=knnsearch(lon_IMERG,lon_stat);
    ID_lat=knnsearch(lat_IMERG,lat_stat);
    
    %the pixel of SM2RAIN closest to the IMERG coordinates
    ID=knnsearch([lon_,lat_],[lon_IMERG(ID_lon),lat_IMERG(ID_lat)]);

% Extraction of SM2RAIN-ASCAT rainfall from 2007 to 2017

Psim_SM2RASC=[];
for ii=start_day(1):end_day(1) % loop over the years 2007 to 2017
    Psim_SM2RASC=[Psim_SM2RASC;...
        ncread(strcat(SW2RAIN_ASCAT_Folder,'SM2RAIN_ASCAT_0125_',num2str(ii),'_v1.1.nc'),'Rainfall',[1 ID],[yeardays(ii) 1])];
end
% [1 ID],[yeardays(ii) 1])] %the first demension from 1 to yeardays(ii),
% the second dimension read from ID, only one layer of data to be read

SM2RAIN_Prec_All_Station(:,i)=Psim_SM2RASC;

end

Id_nan=find(isnan(SM2RAIN_Prec_All_Station));
SM2RAIN_Prec_All_Station(Id_nan)=0; % nodata
% Id_nan_all=[Id_nan_all;Id_nan];
SM2RAIN_ASCAT=SM2RAIN_Prec_All_Station(1:delta,:);

save([current_Folder,'SM2RAIN_ASCAT.mat'],'SM2RAIN_ASCAT');
end





