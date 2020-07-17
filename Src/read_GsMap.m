% %   gsmap:
% 60N-->60S, 0-->360E;
% 0.1*0.1degree;
% 1 hourly;
% 4-byte-float;
% clc;clear;


function [GsMap] = read_GsMap( GsMAP_Folder,current_Folder,IMERG_Folder,mete_station_name, start_day, end_day )
% 读取gsmap降水数据 (lon, lat) = (3600,1200)
% GsMAP_Folder='F:\Data_ZL\GSMAP\00Z-23Z\';
% mete_station_name='Station_location_Degree_new.xlsx';
% current_Folder='D:\Work_2020\Papers\PCP_merge\predictor\SSPs\\';
% IMERG_Folder='F:\Data_ZL\GPM_IMERG\Early_Run\';


% Reading CMD station location
CMD_Station_Location=xlsread([current_Folder,mete_station_name]);
% CMD_Station_Location(21:end,:)=[];
lon=CMD_Station_Location(:,3);
lat=CMD_Station_Location(:,2);
Station_Name=CMD_Station_Location(:,1);

rows=1200;
columns=3600;
% start_day=[2001,1,1];
% end_day=[2001,1,31];
delta = datenum(end_day)-datenum(start_day)+1;

% PERSIANN information
lon_GsMap=0.05:0.1:359.95;
lat_GsMap=59.95:-0.1:-59.95;

% Basic info of the IMERG Early Run data
namefile='3B-DAY-E.MS.MRG.3IMERG.20000601-S000000-E235959.V06.nc4.nc4';
lon_IMERG=ncread([IMERG_Folder,namefile],'lon');
lat_IMERG=ncread([IMERG_Folder,namefile],'lat');


% reading data
GsMap_Prec_All_Station=zeros(delta,length(CMD_Station_Location));
kk=1;
for year = start_day(1):end_day(1)
    
    % end month
    if year==end_day(1)
        end_month=end_day(2);
    else
        end_month=12;
    end
    
    for month = 1:end_month
        
        % end day
        if month==end_day(2)&&year==end_day(1)
            num_day=end_day(3);
        else
            num_day=eomday(year, month);
        end
        
        
        month_samlength=num2str(month,'%02d'); % the number of month with the same length
        % unzip files
        gunzip([GsMAP_Folder,num2str(year),month_samlength,'\','*.gz']);
        
        for  month_day =1:num_day
            
            day_samlength=num2str(month_day,'%02d'); % the number of day with the same length
            
            % GsMap data for Current day
            fid = fopen([GsMAP_Folder,[num2str(year),month_samlength,'\'],'gsmap_nrt.',num2str(year),month_samlength,...
                day_samlength,'.0.1d.daily.00Z-23Z.dat'], 'r');
            [GsMAP_Folder,'gsmap_nrt.',num2str(year),month_samlength,...
                day_samlength,'.0.1d.daily.00Z-23Z.dat']
            
            GsMAP_read = fread(fid, [columns,rows], 'float');
            GsMAP_read(GsMAP_read < 0) = 0;
            GsMAP_read=GsMAP_read';
            fclose(fid);
            
            
            % Coordinates of the station you want to extract
            %  lon_stat=100.43; lat_stat=38.93; % 52652
            PCP_day=[];
            parfor i=1:length(lon)
                lon_stat=lon(i);
                lat_stat=lat(i);
                %Extraction of the pixel closest to the IMERG coordinates
                ID_lon=knnsearch(lon_IMERG,lon_stat);
                ID_lat=knnsearch(lat_IMERG,lat_stat);
                
                %the pixel of PERSIANN closest to the IMERG coordinates
                ID_lon_GsMAP=knnsearch(lon_GsMap',lon_IMERG(ID_lon));
                ID_lat_GsMAP=knnsearch(lat_GsMap',lat_IMERG(ID_lat));
                
                PCP_Temp=GsMAP_read(ID_lat_GsMAP,ID_lon_GsMAP ); % read data for current station
                PCP_day=[PCP_day,PCP_Temp];
            end
            GsMap_Prec_All_Station(kk,:)=PCP_day;
            kk=kk+1;
        end
    end
end


% Since the data is Daily averaged rain rate [mm/hr] 
% we should covert it to the accumuted one
GsMap=GsMap_Prec_All_Station.*24;

save([current_Folder,'GsMap.mat'],'GsMap');


end

%---------------------Detailed explanation goes here-----------------------
% * GrADS control file for GSMaP_MVK Hourly Gauge-calibrated Rain (ver.7).
% *
% *  Negative value indicates missing due to following reason.
% *     -4: missing due to sea ice in microwave retrieval
% *       -8: missing due to low temperature in microwave retrieval
% *      -99: missing due to no observation by IR and/or microwave
% *
% DSET   ^gsmap_gauge.%y4%m2%d2.%h200.v7.0000.0.dat
% TITLE  GSMaP_GAUGE 0.1deg Hourly (ver.7)
% OPTIONS YREV LITTLE_ENDIAN TEMPLATE
% UNDEF  -99.0
% XDEF   3600 LINEAR  0.05 0.1
% YDEF   1200  LINEAR -59.95 0.1
% ZDEF     1 LEVELS 1013
% TDEF   87600 LINEAR 00Z1jan2014 1hr
% VARS    1
% precip    0  99   hourly averaged rain rate [mm/hr]
% ENDVARS