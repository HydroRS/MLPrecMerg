%--------------------------------------------------------------------------
% PERSIANN is saved for left to right and up to down
% fread [row, cloumn]£¬fill in the order of the column. i.e., the first
% column is filled then, the second column and so on
% So we shoudl change the colum and row when fread the data, and then
% transpose the matrix
% Creat by Ling, Zhanglingky@lzb.ac.cn
% -------------------------------------------------------------------------
function [ PERSIANN ] = PRESIANN( IPERSIANN_Folder,current_Folder,IMERG_Folder,mete_station_name, start_day, end_day)
% clc;clear;
% PERSIANN_Folder='F:\Data_ZL\PERSIANN\';
% mete_station_name='Station_location_Degree_new.xlsx';
% current_Folder='D:\Work_2020\Papers\PCP_merge\predictor\SSPs\\';
% IMERG_Folder='F:\Data_ZL\GPM_IMERG\Early_Run\';



% Reading CMD station location
CMD_Station_Location=xlsread([current_Folder,mete_station_name]);
% CMD_Station_Location(21:end,:)=[];
lon=CMD_Station_Location(:,3);
lat=CMD_Station_Location(:,2);
Station_Name=CMD_Station_Location(:,1);

rows=480;
columns=1440;
% start_day=[2008,1,1];
% end_day=[2008,12,31];
delta = datenum(end_day)-datenum(start_day)+1;

% PERSIANN information
lon_PERSIANN=.125:0.25:359.875;
lat_PERSIANN=59.875:-0.25:-59.875;

% Basic info of the IMERG Early Run data
namefile='3B-DAY-E.MS.MRG.3IMERG.20000601-S000000-E235959.V06.nc4.nc4';
lon_IMERG=ncread([IMERG_Folder,namefile],'lon');
lat_IMERG=ncread([IMERG_Folder,namefile],'lat');

% interpolate to the IMERG grid
ID=zeros(length(lon),2);
for i=1:length(lon)
    
    % Station_Name(i)
    % Coordinates of the station you want to extract
    lon_stat=lon(i);
    lat_stat=lat(i);
    %Extraction of the pixel closest to the IMERG coordinates
    ID_lon=knnsearch(lon_IMERG,lon_stat);
    ID_lat=knnsearch(lat_IMERG,lat_stat);
    
    %the pixel of PERSIANN closest to the IMERG coordinates
    ID(i,2)=knnsearch(lon_PERSIANN',lon_IMERG(ID_lon));
    ID(i,1)=knnsearch(lat_PERSIANN',lat_IMERG(ID_lat));
end

PERSIANN_Prec_All_Station=zeros(delta,length(CMD_Station_Location));
kk=1;
for year = start_day(1):end_day(1)
    
    % end day
    if year==end_day(1)
        end_day= datenum(end_day)-datenum([year,1,1])+1;
    else
        end_day=yeardays(year);
    end
    
    for  ii =1:end_day
        
        day_samlength=num2str(ii,'%03d'); % the number of day with the same length
        year_str=num2str(year);
        
        % IPERSIANN data for Current day
        fip=fopen([IPERSIANN_Folder,'ms6s4_d',year_str(3:4),day_samlength,'.bin'],'rb');
        [IPERSIANN_Folder,'ms6s4_d',year_str(3:4),day_samlength,'.bin']
        
        [Array_2D,num]=fread(fip,[columns,rows],'float',0,'b');
        fclose(fip);
        PERSIANN_current_day=Array_2D';
        
        
        PCP_day=[];
        for mm=1:length(ID)
            PCP_Temp=PERSIANN_current_day(ID(mm,1),ID(mm,2) ); % read data for current station
            PCP_day=[PCP_day,PCP_Temp];
        end
        PERSIANN_Prec_All_Station(kk,:)=PCP_day;
        kk=kk+1;
    end
      
end

% nodata
Id_nan=find((PERSIANN_Prec_All_Station)==-9999);
PERSIANN_Prec_All_Station(Id_nan)=0; % nodata

% extreme values >1500 mm
Id_extreme=((PERSIANN_Prec_All_Station)>1500);
PERSIANN_Prec_All_Station(Id_extreme)=0;

PERSIANN=PERSIANN_Prec_All_Station;
save([current_Folder,'PERSIANN.mat'],'PERSIANN');
end








% Data is in 4-byte binary float from a SUN system (big-endian).
% units are mm accumulation for 24 hrs
% NODATA values are -9999
%
% coverage is:
%    60 to -60 lat
%     0 to 360 long
%
% at:
%         .25 x .25 deg resolution
%
% for:
%         480 rows x 1440 cols
%
% data is stored in C style row centric format.
% The first value is centered at
%         59.875,.125
% the second value at
%         59.875,.375
% last 2 values are centered at:
%         -59.875,359.625 &
%         -59.875,359.875
%
%
% the data are mm  and represent the start of the 24hr period in the filename:
% ms6s4_d19001.bin.gz
%
% YY = 2-digit year
% DDD = 3-digit DOY
%
% the data represent the accumulated rainfall in mm from 00:00 to 23:59  UTC.
% for the given date.
%
%
% This data is maintained by:
%         dan braithwaite, dbraithw@uci.edu